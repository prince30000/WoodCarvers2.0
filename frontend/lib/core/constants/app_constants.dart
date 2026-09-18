class AppConstants {
  // Storage Keys
  static const String tokenKey = 'woodcarvers_token';
  static const String userKey = 'woodcarvers_user';
  static const String fcmTokenKey = 'woodcarvers_fcm_token';

  // Order Statuses
  static const List<String> orderStatuses = [
    'Pending',
    'Payment Pending',
    'Paid',
    'Confirmed',
    'Processing',
    'Packed',
    'Shipped',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
    'Returned',
    'Refunded'
  ];

  // Wood Materials
  static const List<String> woodMaterials = [
    'Seasoned Dark Walnut Wood',
    'Natural Teak Wood',
    'Indian Rosewood (Sheesham)',
    'Seasoned Mango Wood',
    'European Beechwood',
    'Himalayan Cedar Wood',
    'Wrightia Tinctoria (Ivory Wood)'
  ];
}
