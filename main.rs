use actix_web::{middleware, web, App, HttpServer, Responder, HttpResponse, get, post, error};
use actix_session::{Session, CookieSession};
use serde::{Serialize, Deserialize};
use sqlx::sqlite::{SqlitePool, SqliteRow};
use sqlx::Row;
use tera::{Tera, Context};
use std::env;
use dotenv::dotenv;
use chrono::{Utc, Duration};
use stripe::{Client, CreateCheckoutSession, CreateCheckoutSessionLineItems, CheckoutSessionMode, Currency, Event, EventObject, EventType};

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

#[derive(Debug, sqlx::FromRow, Serialize)]
struct User {
    id: i64,
    email: String,
    is_member: bool,
    membership_expires_on: Option<chrono::DateTime<Utc>>,
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
            membership_expires_on DATETIME
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
    
    // Fetch the product from the database
    let product_result: Result<Product, _> = sqlx::query_as("SELECT * FROM products WHERE id = ?")
        .bind(product_id)
        .fetch_one(pool.get_ref())
        .await;
    
    if let Ok(product) = product_result {
        let mut cart: Vec<CartItem> = session.get("cart").unwrap_or_else(|_| Some(Vec::new())).unwrap_or_default();
        
        // If user isn't a member, automatically add membership
        if !is_user_member(&session) {
            add_membership_to_cart(&mut cart);
        }

        // Add the actual product
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

    // If the cart has items but no membership, and the user isn't a logged-in member, add it.
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


#[post("/create-checkout-session")]
async fn create_checkout_session(session: Session, stripe_client: web::Data<Client>, form: web::Form<serde_json::Value>) -> impl Responder {
    let mut cart: Vec<CartItem> = session.get("cart").unwrap_or_else(|_| Some(Vec::new())).unwrap_or_default();
    let customer_email = form.get("email").and_then(|v| v.as_str()).unwrap_or_default();

    if customer_email.is_empty() {
        return HttpResponse::BadRequest().body("Email is required.");
    }
    session.insert("customer_email", customer_email).unwrap();

    // Ensure membership is in the cart for non-members
    if !is_user_member(&session) {
        add_membership_to_cart(&mut cart);
        session.insert("cart", &cart).unwrap();
    }
    
    if cart.is_empty() {
        return HttpResponse::BadRequest().body("Cart is empty");
    }

    let line_items: Vec<CreateCheckoutSessionLineItems> = cart.iter().map(|item| {
        let mut line_item = CreateCheckoutSessionLineItems::new();
        line_item.price_data = Some(stripe::CreateCheckoutSessionLineItemsPriceData {
            currency: Currency::USD,
            product_data: Some(stripe::CreateCheckoutSessionLineItemsPriceDataProductData {
                name: item.name.clone(),
                ..Default::default()
            }),
            unit_amount: Some((item.price * 100.0) as i64),
            ..Default::default()
        });
        line_item.quantity = Some(1);
        line_item
    }).collect();
    
    let server_url = env::var("SERVER_URL").unwrap_or_else(|_| "http://127.0.0.1:8080".to_string());

    let mut params = CreateCheckoutSession::new();
    params.line_items = Some(line_items);
    params.mode = Some(CheckoutSessionMode::Payment);
    params.success_url = Some(&format!("{}/payment_success?session_id={{CHECKOUT_SESSION_ID}}", server_url));
    params.cancel_url = Some(&format!("{}/cart", server_url));
    params.customer_email = Some(customer_email);

    match stripe::CheckoutSession::create(&stripe_client, params).await {
        Ok(checkout_session) => {
            if let Some(url) = checkout_session.url {
                HttpResponse::SeeOther().append_header(("Location", url)).finish()
            } else {
                HttpResponse::InternalServerError().body("Stripe did not provide a redirect URL.")
            }
        },
        Err(e) => HttpResponse::InternalServerError().body(format!("Error creating Stripe session: {}", e))
    }
}

#[post("/stripe-webhook")]
async fn stripe_webhook(pool: web::Data<SqlitePool>, req: web::HttpRequest, payload: web::Bytes) -> impl Responder {
    let sig = req.headers().get("stripe-signature").and_then(|s| s.to_str().ok()).unwrap_or("");
    let webhook_secret = env::var("STRIPE_WEBHOOK_SECRET").expect("STRIPE_WEBHOOK_SECRET must be set");

    let event = match Event::construct(std::str::from_utf8(&payload).unwrap(), sig, &webhook_secret) {
        Ok(event) => event,
        Err(e) => return HttpResponse::BadRequest().body(format!("Webhook error: {}", e)),
    };

    if let EventObject::CheckoutSession(session) = event.data.object {
        if event.event_type == EventType::CheckoutSessionCompleted {
            if let Some(email) = session.customer_details.and_then(|d| d.email) {
                // Check if user exists
                let user: Result<User, _> = sqlx::query_as("SELECT * FROM users WHERE email = ?")
                    .bind(&email)
                    .fetch_one(pool.get_ref())
                    .await;

                let expiration_date = Utc::now() + Duration::days(365);

                if user.is_err() {
                    // New user, create them
                    sqlx::query("INSERT INTO users (email, is_member, membership_expires_on) VALUES (?, ?, ?)")
                        .bind(&email)
                        .bind(true)
                        .bind(expiration_date)
                        .execute(pool.get_ref())
                        .await.ok();
                    println!("New member created: {}", email);
                } else {
                    // Existing user, update their membership
                    sqlx::query("UPDATE users SET is_member = ?, membership_expires_on = ? WHERE email = ?")
                        .bind(true)
                        .bind(expiration_date)
                        .bind(&email)
                        .execute(pool.get_ref())
                        .await.ok();
                    println!("Membership renewed for: {}", email);
                }
            }
        }
    }

    HttpResponse::Ok().finish()
}

#[get("/payment_success")]
async fn payment_success(session: Session, tera: web::Data<Tera>) -> impl Responder {
    // Simulate "logging in" the user by setting their membership status in the session
    // In a real app, you'd have a full login system.
    if let Ok(Some(_email)) = session.get::<String>("customer_email") {
        session.insert("is_member", true).unwrap();
    }
    session.remove("cart"); // Clear the cart
    session.remove("customer_email");
    
    let context = Context::new();
    let rendered = tera.render("payment_success.html", &context).unwrap_or_else(|_| "Template error".to_string());
    HttpResponse::Ok().body(rendered)
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

    let secret_key = env::var("STRIPE_SECRET_KEY").expect("STRIPE_SECRET_KEY must be set");
    let stripe_client = Client::new(secret_key);

    println!("🚀 Server started at http://127.0.0.1:8080");

    HttpServer::new(move || {
        App::new()
            .wrap(CookieSession::signed(&[0; 32]).secure(false))
            .app_data(web::Data::new(pool.clone()))
            .app_data(web::Data::new(tera.clone()))
            .app_data(web::Data::new(stripe_client.clone()))
            .service(home)
            .service(menu)
            .service(add_to_cart)
            .service(view_cart)
            .service(create_checkout_session)
            .service(stripe_webhook)
            .service(payment_success)
            .service(actix_files::Files::new("/static", "static"))
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
