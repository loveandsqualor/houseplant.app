use actix_web::{middleware, web, App, HttpServer, Responder, HttpResponse, get, post, error, guard, HttpRequest};
use actix_session::{Session, CookieSession};
use serde::{Serialize, Deserialize};
use sqlx::sqlite::{SqlitePool};
use sqlx::Row;
use tera::{Tera, Context};
use std::env;
use dotenv::dotenv;
use chrono::{Utc, Duration};
use reqwest;
use csv;

// --- Data Structures ---

#[derive(Debug, Serialize, Deserialize, Clone, sqlx::FromRow)]
struct Product {
    id: i64,
    name: String,
    price: f64,
    description: Option<String>,
    image_url: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct CartItem {
    id: i64,
    name: String,
    price: f64,
}

#[derive(Debug, sqlx::FromRow, Serialize, Deserialize)]
struct User {
    id: i64,
    email: String,
    is_member: bool,
    membership_expires_on: Option<chrono::DateTime<Utc>>,
    is_admin: bool,
}

const MEMBERSHIP_PRODUCT_ID: i64 = 100;
const MEMBERSHIP_PRICE: f64 = 125.00;

// --- Database Functions ---

async fn init_db(pool: &SqlitePool) -> Result<(), sqlx::Error> {
    // Products table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT,
            image_url TEXT
        );
        "#,
    )
    .execute(pool)
    .await?;

    // Users table
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            is_member BOOLEAN DEFAULT 0,
            membership_expires_on DATETIME,
            is_admin BOOLEAN DEFAULT 0
        );
        "#,
    )
    .execute(pool)
    .await?;

    Ok(())
}


// --- Helper Functions ---
fn is_user_member(session: &Session) -> bool {
    session.get::<bool>("is_member").unwrap_or(Some(false)).unwrap_or(false)
}

fn is_admin(session: &Session) -> bool {
    session.get::<bool>("is_admin").unwrap_or(Some(false)).unwrap_or(false)
}

fn add_membership_to_cart(cart: &mut Vec<CartItem>) {
    if !cart.iter().any(|item| item.id == MEMBERSHIP_PRODUCT_ID) {
        cart.insert(0, CartItem {
            id: MEMBERSHIP_PRODUCT_ID,
            name: "Annual Membership".to_string(),
            price: MEMBERSHIP_PRICE,
        });
    }
}

// --- Route Handlers ---

#[get("/")]
async fn home(tera: web::Data<Tera>) -> impl Responder {
    let context = Context::new();
    let rendered = tera.render("home.html", &context).unwrap_or_else(|_| "Template error".to_string());
    HttpResponse::Ok().body(rendered)
}

#[get("/menu")]
async fn menu(pool: web::Data<SqlitePool>, tera: web::Data<Tera>) -> impl Responder {
    let products: Result<Vec<Product>, _> = sqlx::query_as("SELECT * FROM products")
        .fetch_all(pool.get_ref())
        .await;

    match products {
        Ok(products) => {
            let mut context = Context::new();
            context.insert("products", &products);
            let rendered = tera.render("menu.html", &context).unwrap_or_else(|_| "Template error".to_string());
            HttpResponse::Ok().body(rendered)
        }
        Err(_) => HttpResponse::InternalServerError().body("Error fetching products."),
    }
}

#[post("/add_to_cart")]
async fn add_to_cart(pool: web::Data<SqlitePool>, session: Session, product_id_json: web::Json<i64>) -> impl Responder {
    let product_id = product_id_json.into_inner();
    
    let product_result: Result<Product, _> = sqlx::query_as("SELECT * FROM products WHERE id = ?")
        .bind(product_id)
        .fetch_one(pool.get_ref())
        .await;
    
    if let Ok(product) = product_result {
        let mut cart: Vec<CartItem> = session.get("cart").unwrap_or_else(|_| Some(Vec::new())).unwrap_or_default();
        
        if !is_user_member(&session) {
            add_membership_to_cart(&mut cart);
        }

        cart.push(CartItem { id: product.id, name: product.name, price: product.price });
        session.insert("cart", cart).unwrap();
        
        HttpResponse::Ok().json({"success": true})
    } else {
        HttpResponse::NotFound().json({"success": false, "message": "Product not found"})
    }
}

#[get("/cart")]
async fn view_cart(session: Session, tera: web::Data<Tera>) -> impl Responder {
    let mut cart: Vec<CartItem> = session.get("cart").unwrap_or_else(|_| Some(Vec::new())).unwrap_or_default();

    if !cart.is_empty() && !is_user_member(&session) {
        add_membership_to_cart(&mut cart);
        session.insert("cart", &cart).unwrap();
    }
    
    let total_price: f64 = cart.iter().map(|item| item.price).sum();

    let mut context = Context::new();
    context.insert("cart", &cart);
    context.insert("total_price", &total_price);
    
    let rendered = tera.render("cart.html", &context).unwrap_or_else(|_| "Template error".to_string());
    HttpResponse::Ok().body(rendered)
}

