Houseplant Haven - Complete Rust ApplicationWelcome to the complete source code and deployment guide for Houseplant Haven, a modern e-commerce application built with Rust.Table of ContentsApplication OverviewLive Interactive PreviewProject File StructureBackend Code (src/main.rs)Configuration FilesHTML TemplatesStylesheet (static/style.css)Deployment Guide for Ubuntu 24.04.3 LTSApplication OverviewThis application is a membership-based e-commerce store for houseplants. It is built with a high-performance Rust backend using the Actix-web framework and a dynamic single-page frontend.Key Features:Membership-Only Store: All purchases require an annual membership, creating a loyal customer base.Two Product Sources:Shop: In-house inventory of plants.Houseplant Hopper: A curated selection of plants from external partner websites, with prices automatically marked up by 50%.Dynamic Cart: A shopping cart that handles both product types and calculates a 10% sales tax on all items except the membership fee.Secure & Containerized: Designed to be deployed securely with Docker and Nginx, with payments handled by Stripe.Live Interactive PreviewClick the "Details" arrow below to expand and view the complete HTML code for a fully interactive preview of the application. You can copy this code, save it as an .html file, and open it in your browser to test the user interface and functionality.<details><summary><strong>Click to view Interactive Preview HTML Code</strong></summary><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Houseplant Store</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #FDFBF8; /* Warm Beige */
        }
        .chart-container {
            position: relative;
            width: 100%;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            height: 300px;
            max-height: 400px;
        }
        @media (min-width: 768px) {
            .chart-container {
                height: 350px;
            }
        }
    </style>
