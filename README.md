<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Interactive Houseplant Store</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/dayjs@1/dayjs.min.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #F3E8FF; /* Light Lavender */
        }
        .chart-container {
            position: relative;
            width: 100%;
            max-width: 800px;
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
        .modal-overlay {
            transition: opacity 0.3s ease;
        }
        .modal-content {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .tab-active {
            border-color: #8A2BE2; /* BlueViolet */
            color: #4B0082; /* Indigo */
            background-color: #F3E8FF;
        }
        .groovy-button {
            transition: all 0.2s ease-in-out;
        }
        .groovy-button:hover {
            transform: translateY(-2px) scale(1.05);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body class="text-[#3D3D3D]">

    <!-- App Container -->
    <div id="app" class="min-h-screen">

        <!-- Header -->
        <header class="bg-white/70 backdrop-blur-lg border-b border-purple-200/80 sticky top-0 z-40">
            <nav class="container mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex items-center justify-between h-16">
                    <div class="flex items-center space-x-4">
                        <span class="text-3xl">🌿</span>
                        <h1 class="text-xl font-bold text-[#4B0082]">Houseplant Haven</h1>
                    </div>
                    <div id="nav-links" class="flex items-center space-x-6">
                        <a href="#" class="nav-link text-sm font-medium" data-page="sale-menu">Sale Menu</a>
                        <a href="#" class="nav-link text-sm font-medium" data-page="my-sesh" style="display: none;">My Sesh</a>
                        <a href="#" class="nav-link text-sm font-medium" data-page="membership">Membership</a>
                        <!-- Admin link injected by JS -->
                        <a href="#" class="nav-link relative" data-page="cart">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                            </svg>
                            <span id="cart-count" class="absolute -top-2 -right-2 bg-[#FF7F50] text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">0</span>
                        </a>
                        <!-- Login/Logout Button will be injected here -->
                    </div>
                </div>
            </nav>
        </header>

        <!-- Main Content -->
        <main id="main-content" class="container mx-auto p-4 sm:p-6 lg:p-8">
            <!-- Dynamic content will be injected here -->
        </main>

    </div>
    
    <!-- Generic Modal -->
    <div id="modal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 modal-overlay opacity-0 pointer-events-none">
        <div id="modal-content" class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6 modal-content scale-95 max-h-[80vh] overflow-y-auto">
            <!-- Modal content will be injected here -->
        </div>
    </div>

    <!-- Templates -->
    <template id="sale-menu-template">
        <section>
            <div class="text-center mb-8">
                <h2 class="text-3xl font-bold text-[#4B0082]">Sale Menu</h2>
                <p class="text-gray-600 mt-2">Browse our in-house collection and curated items from our partners.</p>
            </div>
            <h3 class="text-2xl font-bold text-[#4B0082] mb-4 border-b-2 border-purple-200 pb-2">Our Collection</h3>
            <div id="product-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-12"></div>
            <h3 class="text-2xl font-bold text-[#4B0082] mb-4 border-b-2 border-purple-200 pb-2">Houseplant Hopper</h3>
            <div id="hopper-product-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"></div>
        </section>
    </template>
    
    <template id="membership-template">
        <section class="max-w-2xl mx-auto">
            <div class="bg-white p-8 rounded-xl shadow-lg text-center">
                <h2 class="text-3xl font-bold text-[#4B0082]">Become a Member</h2>
                <p class="text-gray-600 mt-4">Join the Houseplant Haven family to unlock exclusive benefits, including access to our full collection, special promotions, and your own personal plant care dashboard.</p>
                <div class="mt-6">
                    <p class="text-2xl font-bold text-[#8A2BE2]">$125.00 / Year</p>
                    <button id="add-membership-btn" class="mt-4 bg-[#FF7F50] text-white px-8 py-3 rounded-lg font-semibold text-lg groovy-button">Add Membership to Cart</button>
                </div>
                <p class="mt-4 text-sm text-gray-500">Already a member? <a href="#" id="login-from-membership" class="font-semibold text-[#8A2BE2] hover:underline">Log In</a></p>
            </div>
        </section>
    </template>

    <template id="my-sesh-template">
        <section id="my-sesh-container">
            <!-- This content will be dynamically replaced based on user type -->
        </section>
    </template>

    <template id="cart-template">
        <section>
            <h2 class="text-3xl font-bold text-center mb-8 text-[#4B0082]">Your Cart</h2>
            <div id="cart-items" class="max-w-2xl mx-auto bg-white p-6 rounded-xl shadow-lg"></div>
        </section>
    </template>

    <template id="admin-template">
         <section>
            <h2 class="text-3xl font-bold text-center mb-8 text-[#4B0082]">Admin Dashboard</h2>
            <!-- Admin Tabs -->
            <div class="mb-6 border-b border-gray-200">
                <nav class="-mb-px flex space-x-6" aria-label="Tabs">
                    <button class="admin-tab whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" data-tab="members">Members</button>
                    <button class="admin-tab whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" data-tab="shop-items">Shop Items</button>
                    <button class="admin-tab whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" data-tab="hopper-sources">Hopper Sources</button>
                    <button class="admin-tab whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" data-tab="hopper-items">Hopper Items</button>
                </nav>
            </div>
            <!-- Admin Tab Content -->
            <div id="admin-tab-content"></div>
        </section>
    </template>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            
            // --- DATA ---
            const AppData = {
                products: [
                    { id: 1, name: "Monstera Deliciosa", price: 35.00, description: "Iconic for its split leaves.", image_url: "https://placehold.co/400x400/8A2BE2/FFFFFF?text=Monstera", isActive: true, isTrackable: true },
                    { id: 2, name: "Snake Plant", price: 25.50, description: "Extremely hardy and great for purifying air.", image_url: "https://placehold.co/400x400/9370DB/FFFFFF?text=Snake+Plant", isActive: true, isTrackable: true },
                    { id: 3, name: "Fiddle Leaf Fig", price: 55.00, description: "A statement plant with large leaves.", image_url: "https://placehold.co/400x400/8A2BE2/FFFFFF?text=Fiddle+Fig", isActive: true, isTrackable: false },
                    { id: 4, name: "Pothos (Devil's Ivy)", price: 18.00, description: "A forgiving, fast-growing vine.", image_url: "https://placehold.co/400x400/9370DB/FFFFFF?text=Pothos", isActive: false, isTrackable: true },
                ],
                hopperSources: [
                    { id: 1, name: "Bloomscape", url: "https://bloomscape.com/collections/plants" },
                    { id: 2, name: "The Sill", url: "https://www.thesill.com/collections/live-plants" },
                ],
                hopperProducts: [
                    { id: 101, name: "Red Prayer Plant", externalPrice: 22.00, description: "Vibrant red veins on deep green leaves.", image_url: "https://placehold.co/400x400/FF7F50/FFFFFF?text=Prayer+Plant", sourceId: 1, isTrackable: true },
                    { id: 102, name: "Bird of Paradise", externalPrice: 68.00, description: "Large, banana-like leaves give a tropical feel.", image_url: "https://placehold.co/400x400/FFA07A/3D3D3D?text=Bird+of+Paradise", sourceId: 2, isTrackable: false },
                ],
                members: [
                    { id: 1, name: "Alice Johnson", email: "alice@example.com", phone: "555-123-4567", memberSince: "2024-03-15", orders: [
                        { orderId: 'ORD-001', date: '2024-03-15', total: 163.50, paymentMethod: 'Zenobia Pay', items: [{id: 200, name: 'Annual Membership', price: 125.00, isMembership: true}, {id: 1, name: 'Monstera Deliciosa', price: 35.00, description: "Iconic for its split leaves.", image_url: "https://placehold.co/400x400/8A2BE2/FFFFFF?text=Monstera", isTrackable: true}] }
                    ]},
                    { id: 2, name: "Bob Williams", email: "bob@example.com", phone: "555-987-6543", memberSince: "2024-05-20", orders: [
                        { orderId: 'ORD-002', date: '2024-05-20', total: 153.05, paymentMethod: 'PayPal', items: [{id: 200, name: 'Annual Membership', price: 125.00, isMembership: true}, {id: 2, name: 'Snake Plant', price: 25.50, description: "Extremely hardy and great for purifying air.", image_url: "https://placehold.co/400x400/9370DB/FFFFFF?text=Snake+Plant", isTrackable: true}] },
                        { orderId: 'ORD-003', date: '2024-07-11', total: 36.30, paymentMethod: 'Zenobia Pay', items: [{id: 101, name: 'Red Prayer Plant', price: 33.00, description: "Vibrant red veins on deep green leaves.", image_url: "https://placehold.co/400x400/FF7F50/FFFFFF?text=Prayer+Plant", isTrackable: true}] }
                    ]},
                ],
                myPlants: [
                    { id: 1, name: "Monstera Deliciosa", image_url: "https://placehold.co/400x400/8A2BE2/FFFFFF?text=Monstera", purchaseDate: '2025-08-12' },
                    { id: 101, name: "Red Prayer Plant", image_url: "https://placehold.co/400x400/FF7F50/FFFFFF?text=Prayer+Plant", purchaseDate: '2025-08-05' },
                    { id: 2, name: "Snake Plant", image_url: "https://placehold.co/400x400/9370DB/FFFFFF?text=Snake+Plant", purchaseDate: '2025-07-30' },
                ],
                cart: [],
                MEMBERSHIP_FEE: { id: 200, name: "Annual Membership", price: 125.00, isMembership: true }
            };

            const AppState = { currentPage: 'sale-menu', currentAdminTab: 'members', TAX_RATE: 0.10, newMemberInfo: null, isLoggedInMember: false, isSuperUser: false };
            
            const mainContent = document.getElementById('main-content');
            const navLinksContainer = document.getElementById('nav-links');
            const cartCountEl = document.getElementById('cart-count');
            const modal = document.getElementById('modal');
            
            const renderPage = () => {
                mainContent.innerHTML = '';
                const template = document.getElementById(`${AppState.currentPage}-template`);
                if (template) {
                    mainContent.appendChild(template.content.cloneNode(true));
                    if (AppState.currentPage === 'sale-menu') { renderShop(); renderHopper(); }
                    if (AppState.currentPage === 'cart') renderCart();
                    if (AppState.currentPage === 'admin') renderAdmin();
                    if (AppState.currentPage === 'my-sesh') renderMySesh();
                }
                updateActiveNav();
            };
            
            const renderShop = () => {
                const productGrid = document.getElementById('product-grid');
                productGrid.innerHTML = '';
                AppData.products.filter(p => p.isActive).forEach(product => productGrid.appendChild(createProductCard(product)));
            };

            const renderHopper = () => {
                const productGrid = document.getElementById('hopper-product-grid');
                productGrid.innerHTML = '';
                AppData.hopperProducts.forEach(product => {
                    const hopperProduct = { ...product, price: product.externalPrice * 1.50 };
                    productGrid.appendChild(createProductCard(hopperProduct, true));
                });
            };

            const createProductCard = (product, isHopper = false) => {
                const card = document.createElement('div');
                card.className = 'bg-white rounded-xl shadow-lg overflow-hidden transform hover:-translate-y-1 transition-transform duration-300';
                card.innerHTML = `
                    <img src="${product.image_url}" alt="${product.name}" class="h-56 w-full object-cover" onerror="this.onerror=null;this.src='https://placehold.co/400x400/FFA07A/FFFFFF?text=Image+Missing';">
                    <div class="p-4 flex flex-col flex-grow">
                        <h3 class="text-lg font-bold">${product.name}</h3>
                        <p class="text-sm text-gray-600 mt-1 h-10 flex-grow">${product.description}</p>
                        <div class="flex justify-between items-center mt-4">
                            <p class="text-xl font-bold text-[#4B0082]">$${product.price.toFixed(2)}</p>
                            <button class="add-to-cart-btn bg-[#FF7F50] text-white px-4 py-2 rounded-lg font-semibold groovy-button" data-id="${product.id}" data-hopper="${isHopper}">Add to Cart</button>
                        </div>
                    </div>`;
                return card;
            };

            const renderMySesh = () => {
                const container = document.getElementById('my-sesh-container');
                if (!container) return;

                if (AppState.isSuperUser) {
                    const adminTemplate = document.getElementById('admin-template');
                    container.innerHTML = adminTemplate.innerHTML;
                    renderAdmin();
                } else {
                    container.innerHTML = `
                        <div class="text-center mb-8">
                            <h2 class="text-3xl font-bold text-[#4B0082]">My Sesh Dashboard</h2>
                            <p class="text-gray-600 mt-2">Keep track of your plant's happiness and order history.</p>
                        </div>
                         <div class="bg-white p-6 rounded-xl shadow-lg mb-8">
                            <h3 class="text-xl font-bold mb-4">Order History</h3>
                            <div class="chart-container">
                                <canvas id="order-history-chart"></canvas>
                            </div>
                        </div>
                        <div id="my-plants-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"></div>
                    `;
                    const myPlantsGrid = document.getElementById('my-plants-grid');
                    myPlantsGrid.innerHTML = '';
                    AppData.myPlants.forEach(plant => myPlantsGrid.appendChild(createMyPlantCard(plant)));
                    renderOrderHistoryChart();
                }
            };
            
            const getHappyDaysStatus = (purchaseDate) => {
                const daysSincePurchase = dayjs().diff(dayjs(purchaseDate), 'day');
                if (daysSincePurchase <= 6) {
                    return { status: 'Happy', color: 'text-green-500', bgColor: 'bg-green-100', days: daysSincePurchase };
                } else if (daysSincePurchase <= 12) {
                    return { status: 'Mid', color: 'text-yellow-500', bgColor: 'bg-yellow-100', days: daysSincePurchase };
                } else {
                    return { status: 'Crashed', color: 'text-red-500', bgColor: 'bg-red-100', days: daysSincePurchase };
                }
            };

            const createMyPlantCard = (plant) => {
                const card = document.createElement('div');
                card.className = 'bg-white rounded-xl shadow-lg p-4 flex flex-col';
                const happyStatus = getHappyDaysStatus(plant.purchaseDate);

                card.innerHTML = `
                    <img src="${plant.image_url}" alt="${plant.name}" class="h-48 w-full object-cover rounded-lg mb-4" onerror="this.onerror=null;this.src='https://placehold.co/400x400/FFA07A/FFFFFF?text=Image+Missing';">
                    <h3 class="text-lg font-bold">${plant.name}</h3>
                    <div class="text-sm text-gray-600 mt-2 space-y-2">
                        <p><strong>Purchased:</strong> ${dayjs(plant.purchaseDate).format('MMM D, YYYY')}</p>
                        <div class="flex items-center">
                            <p class="font-bold mr-2">Happy Days:</p>
                            <div class="flex items-center justify-center h-8 w-8 rounded-full ${happyStatus.bgColor}">
                                <span class="font-bold text-lg ${happyStatus.color}">${happyStatus.days}</span>
                            </div>
                            <p class="ml-2 font-semibold ${happyStatus.color}">${happyStatus.status}</p>
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
                
                let subtotal = 0, taxableTotal = 0;
                const itemsHtml = AppData.cart.map((item, index) => {
                    subtotal += item.price;
                    if (!item.isMembership) taxableTotal += item.price;
                    return `<div class="flex justify-between items-center py-3 border-b">
                                <div>
                                    <p class="font-semibold">${item.name}</p>
                                    <p class="text-sm text-gray-500">$${item.price.toFixed(2)}</p>
                                </div>
                                <button class="remove-from-cart-btn text-red-500 hover:text-red-700 font-bold" data-index="${index}">X</button>
                            </div>`;
                }).join('');

                const tax = taxableTotal * AppState.TAX_RATE;
                const total = subtotal + tax;
                
                let summaryHtml = `
                    <div class="mt-6 space-y-2 text-right">
                        <p class="font-medium">Subtotal: <span class="font-bold text-gray-800">$${subtotal.toFixed(2)}</span></p>
                        <p class="font-medium">Tax (10%): <span class="font-bold text-gray-800">$${tax.toFixed(2)}</span></p>
                        <p class="text-lg font-bold">Total: <span class="text-[#4B0082]">$${total.toFixed(2)}</span></p>
                        <button id="checkout-btn" class="mt-4 bg-[#4B0082] text-white px-6 py-2 rounded-lg font-semibold groovy-button">Checkout</button>
                    </div>`;

                if (!AppState.isLoggedInMember && AppData.cart.length > 0) {
                    summaryHtml += `<p class="mt-4 text-center text-sm text-gray-500">Already a member? <a href="#" id="login-from-cart" class="font-semibold text-[#8A2BE2] hover:underline">Log In</a> to purchase.</p>`
                }
                
                cartItemsContainer.innerHTML = itemsHtml + summaryHtml;
            };
            
            const renderAdmin = () => {
                document.querySelectorAll('.admin-tab').forEach(t => t.addEventListener('click', handleAdminTabClick));
                renderAdminTabContent();
            };

            const renderAdminTabContent = () => {
                const content = document.getElementById('admin-tab-content');
                content.innerHTML = '';
                if (AppState.currentAdminTab === 'members') content.innerHTML = renderAdminMembers();
                if (AppState.currentAdminTab === 'shop-items') content.innerHTML = renderAdminShopItems();
                if (AppState.currentAdminTab === 'hopper-sources') content.innerHTML = renderAdminHopperSources();
                if (AppState.currentAdminTab === 'hopper-items') content.innerHTML = renderAdminHopperItems();
                
                document.querySelectorAll('.admin-tab').forEach(t => {
                    t.classList.toggle('tab-active', t.dataset.tab === AppState.currentAdminTab);
                    t.classList.toggle('border-transparent', t.dataset.tab !== AppState.currentAdminTab);
                });
            };

            const renderAdminMembers = (searchTerm = '') => {
                const filteredMembers = AppData.members.filter(m => m.name.toLowerCase().includes(searchTerm.toLowerCase()) || m.email.toLowerCase().includes(searchTerm.toLowerCase()));
                return `<div class="bg-white p-6 rounded-xl shadow-lg">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-xl font-bold">Members</h3>
                            <div>
                                <button id="export-members-csv" class="bg-[#8A2BE2] text-white px-4 py-2 rounded-lg text-sm font-semibold groovy-button mr-4">Export CSV</button>
                                <input type="search" id="member-search" placeholder="Search members..." class="border rounded-lg px-4 py-2 text-sm w-64">
                            </div>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50"><tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Member Since</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                                </tr></thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    ${filteredMembers.map(member => `<tr>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">${member.name}</td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm">${member.email}</td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm">${dayjs(member.memberSince).format('MMM D, YYYY')}</td>
                                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium"><button class="view-member-details-btn text-[#8A2BE2] hover:text-[#4B0082]" data-id="${member.id}">View Details</button></td>
                                    </tr>`).join('')}
                                </tbody>
                            </table>
                        </div></div>`;
            };
            
            const renderAdminShopItems = () => {
                return `<div class="bg-white p-6 rounded-xl shadow-lg">
                        <div class="flex justify-between items-center mb-4"><h3 class="text-xl font-bold">Shop Inventory</h3><button class="add-shop-item-btn bg-[#8A2BE2] text-white px-4 py-2 rounded-lg text-sm font-semibold groovy-button">Add New Item</button></div>
                        <div class="space-y-3">
                            ${AppData.products.map(item => `<div class="p-3 border rounded-lg flex items-center space-x-4">
                                <img src="${item.image_url}" class="w-16 h-16 object-cover rounded-md">
                                <div class="flex-grow"><p class="font-semibold">${item.name}</p><p class="text-xs text-gray-500">${item.description}</p></div>
                                <p class="font-bold">$${item.price.toFixed(2)}</p>
                                <button class="edit-shop-item-btn text-sm font-semibold text-[#8A2BE2] groovy-button" data-id="${item.id}">Edit</button>
                            </div>`).join('')}
                        </div></div>`;
            };

            const renderAdminHopperSources = () => {
                return `<div class="bg-white p-6 rounded-xl shadow-lg">
                        <h3 class="text-xl font-bold mb-4">Hopper Sources</h3>
                        <ul class="space-y-3">
                            ${AppData.hopperSources.map(source => `<li class="p-3 border rounded-lg flex justify-between items-center">
                                <div><p class="font-semibold">${source.name}</p><a href="${source.url}" target="_blank" class="text-xs text-gray-500 hover:underline">${source.url}</a></div>
                                <button class="text-red-500 text-sm font-semibold groovy-button">Remove</button>
                            </li>`).join('')}
                        </ul>
                        <div class="mt-6 border-t pt-4"><input type="text" placeholder="Source Name" class="border rounded-lg px-4 py-2 w-full mb-2" /><input type="url" placeholder="https://..." class="border rounded-lg px-4 py-2 w-full mb-2" /><button class="bg-[#8A2BE2] text-white px-4 py-2 rounded-lg font-semibold w-full groovy-button">Add Source</button></div>
                    </div>`;
            };

            const renderAdminHopperItems = () => {
                 return `<div class="bg-white p-6 rounded-xl shadow-lg">
                        <h3 class="text-xl font-bold mb-4">Hopper Item Management</h3>
                        <div class="space-y-4">
                            ${AppData.hopperProducts.map(item => `<div class="p-3 border rounded-lg flex items-center space-x-4">
                                <img src="${item.image_url}" class="w-16 h-16 object-cover rounded-md">
                                <div class="flex-grow"><p class="font-semibold">${item.name}</p><p class="text-xs text-gray-500">${item.description}</p><p class="text-xs text-gray-500 mt-1">Source: ${AppData.hopperSources.find(s => s.id === item.sourceId)?.name || 'Unknown'}</p></div>
                                <div class="text-right"><p class="font-bold">$${(item.externalPrice * 1.5).toFixed(2)}</p><p class="text-xs text-gray-400">($${item.externalPrice.toFixed(2)})</p></div>
                                <div><button class="edit-hopper-item-btn text-sm font-semibold text-[#8A2BE2] groovy-button" data-id="${item.id}">Edit</button><button class="text-red-500 text-sm font-semibold ml-2 groovy-button">Remove</button></div>
                            </div>`).join('')}
                        </div></div>`;
            };

            const renderOrderHistoryChart = () => {
                const ctx = document.getElementById('order-history-chart');
                if (!ctx) return;

                const memberOrders = AppData.members.flatMap(m => m.orders);
                const plantIcons = { "Monstera Deliciosa": "🌿", "Snake Plant": "🐍", "Fiddle Leaf Fig": "🎻", "Red Prayer Plant": "🙏", "Annual Membership": "⭐" };
                const labels = memberOrders.map(o => dayjs(o.date).format('MMM D'));
                
                const allPurchasedItems = [...new Map(memberOrders.flatMap(o => o.items).map(item => [item.name, item])).values()];

                const datasets = allPurchasedItems.map((p, i) => {
                    return {
                        label: p.name,
                        data: memberOrders.map(o => {
                            const foundItem = o.items.find(item => item.name === p.name);
                            return foundItem ? foundItem.price : null;
                        }),
                        borderColor: `hsl(${i * 60}, 70%, 50%)`,
                        tension: 0.1,
                        pointStyle: (context) => {
                            const icon = plantIcons[context.dataset.label] || '🌱';
                            const canvas = document.createElement('canvas');
                            const c = canvas.getContext('2d');
                            canvas.width = 20; canvas.height = 20;
                            c.font = '16px sans-serif'; c.fillStyle = 'black'; c.textAlign = 'center'; c.textBaseline = 'middle';
                            c.fillText(icon, 10, 10);
                            return canvas;
                        },
                        pointRadius: 10,
                    }
                });

                new Chart(ctx, {
                    type: 'line', data: { labels, datasets },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        onClick: (e, elements) => {
                            if (elements.length > 0) {
                                const { datasetIndex, dataIndex } = elements[0];
                                const order = memberOrders[dataIndex];
                                if (order) {
                                    const item = order.items.find(i => i.name === datasets[datasetIndex].label);
                                    if(item) showModal('item-details', item.id);
                                }
                            }
                        },
                        plugins: {
                            tooltip: { callbacks: { title: (tooltipItems) => tooltipItems[0].dataset.label } },
                            legend: {
                                labels: {
                                    usePointStyle: true,
                                    generateLabels: (chart) => {
                                        return chart.data.datasets.map((dataset, i) => ({
                                            text: dataset.label,
                                            fillStyle: dataset.borderColor,
                                            strokeStyle: dataset.borderColor,
                                            pointStyle: dataset.pointStyle({dataset, datasetIndex: i})
                                        }));
                                    }
                                }
                            }
                        }
                    }
                });
            };

            const updateCartCount = () => { cartCountEl.textContent = AppData.cart.length; };

            const updateActiveNav = () => {
                document.querySelectorAll('.nav-link').forEach(link => {
                    link.classList.toggle('text-[#4B0082]', link.dataset.page === AppState.currentPage);
                    link.classList.toggle('font-bold', link.dataset.page === AppState.currentPage);
                });
                
                const authButtonContainer = document.getElementById('auth-button-container');
                if (authButtonContainer) authButtonContainer.remove();

                const newAuthContainer = document.createElement('div');
                newAuthContainer.id = 'auth-button-container';

                if (AppState.isLoggedInMember) {
                    newAuthContainer.innerHTML = `<button id="logout-btn" class="text-sm font-medium text-gray-500 hover:text-[#FF7F50] groovy-button">Log Out</button>`;
                } else {
                    newAuthContainer.innerHTML = `<button id="login-btn" class="text-sm font-medium text-gray-500 hover:text-[#8A2BE2] groovy-button">Log In</button>`;
                }
                navLinksContainer.appendChild(newAuthContainer);
                
                const adminLink = document.querySelector('[data-page="admin"]');
                if (adminLink) adminLink.style.display = AppState.isSuperUser ? 'block' : 'none';
                
                const mySeshLink = document.querySelector('[data-page="my-sesh"]');
                if (mySeshLink) mySeshLink.style.display = AppState.isLoggedInMember ? 'block' : 'none';
            };

            const handleNavClick = (e) => {
                e.preventDefault();
                const page = e.target.closest('.nav-link')?.dataset.page;
                if (page) { AppState.currentPage = page; renderPage(); }
            };

            const handleAdminTabClick = (e) => {
                const tab = e.target.dataset.tab;
                if (tab) { AppState.currentAdminTab = tab; renderAdminTabContent(); }
            };
            
            const handleMainContentClick = (e) => {
                if (e.target.id === 'add-membership-btn') {
                    if (AppState.isLoggedInMember) { alert("You are already a member."); return; }
                    if (AppData.cart.some(item => item.isMembership)) { alert("Membership is already in your cart."); AppState.currentPage = 'cart'; renderPage(); } 
                    else { showModal('new-member-form'); }
                }

                if (e.target.classList.contains('add-to-cart-btn')) {
                    const productId = parseInt(e.target.dataset.id, 10);
                    const isHopper = e.target.dataset.hopper === 'true';
                    let productToAdd;
                    if (isHopper) {
                        const p = AppData.hopperProducts.find(p => p.id === productId);
                        if (p) productToAdd = { ...p, price: p.externalPrice * 1.50 };
                    } else { productToAdd = AppData.products.find(p => p.id === productId); }
                    if (productToAdd) { AppData.cart.push(productToAdd); updateCartCount(); }
                }

                if (e.target.classList.contains('remove-from-cart-btn')) {
                    const itemIndex = parseInt(e.target.dataset.index, 10);
                    AppData.cart.splice(itemIndex, 1);
                    renderCart(); updateCartCount();
                }

                if (e.target.id === 'checkout-btn') {
                    if (!AppData.cart.some(item => item.isMembership) && !AppState.isLoggedInMember) {
                        alert("A membership is required to check out.");
                        AppState.currentPage = 'membership'; renderPage(); return;
                    }
                    showModal('zenobia-pay');
                }

                if (e.target.id === 'member-search') {
                    e.target.addEventListener('input', (event) => {
                        document.getElementById('admin-tab-content').innerHTML = renderAdminMembers(event.target.value);
                    });
                }
                
                if (e.target.classList.contains('view-member-details-btn')) {
                    const memberId = parseInt(e.target.dataset.id, 10);
                    showModal('member-details', memberId);
                }

                if (e.target.classList.contains('add-shop-item-btn')) {
                    showModal('shop-item-form');
                }
                if (e.target.classList.contains('edit-shop-item-btn')) {
                    const itemId = parseInt(e.target.dataset.id, 10);
                    showModal('shop-item-form', itemId);
                }
                
                if (e.target.id === 'export-members-csv') {
                    exportToCSV(AppData.members, 'members.csv');
                }
                if (e.target.id === 'export-orders-csv') {
                    const memberId = parseInt(e.target.dataset.id, 10);
                    const member = AppData.members.find(m => m.id === memberId);
                    if (member) exportToCSV(member.orders, `member_${memberId}_orders.csv`);
                }
                 if (e.target.id === 'login-from-membership' || e.target.id === 'login-from-cart') {
                    e.preventDefault();
                    showModal('login-form');
                }
            };

            const showModal = (type, id) => {
                const content = document.getElementById('modal-content');
                let modalHtml = '';
                
                if (type === 'login-form') {
                    modalHtml = `<form id="login-form">
                        <div class="flex justify-between items-start"><h3 class="text-2xl font-bold text-[#4B0082]">Member Login</h3><button type="button" class="close-modal-btn font-bold text-2xl text-gray-400 hover:text-gray-600">&times;</button></div>
                        <div class="mt-4 space-y-4">
                            <div><label class="block text-sm font-medium">Email</label><input name="email" type="email" required class="mt-1 block w-full border border-gray-300 rounded-md p-2" placeholder="member@example.com or admin@haven.com"></div>
                            <div><label class="block text-sm font-medium">Password</label><input name="password" type="password" required class="mt-1 block w-full border border-gray-300 rounded-md p-2"></div>
                        </div>
                        <div class="mt-6 text-right"><button type="submit" class="bg-[#4B0082] text-white px-6 py-2 rounded-lg font-semibold groovy-button">Log In</button></div>
                    </form>`;
                } else if (type === 'new-member-form') {
                    modalHtml = `<form id="new-member-form">
                        <h4 class="font-semibold text-center mb-4 text-xl">Create Your Membership Account</h4>
                        <div><label for="name" class="block text-sm font-medium text-gray-700">Full Name</label><input type="text" id="name" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3"></div>
                        <div class="mt-4"><label for="email" class="block text-sm font-medium text-gray-700">Email Address</label><input type="email" id="email" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3"></div>
                        <div class="mt-4"><label for="phone" class="block text-sm font-medium text-gray-700">Phone Number</label><input type="tel" id="phone" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3"><p class="text-xs text-gray-400 mt-1">most secure option</p></div>
                        <div class="mt-4"><label for="birthday" class="block text-sm font-medium text-gray-700">Birthday</label><input type="date" id="birthday" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3"></div>
                        <div class="mt-4"><label for="picture" class="block text-sm font-medium text-gray-700">Profile Picture</label><input type="file" id="picture" required class="mt-1 block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-purple-50 file:text-purple-700 hover:file:bg-purple-100"></div>
                        <div class="mt-6"><button type="submit" class="bg-[#4B0082] text-white px-6 py-2 rounded-lg font-semibold w-full groovy-button">Continue to Payment</button></div>
                    </form>`;
                } else if (type === 'zenobia-pay') {
                    const total = AppData.cart.reduce((sum, item) => sum + item.price, 0) * (1 + (AppData.cart.some(i => !i.isMembership) ? AppState.TAX_RATE : 0));
                    modalHtml = `<div class="text-center"><h3 class="text-2xl font-bold text-[#4B0082]">Zenobia Pay</h3><p class="text-gray-500 text-sm mt-1">Secure Payment</p></div>
                                 <div class="mt-6"><p class="text-center">You are about to purchase ${AppData.cart.length} item(s) for a total of <strong class="text-lg">$${total.toFixed(2)}</strong>.</p>
                                 <div class="mt-6 space-y-3">
                                    <button class="confirm-payment-btn bg-[#4B0082] text-white px-6 py-2 rounded-lg font-semibold w-full groovy-button" data-method="Zenobia Pay">Confirm with Zenobia Pay</button>
                                    <button class="confirm-payment-btn bg-[#003087] text-white px-6 py-2 rounded-lg font-semibold w-full groovy-button" data-method="PayPal">Confirm with PayPal</button>
                                 </div></div>`;
                } else if (type === 'member-details') {
                    const member = AppData.members.find(m => m.id === id);
                    if (!member) return;
                    modalHtml = `
                        <div class="flex justify-between items-start">
                           <div>
                               <h3 class="text-2xl font-bold text-[#4B0082]">${member.name}</h3>
                               <p class="text-gray-500 text-sm mt-1">${member.email} | ${member.phone}</p>
                               <p class="text-gray-500 text-sm">Member Since: ${dayjs(member.memberSince).format('MMM D, YYYY')}</p>
                           </div>
                           <button class="close-modal-btn font-bold text-2xl text-gray-400 hover:text-gray-600">&times;</button>
                        </div>
                        <div class="flex justify-between items-center mt-6 mb-2">
                           <h4 class="text-lg font-bold">Order History</h4>
                           <button id="export-orders-csv" data-id="${member.id}" class="bg-[#8A2BE2] text-white px-3 py-1 rounded-md text-xs font-semibold groovy-button">Export CSV</button>
                        </div>
                        <div class="overflow-x-auto border rounded-lg">
                           <table class="min-w-full divide-y divide-gray-200">
                              <thead class="bg-gray-50"><tr>
                                 <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Order ID</th>
                                 <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                                 <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Items</th>
                                 <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Payment Method</th>
                                 <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
                              </tr></thead>
                              <tbody class="bg-white divide-y divide-gray-200">
                                 ${member.orders.map(o => `<tr>
                                    <td class="px-4 py-2 text-sm">${o.orderId}</td>
                                    <td class="px-4 py-2 text-sm">${dayjs(o.date).format('MMM D, YYYY')}</td>
                                    <td class="px-4 py-2 text-sm">${o.items.map(i => i.name).join(', ')}</td>
                                    <td class="px-4 py-2 text-sm">${o.paymentMethod}</td>
                                    <td class="px-4 py-2 text-sm font-semibold">$${o.total.toFixed(2)}</td>
                                 </tr>`).join('')}
                              </tbody>
                           </table>
                        </div>`;
                } else if (type === 'add-shop-item' || type === 'edit-shop-item') {
                    const item = type === 'edit-shop-item' ? AppData.products.find(p => p.id === id) : {};
                    modalHtml = `<form id="shop-item-form" data-id="${id || ''}">
                        <div class="flex justify-between items-start"><h3 class="text-2xl font-bold text-[#4B0082]">${type === 'add-shop-item' ? 'Add New Shop Item' : 'Edit Shop Item'}</h3><button type="button" class="close-modal-btn font-bold text-2xl text-gray-400 hover:text-gray-600">&times;</button></div>
                        <div class="mt-4 space-y-4">
                            <div><label class="block text-sm font-medium">Name</label><input name="name" type="text" value="${item.name || ''}" required class="mt-1 block w-full border border-gray-300 rounded-md p-2"></div>
                            <div><label class="block text-sm font-medium">Price</label><input name="price" type="number" step="0.01" value="${item.price || ''}" required class="mt-1 block w-full border border-gray-300 rounded-md p-2"></div>
                            <div><label class="block text-sm font-medium">Description</label><textarea name="description" class="mt-1 block w-full border border-gray-300 rounded-md p-2">${item.description || ''}</textarea></div>
                            <div><label class="block text-sm font-medium">Image URL</label><input name="image_url" type="url" value="${item.image_url || ''}" class="mt-1 block w-full border border-gray-300 rounded-md p-2"></div>
                            <div class="flex items-center"><input name="isActive" type="checkbox" ${item.isActive ? 'checked' : ''} class="h-4 w-4 rounded"><label class="ml-2 text-sm">Active</label></div>
                            <div class="flex items-center"><input name="isTrackable" type="checkbox" ${item.isTrackable ? 'checked' : ''} class="h-4 w-4 rounded"><label class="ml-2 text-sm">Trackable in My Sesh</label></div>
                        </div>
                        <div class="mt-6 text-right"><button type="submit" class="bg-[#4B0082] text-white px-6 py-2 rounded-lg font-semibold groovy-button">Save Item</button></div>
                    </form>`;
                } else if (type === 'item-details') {
                    const allProducts = [...AppData.products, ...AppData.hopperProducts.map(p => ({...p, price: p.externalPrice * 1.5}))];
                    const item = allProducts.find(p => p.id === id);
                    if (!item) return;
                    modalHtml = `<div class="flex justify-between items-start"><h3 class="text-2xl font-bold text-[#4B0082]">${item.name}</h3><button type="button" class="close-modal-btn font-bold text-2xl text-gray-400 hover:text-gray-600">&times;</button></div>
                                 <img src="${item.image_url}" class="w-full h-48 object-cover rounded-lg mt-4">
                                 <p class="mt-4 text-gray-600">${item.description}</p>`;
                }
                content.innerHTML = modalHtml;
                modal.classList.remove('opacity-0', 'pointer-events-none');
                modal.querySelector('.modal-content').classList.remove('scale-95');
            };

            const hideModal = () => {
                modal.classList.add('opacity-0', 'pointer-events-none');
                modal.querySelector('.modal-content').classList.add('scale-95');
            };

            const exportToCSV = (data, filename) => {
                if (!data || data.length === 0) return;
                const headers = Object.keys(data[0]);
                const csvRows = [headers.join(',')];
                data.forEach(row => {
                    const values = headers.map(header => {
                        let val = row[header];
                        if (typeof val === 'object' && val !== null) {
                            val = JSON.stringify(val).replace(/"/g, '""');
                        }
                        return `"${val}"`;
                    });
                    csvRows.push(values.join(','));
                });
                const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.setAttribute('hidden', '');
                a.setAttribute('href', url);
                a.setAttribute('download', filename);
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
            };

            document.addEventListener('click', (e) => {
                if (e.target.classList.contains('confirm-payment-btn')) {
                    const paymentMethod = e.target.dataset.method;
                    const content = document.getElementById('modal-content');
                    content.innerHTML = `<p class="text-center font-semibold">Processing payment via ${paymentMethod}...</p>`;
                    setTimeout(() => {
                        const total = AppData.cart.reduce((sum, item) => sum + item.price, 0) * (1 + (AppData.cart.some(i => !i.isMembership) ? AppState.TAX_RATE : 0));
                        const newOrder = { orderId: `ORD-00${AppData.members.reduce((max, m) => m.orders.length, 0) + 4}`, date: dayjs().format('YYYY-MM-DD'), total: total, items: [...AppData.cart], paymentMethod: paymentMethod };

                        if (AppState.newMemberInfo) {
                            const newMember = {
                                id: AppData.members.length + 1,
                                name: AppState.newMemberInfo.name, email: AppState.newMemberInfo.email, phone: AppState.newMemberInfo.phone,
                                memberSince: dayjs().format('YYYY-MM-DD'), orders: [newOrder]
                            };
                            AppData.members.push(newMember);
                            newOrder.items.filter(i => i.isTrackable).forEach(i => AppData.myPlants.push({...i, purchaseDate: dayjs().format('YYYY-MM-DD')}));
                            AppState.newMemberInfo = null;
                            AppState.isLoggedInMember = true;
                        } else {
                           console.log("New order for existing member:", newOrder);
                           // In a real app, find the logged-in user and add the order to their history
                        }

                        content.innerHTML = `<div class="text-center"><p class="text-xl font-bold text-green-600">Payment Successful!</p><p class="text-sm text-gray-500 mt-2">Thank you for your order.</p></div>`;
                        setTimeout(() => {
                            hideModal();
                            AppData.cart = []; updateCartCount();
                            AppState.currentPage = 'my-sesh'; renderPage();
                        }, 2000);
                    }, 1500);
                }
                if (e.target.classList.contains('close-modal-btn') || e.target === modal) { hideModal(); }
                if (e.target.id === 'logout-btn') {
                    AppState.isLoggedInMember = false;
                    AppState.isSuperUser = false;
                    alert('You have been logged out.');
                    updateActiveNav();
                }
                 if (e.target.id === 'login-btn') {
                    showModal('login-form');
                }
            });

            document.addEventListener('submit', (e) => {
                if (e.target.id === 'new-member-form') {
                    e.preventDefault();
                    AppState.newMemberInfo = { name: e.target.elements.name.value, email: e.target.elements.email.value, phone: e.target.elements.phone.value };
                    AppData.cart.unshift(AppData.MEMBERSHIP_FEE);
                    updateCartCount();
                    showModal('zenobia-pay');
                }
                if (e.target.id === 'login-form') {
                    e.preventDefault();
                    const email = e.target.elements.email.value;
                    if (email.toLowerCase() === 'admin@haven.com') {
                        AppState.isSuperUser = true;
                        AppState.isLoggedInMember = true;
                        alert('Admin logged in successfully!');
                    } else if (AppData.members.find(m => m.email === email)) {
                        AppState.isSuperUser = false;
                        AppState.isLoggedInMember = true;
                         alert('Member logged in successfully!');
                    } else {
                        alert('No member found with that email address.');
                        return;
                    }
                    hideModal();
                    updateActiveNav();
                }
                if (e.target.id === 'shop-item-form') {
                    e.preventDefault();
                    const form = e.target;
                    const id = form.dataset.id ? parseInt(form.dataset.id, 10) : null;
                    const updatedItem = {
                        id: id || Date.now(),
                        name: form.elements.name.value,
                        price: parseFloat(form.elements.price.value),
                        description: form.elements.description.value,
                        image_url: form.elements.image_url.value,
                        isActive: form.elements.isActive.checked,
                        isTrackable: form.elements.isTrackable.checked,
                    };
                    if (id) {
                        const index = AppData.products.findIndex(p => p.id === id);
                        AppData.products[index] = { ...AppData.products[index], ...updatedItem };
                    } else {
                        AppData.products.push(updatedItem);
                    }
                    hideModal();
                    renderAdminTabContent();
                }
            });
            
            document.querySelector('header').addEventListener('click', handleNavClick);
            mainContent.addEventListener('click', handleMainContentClick);
            renderPage();
        });
    </script>
</body>
</html>
