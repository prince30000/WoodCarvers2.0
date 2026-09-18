import 'product_model.dart';

class CartItemModel {
  final String id;
  final dynamic product; // ProductModel or Map or String ID
  final int quantity;
  final num priceAtAddition;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceAtAddition,
  });

  ProductModel? get productData {
    if (product is ProductModel) return product as ProductModel;
    if (product is Map<String, dynamic>) return ProductModel.fromJson(product);
    return null;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    dynamic prod = json['product'];
    if (prod is Map<String, dynamic>) {
      prod = ProductModel.fromJson(prod);
    }

    return CartItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      product: prod,
      quantity: json['quantity'] ?? 1,
      priceAtAddition: json['priceAtAddition'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product is ProductModel ? (product as ProductModel).id : product,
    'quantity': quantity,
    'priceAtAddition': priceAtAddition,
  };
}

class CartModel {
  final String id;
  final List<CartItemModel> items;
  final num subtotal;
  final num discount;
  final num shipping;
  final num total;

  CartModel({
    required this.id,
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.shipping = 0,
    this.total = 0,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> itemList = [];
    if (json['items'] is List) {
      itemList = (json['items'] as List)
          .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return CartModel(
      id: json['_id'] ?? json['id'] ?? '',
      items: itemList,
      subtotal: json['subtotal'] ?? 0,
      discount: json['discount'] ?? 0,
      shipping: json['shipping'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'shipping': shipping,
    'total': total,
  };
}
