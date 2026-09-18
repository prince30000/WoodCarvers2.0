class OrderItemModel {
  final String id;
  final String product;
  final String title;
  final String sku;
  final num price;
  final int quantity;
  final String image;

  OrderItemModel({
    required this.id,
    required this.product,
    required this.title,
    required this.sku,
    required this.price,
    required this.quantity,
    required this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      product: json['product'] is Map ? (json['product']['_id'] ?? '') : (json['product'] ?? ''),
      title: json['title'] ?? '',
      sku: json['sku'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      image: json['image'] ?? '',
    );
  }
}

class OrderTimelineItem {
  final String status;
  final DateTime timestamp;
  final String note;

  OrderTimelineItem({
    required this.status,
    required this.timestamp,
    this.note = '',
  });

  factory OrderTimelineItem.fromJson(Map<String, dynamic> json) {
    return OrderTimelineItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      note: json['note'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final dynamic user;
  final List<OrderItemModel> items;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic> payment;
  final num subtotal;
  final num discount;
  final num shippingFee;
  final num tax;
  final num total;
  final String status;
  final List<OrderTimelineItem> timeline;
  final String trackingNumber;
  final String carrier;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.user,
    required this.items,
    required this.shippingAddress,
    required this.payment,
    required this.subtotal,
    this.discount = 0,
    this.shippingFee = 0,
    this.tax = 0,
    required this.total,
    required this.status,
    this.timeline = const [],
    this.trackingNumber = '',
    this.carrier = '',
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> itemList = [];
    if (json['items'] is List) {
      itemList = (json['items'] as List)
          .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    List<OrderTimelineItem> timelineList = [];
    if (json['timeline'] is List) {
      timelineList = (json['timeline'] as List)
          .map((t) => OrderTimelineItem.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      user: json['user'],
      items: itemList,
      shippingAddress: json['shippingAddress'] is Map ? Map<String, dynamic>.from(json['shippingAddress']) : {},
      payment: json['payment'] is Map ? Map<String, dynamic>.from(json['payment']) : {},
      subtotal: json['subtotal'] ?? 0,
      discount: json['discount'] ?? 0,
      shippingFee: json['shippingFee'] ?? 0,
      tax: json['tax'] ?? 0,
      total: json['total'] ?? 0,
      status: json['status'] ?? 'Pending',
      timeline: timelineList,
      trackingNumber: json['trackingNumber'] ?? '',
      carrier: json['carrier'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
