import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/order_model.dart';
import 'cart_provider.dart';

final myOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final response = await apiClient.get(ApiEndpoints.myOrders);
  if (response['data'] is List) {
    return (response['data'] as List)
        .map((i) => OrderModel.fromJson(i as Map<String, dynamic>))
        .toList();
  }
  return [];
});

final orderDetailsProvider = FutureProvider.family<OrderModel, String>((ref, id) async {
  final response = await apiClient.get('${ApiEndpoints.orderById}/$id');
  return OrderModel.fromJson(response['data']);
});

class OrderActions {
  final Ref ref;
  OrderActions(this.ref);

  Future<OrderModel> createOrder({
    required Map<String, dynamic> shippingAddress,
    String paymentMethod = 'RAZORPAY',
    String notes = '',
  }) async {
    final response = await apiClient.post(ApiEndpoints.checkout, data: {
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'notes': notes,
    });
    ref.invalidate(cartProvider);
    ref.invalidate(myOrdersProvider);
    return OrderModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> initiateRazorpayPayment(String orderId) async {
    final response = await apiClient.post(ApiEndpoints.createPayment, data: {
      'orderId': orderId,
    });
    return response['data'] as Map<String, dynamic>;
  }

  Future<OrderModel> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await apiClient.post(ApiEndpoints.verifyPayment, data: {
      'orderId': orderId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    });
    ref.invalidate(cartProvider);
    ref.invalidate(myOrdersProvider);
    return OrderModel.fromJson(response['data']);
  }

  Future<void> cancelOrder(String orderId) async {
    await apiClient.put('${ApiEndpoints.cancelOrder}/$orderId/cancel');
    ref.invalidate(myOrdersProvider);
    ref.invalidate(orderDetailsProvider(orderId));
  }
}

final orderActionsProvider = Provider<OrderActions>((ref) {
  return OrderActions(ref);
});
