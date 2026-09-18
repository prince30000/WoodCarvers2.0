import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/state_views.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: statsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operations Overview', style: AppTypography.headingLarge(color: AppColors.espresso)),
                        const SizedBox(height: 4),
                        const Text('Live store analytics and operational status for Wood Carvers studio.'),
                      ],
                    ),
                    WoodButton(
                      text: 'Add Product',
                      icon: Icons.add,
                      variant: WoodButtonVariant.gold,
                      height: 42,
                      onPressed: () => context.push('/admin/products/new'),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // KPI Metric Cards
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _MetricCard(
                      title: 'Total Revenue',
                      value: Formatters.formatCurrency(stats.totalRevenue),
                      icon: Icons.currency_rupee,
                      accentColor: AppColors.antiqueGold,
                    ),
                    _MetricCard(
                      title: 'Total Orders',
                      value: stats.totalOrders.toString(),
                      icon: Icons.receipt_long_outlined,
                      accentColor: AppColors.naturalWood,
                    ),
                    _MetricCard(
                      title: 'Active Customers',
                      value: stats.totalCustomers.toString(),
                      icon: Icons.people_outline,
                      accentColor: AppColors.forestSage,
                    ),
                    _MetricCard(
                      title: 'Active Products',
                      value: stats.totalProducts.toString(),
                      icon: Icons.park_outlined,
                      accentColor: AppColors.espresso,
                    ),
                    _MetricCard(
                      title: 'Low Stock Alert',
                      value: stats.lowStockCount.toString(),
                      icon: Icons.warning_amber_rounded,
                      accentColor: stats.lowStockCount > 0 ? AppColors.terracotta : AppColors.textMuted,
                    ),
                    _MetricCard(
                      title: 'Out of Stock',
                      value: stats.outOfStockCount.toString(),
                      icon: Icons.cancel_outlined,
                      accentColor: stats.outOfStockCount > 0 ? AppColors.errorRed : AppColors.textMuted,
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Order Status Breakdown Strip
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warmBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Status Distribution', style: AppTypography.headingSmall(color: AppColors.espresso)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: stats.statusBreakdown.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.ivory,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.warmBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.espresso,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('${e.value}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Recent Orders Table
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warmBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Orders', style: AppTypography.headingMedium(color: AppColors.espresso)),
                          TextButton(
                            onPressed: () => context.go('/admin/orders'),
                            child: const Text('View All Orders'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (stats.recentOrders.isEmpty)
                        const Text('No recent orders.')
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Order #')),
                              DataColumn(label: Text('Customer')),
                              DataColumn(label: Text('Items')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: stats.recentOrders.map((ord) {
                              final custName = (ord.user is Map) ? ord.user['name'] : 'Customer';
                              return DataRow(
                                cells: [
                                  DataCell(Text(ord.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(custName ?? 'Customer')),
                                  DataCell(Text('${ord.items.length} items')),
                                  DataCell(Text(Formatters.formatCurrency(ord.total))),
                                  DataCell(Text(ord.status, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(
                                    TextButton(
                                      onPressed: () => context.go('/admin/orders'),
                                      child: const Text('Inspect'),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorRetryView(
          message: err.toString(),
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodySmall(color: AppColors.textMuted)),
              Icon(icon, size: 20, color: accentColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headingLarge(color: AppColors.espresso).copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}