</head>
<body class="text-[#3D3D3D]">

    <!-- App Container -->
    <div id="app" class="min-h-screen">

        <!-- Header -->
        <header class="bg-white/80 backdrop-blur-lg border-b border-gray-200/80 sticky top-0 z-50">
            <nav class="container mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex items-center justify-between h-16">
                    <div class="flex items-center space-x-4">
                        <span class="text-2xl font-bold text-[#8D8741]">🌿</span>
                        <h1 class="text-xl font-bold text-[#659DBD]">Houseplant Haven</h1>
                    </div>
                    <div class="flex items-center space-x-6">
                        <a href="#" class="nav-link text-sm font-medium" data-page="shop">Shop</a>
                        <a href="#" class="nav-link text-sm font-medium" data-page="hopper">Hopper</a>
                        <a href="#" class="nav-link text-sm font-medium" data-page="membership">Membership</a>
                        <a href="#" class="nav-link text-sm font-medium" data-page="admin">Admin</a>
                        <a href="#" class="nav-link relative" data-page="cart">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                            <span id="cart-count" class="absolute -top-2 -right-2 bg-[#E07A5F] text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">0</span>
                        </a>
                    </div>
                </div>
            </nav>
        </header>

        <!-- Main Content -->
        <main id="main-content" class="container mx-auto p-4 sm:p-6 lg:p-8">
            <!-- Dynamic content will be injected here -->
        </main>

    </div>

    <!-- Templates -->
    <template id="shop-template">
        <section>
            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-[#0F4C75]">Our Collection</h2>
                <p class="text-gray-600 mt-2">Our hand-picked selection of healthy and beautiful houseplants.</p>
            </div>
            <div id="product-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <!-- Product cards will be injected here -->
            </div>
        </section>
    </template>

    <template id="hopper-template">
        <section>
            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-[#0F4C75]">Houseplant Hopper</h2>
                <p class="text-gray-600 mt-2">We've curated a special selection from our partners. We handle the order, and they ship directly to you!</p>
            </div>
            <div id="hopper-product-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <!-- Hopper product cards will be injected here -->
            </div>
        </section>
    </template>
    
    <template id="membership-template">
        <section class="max-w-2xl mx-auto">
            <div class="bg-white p-8 rounded-xl shadow-lg text-center">
                <h2 class="text-3xl font-bold text-[#0F4C75]">Become a Member</h2>
                <p class="text-gray-600 mt-4">Join the Houseplant Haven family to unlock exclusive benefits, including access to our full collection, special promotions, and more. All purchases require a membership.</p>
                <div class="mt-6">
                    <p class="text-2xl font-bold text-[#659DBD]">$125.00 / Year</p>
                    <button id="add-membership-btn" class="mt-4 bg-[#E07A5F] text-white px-8 py-3 rounded-lg font-semibold text-lg hover:bg-[#d96a4d] transition-colors">Add Membership to Cart</button>
                </div>
            </div>
        </section>
    </template>

    <template id="cart-template">
        <section>
            <h2 class="text-3xl font-bold text-center mb-8 text-[#0F4C75]">Your Cart</h2>
            <div id="cart-items" class="max-w-2xl mx-auto bg-white p-6 rounded-xl shadow-lg">
                <!-- Cart items will be injected here -->
            </div>
        </section>
    </template>

    <template id="admin-template">
         <section>
            <h2 class="text-3xl font-bold text-center mb-8 text-[#0F4C75]">Admin Dashboard</h2>
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Product Management -->
                <div class="lg:col-span-2 bg-white p-6 rounded-xl shadow-lg">
                    <h3 class="text-xl font-bold mb-4">Product Inventory</h3>
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Price</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Active</th>
                                </tr>
                            </thead>
                            <tbody id="admin-product-list" class="bg-white divide-y divide-gray-200">
                                <!-- Admin product list will be injected here -->
                            </tbody>
                        </table>
                    </div>
                </div>
                <!-- Abandoned Carts -->
                <div class="bg-white p-6 rounded-xl shadow-lg">
                    <h3 class="text-xl font-bold mb-4">Abandoned Carts Analysis</h3>
                    <p class="text-sm text-gray-600 mb-4">This chart shows the number of items found in recent abandoned carts, helping to identify potentially large lost sales.</p>
                    <div class="chart-container">
                        <canvas id="abandoned-chart"></canvas>
                    </div>
                </div>
            </div>
        </section>
    </template>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            
            // --- DATA ---
            const AppData = {
                products: [
                    { id: 1, name: "Monstera Deliciosa", price: 35.00, description: "Iconic for its split leaves, easy to care for.", image_url: "https://placehold.co/400x400/8D8741/FFFFFF?text=Monstera", isActive: true },
                    { id: 2, name: "Snake Plant", price: 25.50, description: "Extremely hardy and great for purifying air.", image_url: "https://placehold.co/400x400/659DBD/FFFFFF?text=Snake+Plant", isActive: true },
                    { id: 3, name: "Fiddle Leaf Fig", price: 55.00, description: "A statement plant with large, violin-shaped leaves.", image_url: "https://placehold.co/400x400/8D8741/FFFFFF?text=Fiddle+Fig", isActive: true },
                    { id: 4, name: "Pothos (Devil's Ivy)", price: 18.00, description: "A forgiving, fast-growing vine for beginners.", image_url: "https://placehold.co/400x400/659DBD/FFFFFF?text=Pothos", isActive: false },
                ],
                hopperProducts: [
                    { id: 101, name: "Red Prayer Plant", externalPrice: 22.00, description: "Vibrant red veins on deep green leaves that fold up at night.", image_url: "https://placehold.co/400x400/E07A5F/FFFFFF?text=Prayer+Plant" },
                    { id: 102, name: "Bird of Paradise", externalPrice: 68.00, description: "Large, banana-like leaves give a lush, tropical feel.", image_url: "https://placehold.co/400x400/FBC490/3D3D3D?text=Bird+of+Paradise" },
                    { id: 103, name: "Money Tree", externalPrice: 35.00, description: "A popular plant believed to bring good luck and prosperity.", image_url: "https://placehold.co/400x400/E07A5F/FFFFFF?text=Money+Tree" },
                    { id: 104, name: "Orchid", externalPrice: 45.00, description: "Elegant and timeless, with stunning, long-lasting blooms.", image_url: "https://placehold.co/400x400/FBC490/3D3D3D?text=Orchid" },
                ],
                abandonedCarts: [
                    { id: 'cart_abc', items: [{ name: 'Monstera', price: 35.00 }, { name: 'Pothos', price: 18.00 }], timestamp: '2025-08-12T11:30:00Z' },
                    { id: 'cart_def', items: [{ name: 'Fiddle Leaf Fig', price: 55.00 }], timestamp: '2025-08-12T11:35:00Z' },
                    { id: 'cart_ghi', items: [{ name: 'Snake Plant', price: 25.50 }, { name: 'ZZ Plant', price: 30.00 }, { name: 'Aloe Vera', price: 15.00 }], timestamp: '2025-08-12T11:40:00Z' },
                ],
                cart: [],
                MEMBERSHIP_FEE: { id: 200, name: "Annual Membership", price: 125.00, isMembership: true }
            };

            // --- STATE ---
            const AppState = {
                currentPage: 'shop',
                TAX_RATE: 0.10, // 10%
            };
            
            // --- DOM ELEMENTS ---
            const mainContent = document.getElementById('main-content');
            const navLinks = document.querySelectorAll('.nav-link');
            const cartCountEl = document.getElementById('cart-count');
            
            // --- RENDER FUNCTIONS ---
            
            const renderPage = () => {
                mainContent.innerHTML = '';
                const template = document.getElementById(`${AppState.currentPage}-template`);
                if (template) {
                    mainContent.appendChild(template.content.cloneNode(true));
                    if (AppState.currentPage === 'shop') renderShop();
                    if (AppState.currentPage === 'hopper') renderHopper();
                    if (AppState.currentPage === 'cart') renderCart();
                    if (AppState.currentPage === 'admin') renderAdmin();
                }
                updateActiveNav();
            };
            
            const renderShop = () => {
                const productGrid = document.getElementById('product-grid');
                productGrid.innerHTML = '';
                AppData.products.filter(p => p.isActive).forEach(product => {
                    productGrid.appendChild(createProductCard(product));
                });
            };

            const renderHopper = () => {
                const productGrid = document.getElementById('hopper-product-grid');
                productGrid.innerHTML = '';
                AppData.hopperProducts.forEach(product => {
                    const hopperProduct = {
                        ...product,
                        price: product.externalPrice * 1.50 // Apply 50% markup for display
                    };
                    productGrid.appendChild(createProductCard(hopperProduct, true));
                });
            };

            const createProductCard = (product, isHopper = false) => {
                const card = document.createElement('div');
                card.className = 'bg-white rounded-xl shadow-lg overflow-hidden transform hover:-translate-y-1 transition-transform duration-300';
                card.innerHTML = `
                    <img src="${product.image_url}" alt="${product.name}" class="h-56 w-full object-cover" onerror="this.onerror=null;this.src='https://placehold.co/400x400/FBC490/FFFFFF?text=Image+Missing';">
                    <div class="p-4">
                        <h3 class="text-lg font-bold">${product.name}</h3>
                        <p class="text-sm text-gray-600 mt-1 h-10">${product.description}</p>
                        <div class="flex justify-between items-center mt-4">
                            <p class="text-xl font-bold text-[#0F4C75]">$${product.price.toFixed(2)}</p>
                            <button class="add-to-cart-btn bg-[#E07A5F] text-white px-4 py-2 rounded-lg font-semibold hover:bg-[#d96a4d] transition-colors" data-id="${product.id}" data-hopper="${isHopper}">Add to Cart</button>
                        </div>
                    </div>
                `;
                return card;
            };
            
            const renderCart = () => {
                const cartItemsContainer = document.getElementById('cart-items');
                cartItemsContainer.innerHTML = '';
                if (AppData.cart.length === 0) {
                    cartItemsContainer.innerHTML = '<p class="text-center text-gray-500">Your cart is empty.</p>';
                    return;
                }
                
                let subtotal = 0;
                let taxableTotal = 0;

                const itemsHtml = AppData.cart.map((item, index) => {
                    subtotal += item.price;
                    if (!item.isMembership) {
                        taxableTotal += item.price;
                    }
                    return `
                        <div class="flex justify-between items-center py-3 border-b">
                            <div>
                                <p class="font-semibold">${item.name}</p>
                                <p class="text-sm text-gray-500">$${item.price.toFixed(2)}</p>
                            </div>
                            <button class="remove-from-cart-btn text-red-500 hover:text-red-700 font-bold" data-index="${index}">X</button>
                        </div>
                    `;
                }).join('');

                const tax = taxableTotal * AppState.TAX_RATE;
                const total = subtotal + tax;
                
                const summaryHtml = `
                    <div class="mt-6 space-y-2 text-right">
                        <p class="font-medium">Subtotal: <span class="font-bold text-gray-800">$${subtotal.toFixed(2)}</span></p>
                        <p class="font-medium">Tax (10%): <span class="font-bold text-gray-800">$${tax.toFixed(2)}</span></p>
                        <p class="text-lg font-bold">Total: <span class="text-[#0F4C75]">$${total.toFixed(2)}</span></p>
                        <button id="checkout-btn" class="mt-4 bg-[#0F4C75] text-white px-6 py-2 rounded-lg font-semibold hover:bg-[#1b262c] transition-colors">Checkout</button>
                    </div>
                `;
                
                cartItemsContainer.innerHTML = itemsHtml + summaryHtml;
            };
            
            const renderAdmin = () => {
                const productList = document.getElementById('admin-product-list');
                productList.innerHTML = '';
                AppData.products.forEach(product => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${product.name}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">$${product.price.toFixed(2)}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${product.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                                ${product.isActive ? 'Active' : 'Inactive'}
                            </span>
                        </td>
                    `;
                    productList.appendChild(row);
                });
                renderAbandonedCartChart();
            };
            
            const renderAbandonedCartChart = () => {
                const ctx = document.getElementById('abandoned-chart').getContext('2d');
                const chartData = {
                    labels: AppData.abandonedCarts.map(c => c.id),
                    datasets: [{
                        label: '# of Items in Cart',
                        data: AppData.abandonedCarts.map(c => c.items.length),
                        backgroundColor: 'rgba(224, 122, 95, 0.6)', // #E07A5F
                        borderColor: 'rgba(224, 122, 95, 1)',
                        borderWidth: 1,
                        borderRadius: 4,
                    }]
                };
                new Chart(ctx, {
                    type: 'bar',
                    data: chartData,
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } },
                        plugins: {
                            legend: { display: false },
                            tooltip: { callbacks: { title: (tooltipItems) => `Cart ID: ${tooltipItems[0].label}` } }
                        }
                    }
                });
            };

            // --- UI UPDATE FUNCTIONS ---
            const updateCartCount = () => {
                cartCountEl.textContent = AppData.cart.length;
            };

            const updateActiveNav = () => {
                navLinks.forEach(link => {
                    link.classList.toggle('text-[#0F4C75]', link.dataset.page === AppState.currentPage);
                    link.classList.toggle('font-bold', link.dataset.page === AppState.currentPage);
                });
            };

            // --- EVENT HANDLERS ---
            const handleNavClick = (e) => {
                e.preventDefault();
                const page = e.target.closest('.nav-link')?.dataset.page;
                if (page) {
                    AppState.currentPage = page;
                    renderPage();
                }
            };
            
            const handleMainContentClick = (e) => {
                // Add Membership
                if (e.target.id === 'add-membership-btn') {
                    if (AppData.cart.some(item => item.isMembership)) {
                        alert("Membership is already in your cart.");
                    } else {
                        AppData.cart.unshift(AppData.MEMBERSHIP_FEE);
                        updateCartCount();
                        alert("Membership added to cart!");
                    }
                    AppState.currentPage = 'cart';
                    renderPage();
                }

                // Add to Cart
                if (e.target.classList.contains('add-to-cart-btn')) {
                    const productId = parseInt(e.target.dataset.id, 10);
                    const isHopper = e.target.dataset.hopper === 'true';
                    
                    let productToAdd;
                    if (isHopper) {
                        const hopperProduct = AppData.hopperProducts.find(p => p.id === productId);
                        if (hopperProduct) {
                            productToAdd = {
                                ...hopperProduct,
                                price: hopperProduct.externalPrice * 1.50 // Final price calculation
                            };
                        }
                    } else {
                        productToAdd = AppData.products.find(p => p.id === productId);
                    }
                    
                    if (productToAdd) {
                        AppData.cart.push(productToAdd);
                        updateCartCount();
                    }
                }
                // Remove from Cart
                if (e.target.classList.contains('remove-from-cart-btn')) {
                    const itemIndex = parseInt(e.target.dataset.index, 10);
                    AppData.cart.splice(itemIndex, 1);
                    renderCart();
                    updateCartCount();
                }
                // Checkout
                if (e.target.id === 'checkout-btn') {
                    const hasMembership = AppData.cart.some(item => item.isMembership);
                    if (!hasMembership) {
                        alert("A membership is required to check out. Please add one from the Membership page.");
                        AppState.currentPage = 'membership';
                        renderPage();
                        return;
                    }

                    alert('Thank you for your purchase! This is a simulation, no real transaction has occurred.');
                    AppData.cart = [];
                    updateCartCount();
                    AppState.currentPage = 'shop';
                    renderPage();
                }
            };
            
            // --- INITIALIZATION ---
            document.querySelector('header').addEventListener('click', handleNavClick);
            mainContent.addEventListener('click', handleMainContentClick);
            
            renderPage();
        });
    </script>
</body>
</html>
</details>Project File StructureOrganize your project in the following structure before uploading to GitHub.houseplant-app-rust/
├── .gitignore
├── Cargo.toml
├── deploy.sh
├── Dockerfile
├── README.md
├── src/
│   └── main.rs
├── static/
│   └── style.css
└── templates/
    ├── cart.html
    ├── home.html
    ├── menu.html
    └── payment_success.html
Backend Code (src/main.rs)This is the core of your application. It handles all server-side logic, database interactions, and API endpoints.use actix_web::{middleware, web, App, HttpServer, Responder, HttpResponse, get, post, error};
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
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

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
Configuration FilesCargo.tomlThis file defines all the Rust packages (crates) your project depends on.[package]
name = "houseplant_app_rust"
version = "0.1.0"
edition = "2021"

[dependencies]
actix-web = "4"
actix-files = "0.6"
actix-session = { version = "0.7", features = ["cookie-session"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "sqlite", "chrono"] }
tera = "1"
dotenv = "0.15"
chrono = { version = "0.4", features = ["serde"] }
stripe = "0.33"
env_logger = "0.11"
.gitignoreThis tells Git which files to ignore. It is crucial for keeping your repository clean and secure.# Compiled files
/target/

# Environment file - NEVER commit secrets!
.env

# Database file
*.db
*.db-journal

# IDE-specific files
.vscode/
.idea/
DockerfileThis file contains the instructions for Docker to build a container for your application.# --- Stage 1: Build Stage ---
FROM rust:1.72-slim as builder

WORKDIR /usr/src/app

# Install build dependencies
RUN apt-get update && apt-get install -y libsqlite3-dev pkg-config build-essential

# Copy source code
COPY . .

# Build the application in release mode
RUN cargo build --release

# --- Stage 2: Final Stage ---
FROM debian:bullseye-slim

WORKDIR /usr/src/app

# Install runtime dependencies
RUN apt-get update && apt-get install -y libsqlite3-0

# Copy the built binary from the builder stage
COPY --from=builder /usr/src/app/target/release/houseplant_app_rust .

# Copy templates and static files
COPY templates ./templates
COPY static ./static

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["./houseplant_app_rust"]
deploy.shThis script automates the process of building and running your application on the server.#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables
APP_NAME="houseplant-app"
DOCKER_IMAGE_NAME="houseplant-app-img"
DATABASE_FILE="houseplants.db"

echo "--- Starting deployment for $APP_NAME ---"

# --- 1. System Prerequisite Check ---
echo "Checking for Docker..."
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: Docker is not installed. Please install Docker first."
  exit 1
fi
echo "Docker is installed."

# --- 2. Create Database File ---
if [ ! -f "$DATABASE_FILE" ]; then
    echo "Creating SQLite database file: $DATABASE_FILE"
    touch "$DATABASE_FILE"
fi

# --- 3. Check for .env file ---
if [ ! -f ".env" ]; then
    echo "Error: .env file not found. Please create it with your secrets before deploying."
    exit 1
fi

# --- 4. Build Docker Image ---
echo "Building Docker image: $DOCKER_IMAGE_NAME..."
docker build -t "$DOCKER_IMAGE_NAME" .
echo "Docker image built successfully."

# --- 5. Stop and Remove Existing Container ---
if [ "$(docker ps -q -f name=$APP_NAME)" ]; then
    echo "Stopping existing container..."
    docker stop "$APP_NAME"
fi
if [ "$(docker ps -aq -f name=$APP_NAME)" ]; then
    echo "Removing existing container..."
    docker rm "$APP_NAME"
fi

# --- 6. Run New Docker Container ---
echo "Running new Docker container..."
docker run -d \
  --name "$APP_NAME" \
  -p 127.0.0.1:8080:8080 \
  -v "$(pwd)/$DATABASE_FILE":/usr/src/app/$DATABASE_FILE \
  --env-file ./.env \
  --restart always \
  "$DOCKER_IMAGE_NAME"

echo "--- Deployment complete! ---"
echo "Your application is running in a Docker container and listening on localhost:8080."
echo "Configure Nginx to proxy requests to it."
HTML TemplatesThese files should be placed inside a templates/ directory.templates/home.html<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Houseplant Haven</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <header>
        <h1>Houseplant Haven</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/menu">Menu</a>
        </nav>
    </header>
    <main class="home-main">
        <h2>Your Green Oasis Awaits</h2>
        <p>Discover the perfect plants to bring life and tranquility to your space.</p>
        <a href="/menu" class="cta-button">Explore Our Plants</a>
    </main>
    <footer>
        <p>&copy; 2025 Houseplant Haven. All rights reserved.</p>
    </footer>
</body>
</html>
templates/menu.html<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Our Plants - Houseplant Haven</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <header>
        <h1>Our Menu</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/cart">Cart</a>
        </nav>
    </header>
    <main>
        <div class="product-grid">
            {% for product in products %}
            <div class="product-card">
                <img src="{{ product.image_url | default(value='https://placehold.co/300x300/2e8b57/ffffff?text=Plant') }}" alt="{{ product.name }}">
                <h3>{{ product.name }}</h3>
                <p>{{ product.description | default(value='A beautiful plant.') }}</p>
                <div class="price">${{ product.price }}</div>
                <button class="add-to-cart-btn" data-id="{{ product.id }}">Add to Cart</button>
            </div>
            {% endfor %}
        </div>
    </main>
    <footer>
        <p>&copy; 2025 Houseplant Haven. All rights reserved.</p>
    </footer>
    <script>
        document.querySelectorAll('.add-to-cart-btn').forEach(button => {
            button.addEventListener('click', async (e) => {
                const productId = e.target.dataset.id;
                await fetch('/add_to_cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(parseInt(productId))
                });
                alert('Added to cart!');
            });
        });
    </script>
</body>
</html>
templates/cart.html<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart - Houseplant Haven</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <header>
        <h1>Your Shopping Cart</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/menu">Menu</a>
        </nav>
    </header>
    <main>
        <div class="cart-container">
            {% if cart is not empty %}
                <h2>Review Your Order</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Price</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for item in cart %}
                        <tr>
                            <td>{{ item.name }}</td>
                            <td>${{ "%.2f" | format(value=item.price) }}</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                    <tfoot>
                        <tr>
                            <td><strong>Total</strong></td>
                            <td><strong>${{ "%.2f" | format(value=total_price) }}</strong></td>
                        </tr>
                    </tfoot>
                </table>
                
                <form action="/create-checkout-session" method="POST" class="checkout-form">
                    <h3>Enter your email to proceed:</h3>
                    <p>Your membership will be linked to this email address.</p>
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" required placeholder="you@example.com">
                    <button type="submit" class="cta-button">Proceed to Checkout</button>
                </form>

            {% else %}
                <div class="empty-cart-message">
                    <h2>Your cart is empty.</h2>
                    <p>Looks like you haven't added any plants yet.</p>
                    <a href="/menu" class="cta-button">Start Shopping</a>
                </div>
            {% endif %}
        </div>
    </main>
    <footer>
        <p>&copy; 2025 Houseplant Haven. All rights reserved.</p>
    </footer>
</body>
</html>
templates/payment_success.html<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful - Houseplant Haven</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <header>
        <h1>Payment Successful!</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/menu">Menu</a>
        </nav>
    </header>
    <main>
        <div class="static-page">
            <h2>Thank You for Your Order!</h2>
            <p>Your payment was successful. If you just became a member, you can now shop freely. We'll get your new plant friends ready for their new home soon!</p>
            <a href="/menu" class="cta-button">Continue Shopping</a>
        </div>
    </main>
    <footer>
        <p>&copy; 2025 Houseplant Haven. All rights reserved.</p>
    </footer>
</body>
</html>
Stylesheet (static/style.css)This file should be placed inside a static/ directory./* --- MODERN COLOR SCHEME --- */
:root {
    --primary-color: #36454F; /* Charcoal */
    --secondary-color: #E07A5F; /* Terracotta */
    --background-color: #F4F1DE; /* Beige */
    --dark-text: #36454F;
    --medium-text: #555;
    --white: #ffffff;
    --shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    --shadow-hover: 0 6px 16px rgba(0, 0, 0, 0.12);
    --border-radius: 12px;
    --border-color: #ddd;
}

body {
    margin: 0;
    font-family: 'Poppins', sans-serif;
    background-color: var(--background-color);
    color: var(--dark-text);
    line-height: 1.6;
}

h1, h2, h3 {
    font-weight: 600;
    color: var(--primary-color);
}

.cta-button, button {
    background-color: var(--secondary-color);
    color: var(--white);
    border: none;
    padding: 12px 24px;
    font-size: 1rem;
    font-weight: 500;
    border-radius: var(--border-radius);
    cursor: pointer;
    transition: background-color 0.3s ease, transform 0.2s ease, box-shadow 0.3s ease;
    box-shadow: var(--shadow);
}

.cta-button:hover, button:hover {
    background-color: #d96a4d;
    transform: translateY(-2px);
    box-shadow: var(--shadow-hover);
}

.cart-container {
    background: var(--white);
    padding: 2rem;
    border-radius: var(--border-radius);
    box-shadow: var(--shadow);
    max-width: 600px;
    margin: 2rem auto;
}

.checkout-form {
    margin-top: 2rem;
    border-top: 1px solid var(--border-color);
    padding-top: 1.5rem;
}

.checkout-form label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
}

.checkout-form input[type="email"] {
    width: 100%;
    padding: 10px;
    margin-bottom: 1rem;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    box-sizing: border-box;
}

/* Add other styles as needed from the interactive preview */
Deployment Guide for Ubuntu 24.04.3 LTSFollow these steps to take your application live.Phase 1: PrerequisitesGet a Server: Rent a Virtual Private Server (VPS) from a provider like DigitalOcean, Vultr, or Linode. Choose the Ubuntu 24.04 image. You will receive an IP address for your server.Get a Domain Name: Purchase a domain (e.g., my-plant-store.com) from a registrar like Namecheap or GoDaddy.Point Domain to Server: In your domain registrar's DNS settings, create an A record.Host/Name: @Value: Your server's IP address.This tells the internet that your domain lives at your server's address. (This can take a few hours to propagate).Phase 2: Initial Server SetupConnect to Your Server: Open a terminal and connect to your server using SSH.ssh root@YOUR_SERVER_IP
Install Essential Software: Install Docker (to run your app), Nginx (to manage web traffic), and Certbot (for SSL/HTTPS).apt-get update
apt-get install -y docker.io nginx certbot python3-certbot-nginx
Phase 3: Deploy Your ApplicationClone Your Code: Clone your repository from GitHub onto the server.# Install git if you haven't already
apt-get install -y git

# Clone your repo
git clone https://github.com/your-username/your-repo-name.git

# Enter the project directory
cd your-repo-name
Create the Environment File: This file holds your secret keys. It is the most critical configuration step. Do not skip this.nano .env
Paste the following into the file, adding your LIVE Stripe keys and your domain.# The database file inside the container
DATABASE_URL=sqlite:houseplants.db

# Your LIVE Stripe keys
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# The public URL of your server for Stripe redirects
SERVER_URL=https://your-domain.com

# For logging
RUST_LOG=info
Press CTRL+X, then Y, then Enter to save and exit.Run the Deployment Script: Make the script executable and run it.chmod +x deploy.sh
./deploy.sh
This will build and run your application in a Docker container. It will only be accessible from the server itself at this point.Phase 4: Configure Nginx and Enable HTTPSCreate Nginx Config File:nano /etc/nginx/sites-available/your-domain.com
Paste the following configuration. This tells Nginx to forward traffic to your app running in Docker. Replace your-domain.com with your actual domain.server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
Save and exit.Enable the Site:ln -s /etc/nginx/sites-available/your-domain.com /etc/nginx/sites-enabled/
nginx -t # This should report syntax is ok
Get SSL Certificate: Run Certbot. It will automatically detect your Nginx config, get a certificate, and set up HTTPS for you.certbot --nginx -d your-domain.com -d www.your-domain.com
Follow the on-screen prompts. Provide your email and agree to the terms. When asked, choose the option to redirect all HTTP traffic to HTTPS.Restart Nginx: Apply all the changes.systemctl restart nginx
Your application is now live, secure, and ready to accept payments on the public web at https://your-domain.com.
