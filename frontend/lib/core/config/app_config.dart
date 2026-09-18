class AppConfig {
  // Configurable base URL for Wood Carvers REST API
  // In development: defaults to localhost:5000/api
  // In production: can be injected via --dart-define=API_BASE_URL=https://...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  // Razorpay Key ID
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_woodcarvers123',
  );

  static const String appName = 'WOOD CARVERS';
  static const String brandTagline = 'Handcrafted wooden pieces made to bring character to your space.';
  static const String currencySymbol = '₹';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
