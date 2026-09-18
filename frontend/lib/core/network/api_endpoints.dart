class ApiEndpoints {
  // Health
  static const String health = '/health';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String address = '/auth/address';
  static const String deviceToken = '/auth/device-token';

  // Products
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static const String newArrivals = '/products/new-arrivals';
  static const String bestsellers = '/products/bestsellers';
  static const String productBySlug = '/products/slug';
  static const String relatedProducts = '/products/related';

  // Categories
  static const String categories = '/categories';

  // Cart
  static const String cart = '/cart';
  static const String cartAdd = '/cart/add';
  static const String cartUpdate = '/cart/update';
  static const String cartRemove = '/cart/remove';
  static const String cartClear = '/cart/clear';

  // Orders
  static const String checkout = '/orders/checkout';
  static const String myOrders = '/orders/my-orders';
  static const String orderById = '/orders';
  static const String cancelOrder = '/orders';

  // Payments
  static const String createPayment = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';

  // Reviews
  static const String reviews = '/reviews/product';

  // Wishlist
  static const String wishlist = '/wishlist';
  static const String wishlistToggle = '/wishlist/toggle';

  // Notifications
  static const String notifications = '/notifications';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminCategories = '/admin/categories';
  static const String adminOrders = '/admin/orders';
  static const String adminCustomers = '/admin/customers';
  static const String adminUpload = '/admin/upload';
}
