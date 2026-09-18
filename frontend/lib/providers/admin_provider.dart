import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/dashboard_stats_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

final adminDashboardProvider = FutureProvider<DashboardStatsModel>((ref) async {
  final res = await apiClient.get(ApiEndpoints.adminDashboard);
  return DashboardStatsModel.fromJson(res['data']);
});

final adminProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, search) async {
  final queryParams = <String, dynamic>{'limit': 50};
  if (search.isNotEmpty) queryParams['search'] = search;
  final res = await apiClient.get(ApiEndpoints.adminProducts, queryParameters: queryParams);
  if (res['data'] is List) {
    return (res['data'] as List).map((i) => ProductModel.fromJson(i)).toList();
  }
  return [];
});

final adminOrdersProvider = FutureProvider.family<List<OrderModel>, String>((ref, status) async {
  final queryParams = <String, dynamic>{'limit': 50};
  if (status.isNotEmpty && status != 'ALL') queryParams['status'] = status;
  final res = await apiClient.get(ApiEndpoints.adminOrders, queryParameters: queryParams);
  if (res['data'] is List) {
    return (res['data'] as List).map((i) => OrderModel.fromJson(i)).toList();
  }
  return [];
});

final adminCustomersProvider = FutureProvider<List<UserModel>>((ref) async {
  final res = await apiClient.get(ApiEndpoints.adminCustomers, queryParameters: {'limit': 50});
  if (res['data'] is List) {
    return (res['data'] as List).map((i) => UserModel.fromJson(i)).toList();
  }
  return [];
});

class AdminActions {
  final Ref ref;
  AdminActions(this.ref);

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
    String? carrier,
    String? note,
  }) async {
    await apiClient.put('${ApiEndpoints.adminOrders}/$orderId/status', data: {
      'status': status,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'note': note,
    });
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminOrdersProvider);
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await apiClient.post(ApiEndpoints.adminProducts, data: data);
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminProductsProvider(''));
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await apiClient.put('${ApiEndpoints.adminProducts}/$id', data: data);
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminProductsProvider(''));
  }

  Future<void> deleteProduct(String id) async {
    await apiClient.delete('${ApiEndpoints.adminProducts}/$id');
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminProductsProvider(''));
  }

  Future<void> toggleCustomerStatus(String id) async {
    await apiClient.put('${ApiEndpoints.adminCustomers}/$id/toggle-status');
    ref.invalidate(adminCustomersProvider);
  }
}

final adminActionsProvider = Provider<AdminActions>((ref) {
  return AdminActions(ref);
});
