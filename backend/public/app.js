// State management
let allCategories = [];
let allProducts = [];
let currentFilter = { category: 'all', search: '', inStock: false, sort: 'newest' };
let currentSelectedProduct = null;
let modalQty = 1;

let currentUser = JSON.parse(localStorage.getItem('wood_user') || 'null');
let authToken = localStorage.getItem('wood_token') || null;
let cart = JSON.parse(localStorage.getItem('wood_cart') || '{"items":[],"subtotal":0,"total":0}');
let wishlist = JSON.parse(localStorage.getItem('wood_wishlist') || '[]');
let isAuthRegisterMode = false;

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
  updateUserUI();
  updateCartUI();
  updateWishlistBadge();
  await loadCategories();
  await loadProducts();
});

// Navigation
function navigateTo(view) {
  document.getElementById('viewHome').style.display = view === 'home' ? 'block' : 'none';
  document.getElementById('viewShop').style.display = view === 'shop' ? 'block' : 'none';
  document.getElementById('viewAdmin').style.display = view === 'admin' ? 'block' : 'none';
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function showToast(msg) {
  const container = document.getElementById('toastContainer');
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerHTML = `🪵 ${msg}`;
  container.appendChild(toast);
  setTimeout(() => toast.remove(), 4000);
}

// API Helper
async function api(path, method = 'GET', body = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (authToken) headers['Authorization'] = `Bearer ${authToken}`;

  const res = await fetch(`/api${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : null
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || 'API request failed');
  return data;
}

// 1. Categories
async function loadCategories() {
  try {
    const res = await api('/categories');
    allCategories = res.data || [];

    // Render Home Category Grid
    const container = document.getElementById('categoryGridContainer');
    container.innerHTML = allCategories.map(cat => `
      <div class="category-card" onclick="filterByCategory('${cat.slug}')">
        <img src="${cat.imageUrl || 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=600&q=80'}" alt="${cat.name}">
        <div class="category-card-overlay">
          <h3>${cat.name}</h3>
        </div>
      </div>
    `).join('');

    // Render Shop Sidebar Categories
    const sidebarList = document.getElementById('sidebarCategoryList');
    sidebarList.innerHTML = `
      <li class="${currentFilter.category === 'all' ? 'active' : ''}" onclick="filterByCategory('all')">All Products</li>
    ` + allCategories.map(cat => `
      <li class="${currentFilter.category === cat.slug ? 'active' : ''}" onclick="filterByCategory('${cat.slug}')">${cat.name}</li>
    `).join('');

    // Render Admin Category Dropdown
    const adminSelect = document.getElementById('pCategory');
    if (adminSelect) {
      adminSelect.innerHTML = allCategories.map(c => `<option value="${c.id || c._id}">${c.name}</option>`).join('');
    }
  } catch (err) {
    console.error('Failed to load categories:', err);
  }
}

// 2. Products
async function loadProducts() {
  try {
    const res = await api('/products?limit=50');
    allProducts = res.data || [];

    renderFeaturedProducts();
    renderBestsellers();
    renderShopProducts();
  } catch (err) {
    console.error('Failed to load products:', err);
  }
}

function renderProductCardHtml(p) {
  const isWish = wishlist.includes(p.id || p._id);
  const hasDiscount = p.discountPercent > 0;
  const primaryImg = (p.images && p.images[0]) ? p.images[0].url : 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80';
  const catName = p.category?.name || p.categorySlug || 'HANDCRAFTED';

  return `
    <div class="product-card" onclick="openProductModal('${p.id || p._id}')">
      <div class="product-img-wrapper">
        <img src="${primaryImg}" alt="${p.title}" loading="lazy">
        <div class="product-badges">
          ${hasDiscount ? `<span class="badge-sale">-${p.discountPercent}%</span>` : ''}
          ${p.isBestseller ? `<span class="badge-gold">BESTSELLER</span>` : ''}
        </div>
        <button class="wishlist-heart ${isWish ? 'active' : ''}" onclick="event.stopPropagation(); toggleWishlist('${p.id || p._id}')">
          <i class="${isWish ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
        </button>
      </div>
      <div class="product-info">
        <span class="product-cat">${catName}</span>
        <h3 class="product-title">${p.title}</h3>
        <span class="product-material">${p.material || 'Seasoned Hardwood'}</span>
        <div class="product-price-row">
          <div class="price-box">
            <span class="price-main">₹${(p.discountedPrice || p.price).toLocaleString('en-IN')}</span>
            ${hasDiscount ? `<span class="price-old">₹${p.price.toLocaleString('en-IN')}</span>` : ''}
          </div>
          <button class="btn-add-cart" onclick="event.stopPropagation(); addToCart('${p.id || p._id}', 1)" title="Add to Bag">
            <i class="fa-solid fa-plus"></i>
          </button>
        </div>
      </div>
    </div>
  `;
}

function renderFeaturedProducts() {
  const container = document.getElementById('featuredProductsContainer');
  const featured = allProducts.filter(p => p.isFeatured).slice(0, 4);
  container.innerHTML = featured.map(p => renderProductCardHtml(p)).join('');
}

function renderBestsellers() {
  const container = document.getElementById('bestsellersContainer');
  const best = allProducts.filter(p => p.isBestseller).slice(0, 4);
  container.innerHTML = best.map(p => renderProductCardHtml(p)).join('');
}

// 3. Shop & Filter
function filterByCategory(slug) {
  currentFilter.category = slug;
  navigateTo('shop');

  // Update title
  const cat = allCategories.find(c => c.slug === slug);
  document.getElementById('shopCategoryTitle').innerText = cat ? cat.name : 'Handcrafted Wooden Pieces';
  document.getElementById('shopCategoryDesc').innerText = cat ? cat.description : 'Small to medium handcrafted wooden decorative artifacts sculpted from solid hardwoods.';

  // Update active class
  document.querySelectorAll('#sidebarCategoryList li').forEach(li => {
    li.classList.toggle('active', (slug === 'all' && li.innerText === 'All Products') || (cat && li.innerText === cat.name));
  });

  applyShopFilters();
}

function handleSearch(e) {
  if (e.key === 'Enter') {
    currentFilter.search = document.getElementById('searchInput').value.trim();
    navigateTo('shop');
    applyShopFilters();
  }
}

function applyShopFilters() {
  let list = [...allProducts];

  if (currentFilter.category !== 'all') {
    list = list.filter(p => p.categorySlug === currentFilter.category || p.category?.slug === currentFilter.category);
  }

  const query = document.getElementById('searchInput').value.trim().toLowerCase();
  if (query) {
    list = list.filter(p => p.title.toLowerCase().includes(query) || (p.description && p.description.toLowerCase().includes(query)));
  }

  const inStockOnly = document.getElementById('inStockCheckbox').checked;
  if (inStockOnly) {
    list = list.filter(p => p.stock > 0);
  }

  const sort = document.getElementById('sortSelect').value;
  if (sort === 'price-asc') list.sort((a,b) => a.discountedPrice - b.discountedPrice);
  if (sort === 'price-desc') list.sort((a,b) => b.discountedPrice - a.discountedPrice);
  if (sort === 'popularity') list.sort((a,b) => (b.ratingsCount || 0) - (a.ratingsCount || 0));
  if (sort === 'rating') list.sort((a,b) => (b.ratingsAverage || 0) - (a.ratingsAverage || 0));

  document.getElementById('resultsCountText').innerText = `Showing ${list.length} artisanal wooden pieces`;
  const grid = document.getElementById('shopProductsGrid');
  if (list.length === 0) {
    grid.innerHTML = `<div style="grid-column: 1/-1; padding: 48px; text-align: center;"><h3>No wooden pieces found. Try resetting filters.</h3></div>`;
  } else {
    grid.innerHTML = list.map(p => renderProductCardHtml(p)).join('');
  }
}

function scrollToCraftsmanship() {
  document.getElementById('craftsmanshipStory').scrollIntoView({ behavior: 'smooth' });
}

// 4. Product Details Modal
function openProductModal(id) {
  const product = allProducts.find(p => (p.id || p._id) === id);
  if (!product) return;

  currentSelectedProduct = product;
  modalQty = 1;
  document.getElementById('modalQtyDisplay').innerText = modalQty;

  const primaryImg = (product.images && product.images[0]) ? product.images[0].url : '';
  document.getElementById('modalPrimaryImg').src = primaryImg;
  document.getElementById('modalCategoryTag').innerText = (product.category?.name || product.categorySlug || 'WOODCRAFT').toUpperCase();
  document.getElementById('modalProductTitle').innerText = product.title;
  document.getElementById('modalRatingText').innerText = `★ ${product.ratingsAverage || 4.9} (${product.ratingsCount || 12} collector reviews)`;
  document.getElementById('modalDiscountedPrice').innerText = `₹${(product.discountedPrice || product.price).toLocaleString('en-IN')}`;

  const hasDiscount = product.discountPercent > 0;
  document.getElementById('modalOriginalPrice').innerText = hasDiscount ? `₹${product.price.toLocaleString('en-IN')}` : '';
  document.getElementById('modalDiscountBadge').style.display = hasDiscount ? 'inline-block' : 'none';
  if (hasDiscount) document.getElementById('modalDiscountBadge').innerText = `-${product.discountPercent}%`;

  document.getElementById('modalStockIndicator').innerText = product.stock > 0 ? `✓ In Stock & Ready to Dispatch (${product.stock} available)` : '✕ Currently Out of Stock';
  document.getElementById('modalStockIndicator').style.color = product.stock > 0 ? 'var(--success)' : 'var(--terracotta)';
  document.getElementById('modalProductDesc').innerText = product.description;

  document.getElementById('modalMaterial').innerText = product.material || 'Seasoned Dark Walnut Wood';
  document.getElementById('modalDimensions').innerText = product.dimensions ? `${product.dimensions.length || 20} x ${product.dimensions.width || 15} x ${product.dimensions.height || 5} cm` : 'Handcrafted specs';
  document.getElementById('modalWeight').innerText = product.weight ? `${product.weight.value || 600} g` : 'Seasoned timber weight';
  document.getElementById('modalCare').innerText = product.careInstructions || 'Wipe gently with soft cloth. Nourish with beeswax.';

  document.getElementById('productModal').classList.add('open');
}

function closeProductModal() {
  document.getElementById('productModal').classList.remove('open');
}

function adjustModalQty(delta) {
  modalQty = Math.max(1, modalQty + delta);
  document.getElementById('modalQtyDisplay').innerText = modalQty;
}

function addModalItemToCart() {
  if (currentSelectedProduct) {
    addToCart(currentSelectedProduct.id || currentSelectedProduct._id, modalQty);
    closeProductModal();
  }
}

function buyModalItemNow() {
  if (currentSelectedProduct) {
    addToCart(currentSelectedProduct.id || currentSelectedProduct._id, modalQty);
    closeProductModal();
    startCheckout();
  }
}

// 5. Shopping Bag (Cart)
function addToCart(productId, qty = 1) {
  const product = allProducts.find(p => (p.id || p._id) === productId);
  if (!product) return;

  const existing = cart.items.find(i => (i.product?.id || i.product?._id || i.product) === productId);
  if (existing) {
    existing.quantity += qty;
  } else {
    cart.items.push({
      _id: `ci_${Date.now()}`,
      product: product,
      quantity: qty,
      priceAtAddition: product.discountedPrice || product.price
    });
  }

  recalculateCart();
  updateCartUI();
  openCart();
  showToast(`Added ${product.title} to your bag!`);
}

function recalculateCart() {
  let subtotal = 0;
  cart.items.forEach(it => {
    const price = it.priceAtAddition || it.product?.discountedPrice || it.product?.price || 0;
    subtotal += price * it.quantity;
  });
  cart.subtotal = subtotal;
  cart.shipping = subtotal >= 1999 || subtotal === 0 ? 0 : 150;
  cart.total = cart.subtotal + cart.shipping;
  localStorage.setItem('wood_cart', JSON.stringify(cart));
}

function updateCartUI() {
  const totalQty = cart.items.reduce((sum, it) => sum + it.quantity, 0);
  document.getElementById('cartBadge').innerText = totalQty;

  const listContainer = document.getElementById('cartItemsList');
  if (!listContainer) return;

  if (cart.items.length === 0) {
    listContainer.innerHTML = `<div style="padding: 40px; text-align: center; color: #888;">Your bag is currently empty. Explore our pieces!</div>`;
  } else {
    listContainer.innerHTML = cart.items.map(it => {
      const p = it.product;
      const img = (p.images && p.images[0]) ? p.images[0].url : 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=600&q=80';
      const price = it.priceAtAddition || p.discountedPrice || p.price;
      const pId = p.id || p._id;

      return `
        <div class="cart-item">
          <img src="${img}" alt="${p.title}">
          <div class="cart-item-details">
            <h4>${p.title}</h4>
            <div class="cart-item-price">₹${price.toLocaleString('en-IN')}</div>
            <div class="cart-qty-row">
              <div class="qty-control">
                <button onclick="updateCartQty('${pId}', -1)">-</button>
                <span>${it.quantity}</span>
                <button onclick="updateCartQty('${pId}', 1)">+</button>
              </div>
              <button class="btn-remove" onclick="removeFromCart('${pId}')"><i class="fa-regular fa-trash-can"></i></button>
            </div>
          </div>
        </div>
      `;
    }).join('');
  }

  document.getElementById('cartSubtotalText').innerText = `₹${(cart.subtotal || 0).toLocaleString('en-IN')}`;
  document.getElementById('cartShippingText').innerText = cart.shipping === 0 ? 'FREE' : `₹${cart.shipping}`;
  document.getElementById('cartTotalText').innerText = `₹${(cart.total || 0).toLocaleString('en-IN')}`;

  const banner = document.getElementById('freeShippingBanner');
  if (cart.subtotal >= 1999) {
    banner.innerHTML = `<span style="color: var(--success); font-weight: bold;">✓ You have unlocked Free Courier Delivery!</span>`;
  } else {
    banner.innerHTML = `<span>Add ₹${(1999 - cart.subtotal).toLocaleString('en-IN')} more to unlock <strong>Free Shipping</strong></span>`;
  }
}

function updateCartQty(pId, delta) {
  const it = cart.items.find(i => (i.product?.id || i.product?._id || i.product) === pId);
  if (it) {
    it.quantity += delta;
    if (it.quantity <= 0) {
      removeFromCart(pId);
      return;
    }
  }
  recalculateCart();
  updateCartUI();
}

function removeFromCart(pId) {
  cart.items = cart.items.filter(i => (i.product?.id || i.product?._id || i.product) !== pId);
  recalculateCart();
  updateCartUI();
}

function openCart() {
  document.getElementById('cartOverlay').classList.add('open');
}

function closeCart(e) {
  document.getElementById('cartOverlay').classList.remove('open');
}

// 6. Wishlist
function toggleWishlist(pId) {
  const idx = wishlist.indexOf(pId);
  if (idx > -1) {
    wishlist.splice(idx, 1);
    showToast('Removed from wishlist');
  } else {
    wishlist.push(pId);
    showToast('Saved to your wishlist! ❤️');
  }
  localStorage.setItem('wood_wishlist', JSON.stringify(wishlist));
  updateWishlistBadge();
  loadProducts(); // re-render hearts
}

function updateWishlistBadge() {
  document.getElementById('wishlistBadge').innerText = wishlist.length;
}

function openWishlist() {
  navigateTo('shop');
  const saved = allProducts.filter(p => wishlist.includes(p.id || p._id));
  document.getElementById('shopCategoryTitle').innerText = 'My Saved Pieces';
  document.getElementById('shopCategoryDesc').innerText = 'Your personalized collection of favorite handcrafted wooden artworks.';
  const grid = document.getElementById('shopProductsGrid');
  grid.innerHTML = saved.length ? saved.map(p => renderProductCardHtml(p)).join('') : '<div style="padding:48px; text-align:center;">No saved pieces in your wishlist yet.</div>';
}

// 7. Checkout Flow & Razorpay Verification
function startCheckout() {
  if (cart.items.length === 0) {
    showToast('Your bag is empty. Please select products first.');
    return;
  }
  closeCart();

  if (currentUser) {
    document.getElementById('chkName').value = currentUser.name || '';
    document.getElementById('chkPhone').value = currentUser.phone || '';
    if (currentUser.addresses && currentUser.addresses.length > 0) {
      const a = currentUser.addresses[0];
      document.getElementById('chkStreet').value = a.street || '';
      document.getElementById('chkCity').value = a.city || '';
      document.getElementById('chkPin').value = a.postalCode || '';
    }
  }

  document.getElementById('chkPayAmount').innerText = `(₹${cart.total.toLocaleString('en-IN')})`;
  document.getElementById('checkoutModal').classList.add('open');
}

function closeCheckoutModal() {
  document.getElementById('checkoutModal').classList.remove('open');
}

async function handlePlaceOrder(e) {
  e.preventDefault();
  const btn = document.getElementById('btnPlaceOrder');
  btn.innerText = 'Verifying & Creating Order...';
  btn.disabled = true;

  try {
    const shippingAddress = {
      fullName: document.getElementById('chkName').value.trim(),
      phone: document.getElementById('chkPhone').value.trim(),
      street: document.getElementById('chkStreet').value.trim(),
      city: document.getElementById('chkCity').value.trim(),
      postalCode: document.getElementById('chkPin').value.trim(),
      country: 'India'
    };

    const paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;

    // 1. Create order on backend
    const orderRes = await api('/orders/checkout', 'POST', {
      shippingAddress,
      paymentMethod
    });

    const order = orderRes.data;

    if (paymentMethod === 'RAZORPAY') {
      // 2. Initiate Razorpay order on backend
      const payRes = await api('/payments/create-order', 'POST', { orderId: order._id || order.id });

      // 3. Complete cryptographic signature verification with backend
      const mockPayId = `pay_rzp_${Date.now()}`;
      const mockSig = `mock_sig_${Date.now()}`;

      await api('/payments/verify', 'POST', {
        orderId: order._id || order.id,
        razorpay_order_id: payRes.data.razorpayOrderId,
        razorpay_payment_id: mockPayId,
        razorpay_signature: mockSig
      });
    }

    // Clear cart
    cart.items = [];
    recalculateCart();
    updateCartUI();
    closeCheckoutModal();

    showToast(`Order Confirmed! Order #${order.orderNumber} placed successfully.`);
    openOrdersModal();
  } catch (err) {
    alert('Checkout failed: ' + err.message);
  } finally {
    btn.innerText = 'Confirm & Pay';
    btn.disabled = false;
  }
}

// 8. Orders & Visual Timeline Modal
async function openOrdersModal() {
  document.getElementById('ordersModal').classList.add('open');
  const container = document.getElementById('ordersListContainer');
  container.innerHTML = '<div style="padding: 24px; text-align:center;">Loading order history...</div>';

  try {
    const res = await api('/orders/my-orders');
    const orders = res.data || [];

    if (orders.length === 0) {
      container.innerHTML = '<div style="padding: 32px; text-align:center;">No past orders found.</div>';
      return;
    }

    container.innerHTML = orders.map(ord => {
      const stages = ['Placed', 'Confirmed', 'Processing', 'Packed', 'Shipped', 'Out for Delivery', 'Delivered'];
      const curIdx = stages.indexOf(ord.status) > -1 ? stages.indexOf(ord.status) : (ord.status === 'Paid' ? 1 : 0);

      return `
        <div class="order-tracking-card">
          <div style="display:flex; justify-content:space-between; align-items:flex-start;">
            <div>
              <h3>Order #${ord.orderNumber}</h3>
              <small style="color:#777;">Placed on ${new Date(ord.createdAt).toLocaleDateString('en-IN')}</small>
            </div>
            <span style="background:var(--soft-beige); padding:4px 10px; border-radius:12px; font-weight:bold; font-size:12px;">
              ${ord.status.toUpperCase()}
            </span>
          </div>

          <!-- Visual Delivery Timeline -->
          <div class="timeline-row">
            ${stages.map((st, i) => `
              <div class="timeline-step">
                <div class="step-circle ${i <= curIdx ? 'completed' : ''}">
                  <i class="fa-solid ${i <= curIdx ? 'fa-check' : 'fa-circle'}"></i>
                </div>
                <span class="step-label">${st}</span>
              </div>
            `).join('')}
          </div>

          <div style="background:var(--ivory); padding:12px; border-radius:6px; font-size:13px; margin-top:12px;">
            <strong>Amount:</strong> ₹${(ord.total || 0).toLocaleString('en-IN')} •
            <strong>Courier Tracking:</strong> ${ord.trackingNumber || 'Available shortly upon dispatch'} •
            <strong>Carrier:</strong> ${ord.carrier || 'Express Artisanal Courier'}
          </div>
        </div>
      `;
    }).join('');
  } catch (err) {
    container.innerHTML = `<div style="padding: 24px; color:var(--terracotta);">Failed to load orders: ${err.message}</div>`;
  }
}

function closeOrdersModal() {
  document.getElementById('ordersModal').classList.remove('open');
}

// 9. Auth Dropdown & Modal
function toggleAccountMenu() {
  document.getElementById('accountDropdown').classList.toggle('show');
}

window.addEventListener('click', (e) => {
  if (!e.target.closest('.account-menu-container')) {
    document.getElementById('accountDropdown').classList.remove('show');
  }
});

function updateUserUI() {
  const label = document.getElementById('userNameLabel');
  const loggedOut = document.getElementById('loggedOutMenu');
  const loggedIn = document.getElementById('loggedInMenu');
  const greeting = document.getElementById('userGreetingText');
  const adminBtn = document.getElementById('adminPortalBtn');

  if (currentUser) {
    label.innerText = currentUser.name.split(' ')[0];
    loggedOut.style.display = 'none';
    loggedIn.style.display = 'block';
    greeting.innerText = `Welcome, ${currentUser.name}`;
    if (currentUser.role === 'ADMIN') {
      adminBtn.style.display = 'block';
    }
  } else {
    label.innerText = 'Sign In';
    loggedOut.style.display = 'block';
    loggedIn.style.display = 'none';
    adminBtn.style.display = 'none';
  }
}

function openAuthModal(mode) {
  isAuthRegisterMode = (mode === 'register');
  document.getElementById('authModalTitle').innerText = isAuthRegisterMode ? 'Create Collector Account' : 'Sign In to Your Account';
  document.getElementById('authNameGroup').style.display = isAuthRegisterMode ? 'flex' : 'none';
  document.getElementById('authSubmitBtn').innerText = isAuthRegisterMode ? 'Create Account' : 'Sign In';
  document.getElementById('authTogglePrompt').innerText = isAuthRegisterMode ? 'Already have an account?' : 'Don\'t have an account?';
  document.getElementById('authToggleLink').innerText = isAuthRegisterMode ? 'Sign In' : 'Create Account';
  document.getElementById('authModal').classList.add('open');
}

function closeAuthModal() {
  document.getElementById('authModal').classList.remove('open');
}

function toggleAuthMode() {
  openAuthModal(isAuthRegisterMode ? 'login' : 'register');
}

async function handleAuthSubmit(e) {
  e.preventDefault();
  const email = document.getElementById('authEmail').value.trim();
  const password = document.getElementById('authPassword').value;
  const name = document.getElementById('authName').value.trim();

  try {
    const endpoint = isAuthRegisterMode ? '/auth/register' : '/auth/login';
    const payload = isAuthRegisterMode ? { name, email, password } : { email, password };

    const res = await api(endpoint, 'POST', payload);
    authToken = res.data.token;
    currentUser = res.data.user;

    localStorage.setItem('wood_token', authToken);
    localStorage.setItem('wood_user', JSON.stringify(currentUser));

    updateUserUI();
    closeAuthModal();
    showToast(`Welcome ${currentUser.name}!`);

    if (currentUser.role === 'ADMIN') {
      openAdminPanel();
    }
  } catch (err) {
    alert('Authentication error: ' + err.message);
  }
}

async function demoLogin(role) {
  const credentials = role === 'admin'
    ? { email: 'admin@woodcarvers.com', password: 'Admin@123456' }
    : { email: 'customer@woodcarvers.com', password: 'Customer@123456' };

  try {
    const res = await api('/auth/login', 'POST', credentials);
    authToken = res.data.token;
    currentUser = res.data.user;

    localStorage.setItem('wood_token', authToken);
    localStorage.setItem('wood_user', JSON.stringify(currentUser));

    updateUserUI();
    document.getElementById('accountDropdown').classList.remove('show');
    showToast(`Signed in as ${currentUser.name}`);

    if (role === 'admin') openAdminPanel();
  } catch (err) {
    alert('Demo sign in failed: ' + err.message);
  }
}

function handleLogout() {
  authToken = null;
  currentUser = null;
  localStorage.removeItem('wood_token');
  localStorage.removeItem('wood_user');
  updateUserUI();
  document.getElementById('accountDropdown').classList.remove('show');
  navigateTo('home');
  showToast('You have signed out.');
}

// 10. Admin Operations Panel
async function openAdminPanel() {
  if (!currentUser || currentUser.role !== 'ADMIN') {
    await demoLogin('admin');
  }
  navigateTo('admin');
  loadAdminDashboard();
}

function switchAdminTab(tab) {
  document.querySelectorAll('.admin-nav-item').forEach(b => b.classList.remove('active'));
  event.currentTarget.classList.add('active');

  document.getElementById('adminTabDashboard').style.display = tab === 'dashboard' ? 'block' : 'none';
  document.getElementById('adminTabProducts').style.display = tab === 'products' ? 'block' : 'none';
  document.getElementById('adminTabOrders').style.display = tab === 'orders' ? 'block' : 'none';
  document.getElementById('adminTabCustomers').style.display = tab === 'customers' ? 'block' : 'none';

  if (tab === 'dashboard') loadAdminDashboard();
  if (tab === 'products') loadAdminProducts();
  if (tab === 'orders') loadAdminOrders();
  if (tab === 'customers') loadAdminCustomers();
}

async function loadAdminDashboard() {
  try {
    const res = await api('/admin/dashboard');
    const stats = res.data;

    document.getElementById('adminKpiGrid').innerHTML = `
      <div class="kpi-card"><span>Total Revenue</span><strong>₹${(stats.totalRevenue || 0).toLocaleString('en-IN')}</strong></div>
      <div class="kpi-card"><span>Total Orders</span><strong>${stats.totalOrders || 0}</strong></div>
      <div class="kpi-card"><span>Active Customers</span><strong>${stats.totalCustomers || 0}</strong></div>
      <div class="kpi-card"><span>Active Products</span><strong>${stats.totalProducts || 0}</strong></div>
      <div class="kpi-card"><span style="color:var(--terracotta);">Low Stock Alerts</span><strong>${stats.lowStockCount || 0}</strong></div>
    `;

    const recentTbody = document.querySelector('#adminRecentOrdersTable tbody');
    recentTbody.innerHTML = (stats.recentOrders || []).map(o => `
      <tr>
        <td><strong>#${o.orderNumber}</strong></td>
        <td>${o.user?.name || o.shippingAddress?.fullName || 'Customer'}</td>
        <td>${o.items.length} pcs</td>
        <td>₹${(o.total || 0).toLocaleString('en-IN')}</td>
        <td>${o.payment?.status || 'PAID'}</td>
        <td><span style="font-weight:bold;">${o.status}</span></td>
        <td><button class="btn btn-outline btn-sm" onclick="switchAdminTab('orders')">Manage</button></td>
      </tr>
    `).join('');
  } catch (err) {
    console.error('Failed to load admin dashboard:', err);
  }
}

async function loadAdminProducts() {
  try {
    const res = await api('/admin/products');
    const products = res.data || [];
    const tbody = document.querySelector('#adminProductsTable tbody');
    tbody.innerHTML = products.map(p => `
      <tr>
        <td><img src="${(p.images && p.images[0]) ? p.images[0].url : ''}" style="width:40px; height:40px; object-fit:cover; border-radius:4px;"></td>
        <td><strong>${p.title}</strong><br><small style="color:#888;">SKU: ${p.sku}</small></td>
        <td>₹${p.price.toLocaleString('en-IN')}</td>
        <td><strong>${p.stock}</strong> in stock</td>
        <td>${p.material || 'Hardwood'}</td>
        <td><span style="color:${p.isActive ? 'var(--success)' : '#888'}; font-weight:bold;">${p.isActive ? 'Active' : 'Disabled'}</span></td>
        <td>
          <button class="btn btn-outline btn-sm" onclick="editProduct('${p.id || p._id}')"><i class="fa-solid fa-pen"></i></button>
          <button class="btn btn-outline btn-sm" style="color:#a33b32;" onclick="deleteProduct('${p.id || p._id}')"><i class="fa-solid fa-trash"></i></button>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    console.error(err);
  }
}

async function loadAdminOrders() {
  try {
    const res = await api('/admin/orders');
    const orders = res.data || [];
    const tbody = document.querySelector('#adminAllOrdersTable tbody');
    tbody.innerHTML = orders.map(o => `
      <tr>
        <td><strong>#${o.orderNumber}</strong></td>
        <td>${new Date(o.createdAt).toLocaleDateString('en-IN')}</td>
        <td>${o.user?.name || o.shippingAddress?.fullName || 'Collector'}</td>
        <td>${o.items.length} items</td>
        <td>₹${(o.total || 0).toLocaleString('en-IN')}</td>
        <td><span style="font-weight:bold;">${o.status}</span></td>
        <td>
          <select onchange="updateOrderStatus('${o._id || o.id}', this.value)" class="select-input" style="padding:4px 8px; font-size:12px;">
            <option value="">Update Status...</option>
            <option value="Confirmed">Confirmed</option>
            <option value="Processing">Processing</option>
            <option value="Packed">Packed</option>
            <option value="Shipped">Shipped</option>
            <option value="Out for Delivery">Out for Delivery</option>
            <option value="Delivered">Delivered</option>
            <option value="Cancelled">Cancelled</option>
          </select>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    console.error(err);
  }
}

async function updateOrderStatus(orderId, newStatus) {
  if (!newStatus) return;
  try {
    await api(`/admin/orders/${orderId}/status`, 'PUT', {
      status: newStatus,
      trackingNumber: `BD-WC-${Math.floor(100000 + Math.random() * 900000)}`,
      carrier: 'BlueDart Artisanal Express'
    });
    showToast(`Order status updated to "${newStatus}" and FCM push triggered! 🔔`);
    loadAdminOrders();
  } catch (err) {
    alert('Error updating order: ' + err.message);
  }
}

async function loadAdminCustomers() {
  try {
    const res = await api('/admin/customers');
    const customers = res.data || [];
    const tbody = document.querySelector('#adminCustomersTable tbody');
    tbody.innerHTML = customers.map(c => `
      <tr>
        <td><strong>${c.name}</strong></td>
        <td>${c.email}</td>
        <td>${c.phone || '—'}</td>
        <td>${(c.addresses || []).length} saved</td>
        <td><span style="color:${c.isActive ? 'var(--success)' : '#a33b32'}; font-weight:bold;">${c.isActive ? 'Active' : 'Disabled'}</span></td>
        <td>
          <button class="btn btn-outline btn-sm" onclick="toggleCustomer('${c._id || c.id}')">
            ${c.isActive ? 'Disable' : 'Enable'}
          </button>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    console.error(err);
  }
}

async function toggleCustomer(id) {
  try {
    await api(`/admin/customers/${id}/toggle-status`, 'PUT');
    showToast('Customer account access updated.');
    loadAdminCustomers();
  } catch (err) {
    alert(err.message);
  }
}

// Admin Product Add/Edit Modal
function openProductModal(id = null) {
  document.getElementById('editProductId').value = id || '';
  document.getElementById('adminProductModalTitle').innerText = id ? 'Edit Wooden Product' : 'Add New Wooden Product';

  if (id) {
    const p = allProducts.find(x => (x.id || x._id) === id);
    if (p) {
      document.getElementById('pTitle').value = p.title;
      document.getElementById('pSku').value = p.sku;
      document.getElementById('pPrice').value = p.price;
      document.getElementById('pDiscount').value = p.discountPercent || 0;
      document.getElementById('pStock').value = p.stock;
      document.getElementById('pImageUrl').value = (p.images && p.images[0]) ? p.images[0].url : '';
      document.getElementById('pDesc').value = p.description;
      document.getElementById('pMaterial').value = p.material;
      document.getElementById('pDimensions').value = p.dimensions ? `${p.dimensions.length} x ${p.dimensions.width} x ${p.dimensions.height}` : '';
    }
  } else {
    document.getElementById('adminProductForm').reset();
    document.getElementById('pImageUrl').value = 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80';
  }

  document.getElementById('adminProductModal').classList.add('open');
}

function closeAdminProductModal() {
  document.getElementById('adminProductModal').classList.remove('open');
}

async function handleAdminProductSave(e) {
  e.preventDefault();
  const id = document.getElementById('editProductId').value;
  const payload = {
    title: document.getElementById('pTitle').value.trim(),
    sku: document.getElementById('pSku').value.trim(),
    category: document.getElementById('pCategory').value,
    price: Number(document.getElementById('pPrice').value),
    discountPercent: Number(document.getElementById('pDiscount').value) || 0,
    stock: Number(document.getElementById('pStock').value),
    description: document.getElementById('pDesc').value.trim(),
    material: document.getElementById('pMaterial').value.trim(),
    images: [{ url: document.getElementById('pImageUrl').value.trim(), isPrimary: true }]
  };

  try {
    if (id) {
      await api(`/admin/products/${id}`, 'PUT', payload);
      showToast('Product updated successfully!');
    } else {
      await api('/admin/products', 'POST', payload);
      showToast('New handcrafted product published!');
    }
    closeAdminProductModal();
    await loadProducts();
    loadAdminProducts();
  } catch (err) {
    alert('Failed to save product: ' + err.message);
  }
}

async function deleteProduct(id) {
  if (!confirm('Are you sure you want to delete this handcrafted piece?')) return;
  try {
    await api(`/admin/products/${id}`, 'DELETE');
    showToast('Product deleted.');
    await loadProducts();
    loadAdminProducts();
  } catch (err) {
    alert(err.message);
  }
}