#[post("/create-transfer-request")]
async fn create_transfer_request(session: Session, form: web::Form<serde_json::Value>) -> impl Responder {
    let cart: Vec<CartItem> = session.get("cart").unwrap_or_else(|_| Some(Vec::new())).unwrap_or_default();
    if cart.is_empty() {
        return HttpResponse::BadRequest().body("Cart is empty");
    }

    let total_amount = cart.iter().map(|item| item.price).sum::<f64>();

    let zenobia_api_key = env::var("ZENOBIA_API_KEY").expect("ZENOBIA_API_KEY must be set");
    let zenobia_api_url = env::var("ZENOBIA_API_URL").expect("ZENOBIA_API_URL must be set");

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/create-transfer-request", zenobia_api_url))
        .header("Authorization", format!("Bearer {}", zenobia_api_key))
        .json(&serde_json::json!({
            "amount": (total_amount * 100.0) as i64, // Amount in cents
        }))
        .send()
        .await;

    match response {
        Ok(res) => {
            if res.status().is_success() {
                let transfer_response: serde_json::Value = res.json().await.unwrap();
                HttpResponse::Ok().json(transfer_response)
            } else {
                HttpResponse::InternalServerError().body("Error from Zenobia Pay API.")
            }
        }
        Err(_) => HttpResponse::InternalServerError().body("Failed to communicate with Zenobia Pay."),
    }
}


// --- Admin Routes ---

async fn admin_dashboard(session: Session, tera: web::Data<Tera>) -> impl Responder {
    if !is_admin(&session) {
        return HttpResponse::Forbidden().body("Access denied");
    }
    let context = Context::new();
    let rendered = tera.render("admin/dashboard.html", &context).unwrap();
    HttpResponse::Ok().body(rendered)
}

async fn admin_products(session: Session, pool: web::Data<SqlitePool>, tera: web::Data<Tera>) -> impl Responder {
    if !is_admin(&session) {
        return HttpResponse::Forbidden().body("Access denied");
    }
    
    let products: Vec<Product> = sqlx::query_as("SELECT * FROM products").fetch_all(pool.get_ref()).await.unwrap();
    let mut context = Context::new();
    context.insert("products", &products);
    let rendered = tera.render("admin/products.html", &context).unwrap();
    HttpResponse::Ok().body(rendered)
}

#[derive(Deserialize)]
struct ProductFormData {
    name: String,
    price: f64,
    description: String,
    image_url: String,
}

async fn add_product(session: Session, pool: web::Data<SqlitePool>, form: web::Form<ProductFormData>) -> impl Responder {
    if !is_admin(&session) {
        return HttpResponse::Forbidden().body("Access denied");
    }
    
    sqlx::query("INSERT INTO products (name, price, description, image_url) VALUES (?, ?, ?, ?)")
        .bind(&form.name)
        .bind(&form.price)
        .bind(&form.description)
        .bind(&form.image_url)
        .execute(pool.get_ref())
        .await
        .unwrap();

    HttpResponse::SeeOther().append_header(("Location", "/admin/products")).finish()
}

async fn admin_users(session: Session, pool: web::Data<SqlitePool>, tera: web::Data<Tera>) -> impl Responder {
    if !is_admin(&session) {
        return HttpResponse::Forbidden().body("Access denied");
    }

    let users: Vec<User> = sqlx::query_as("SELECT * FROM users").fetch_all(pool.get_ref()).await.unwrap();
    let mut context = Context::new();
    context.insert("users", &users);
    let rendered = tera.render("admin/users.html", &context).unwrap();
    HttpResponse::Ok().body(rendered)
}

async fn export_users_csv(session: Session, pool: web::Data<SqlitePool>) -> impl Responder {
    if !is_admin(&session) {
        return HttpResponse::Forbidden().body("Access denied");
    }
    let users: Vec<User> = sqlx::query_as("SELECT * FROM users").fetch_all(pool.get_ref()).await.unwrap();

    let mut wtr = csv::Writer::from_writer(vec![]);
    wtr.serialize(users).unwrap();
    let data = String::from_utf8(wtr.into_inner().unwrap()).unwrap();

    HttpResponse::Ok()
        .content_type("text/csv")
        .append_header(("Content-Disposition", "attachment; filename=\"users.csv\""))
        .body(data)
}

// --- Main Function ---

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let pool = SqlitePool::connect(&database_url).await.expect("Failed to create database pool.");
    init_db(&pool).await.expect("Failed to initialize database.");

    let tera = Tera::new("templates/**/*.html").expect("Parsing error");

    println!("🚀 Server started at http://127.0.0.1:8080");

    HttpServer::new(move || {
        App::new()
            .wrap(CookieSession::signed(&[0; 32]).secure(false))
            .app_data(web::Data::new(pool.clone()))
            .app_data(web::Data::new(tera.clone()))
            .service(home)
            .service(menu)
            .service(add_to_cart)
            .service(view_cart)
            .service(create_transfer_request)
            .service(actix_files::Files::new("/static", "static"))
            .service(
                web::scope("/admin")
                    .guard(guard::fn_guard(|req: &guard::GuardContext| {
                        let session = req.get_session();
                        is_admin(&session)
                    }))
                    .route("", web::get().to(admin_dashboard))
                    .route("/products", web::get().to(admin_products))
                    .route("/products/add", web::post().to(add_product))
                    .route("/users", web::get().to(admin_users))
                    .route("/users/export", web::get().to(export_users_csv)),
            )
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}