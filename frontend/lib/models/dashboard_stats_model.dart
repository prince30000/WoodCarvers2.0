import 'order_model.dart';
import 'user_model.dart';

class DashboardStatsModel {
  final num totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final List<OrderModel> recentOrders;
  final List<UserModel> recentCustomers;
  final Map<String, int> statusBreakdown;

  DashboardStatsModel({
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.recentOrders = const [],
    this.recentCustomers = const [],
    this.statusBreakdown = const {},
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    List<OrderModel> orders = [];
    if (json['recentOrders'] is List) {
      orders = (json['recentOrders'] as List)
          .map((i) => OrderModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    List<UserModel> customers = [];
    if (json['recentCustomers'] is List) {
      customers = (json['recentCustomers'] as List)
          .map((i) => UserModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    Map<String, int> breakdown = {};
    if (json['statusBreakdown'] is Map) {
      json['statusBreakdown'].forEach((k, v) {
        breakdown[k.toString()] = (v is num) ? v.toInt() : 0;
      });
    }

    return DashboardStatsModel(
      totalRevenue: json['totalRevenue'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      outOfStockCount: json['outOfStockCount'] ?? 0,
      recentOrders: orders,
      recentCustomers: customers,
      statusBreakdown: breakdown,
    );
  }
}
