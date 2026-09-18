import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../core/widgets/state_views.dart';
import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedStatusFilter = 'ALL';

  void _showUpdateStatusDialog(BuildContext context, OrderModel order) {
    String newStatus = order.status;
    final trackingCtrl = TextEditingController(text: order.trackingNumber);
    final carrierCtrl = TextEditingController(text: order.carrier);
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update Status: #${order.orderNumber}', style: AppTypography.headingSmall()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select New Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: newStatus,
                items: AppConstants.orderStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => newStatus = val);
                },
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 12),
              WoodTextField(label: 'Tracking Number', hint: 'e.g. DTDC-987654321', controller: trackingCtrl),
              const SizedBox(height: 12),
              WoodTextField(label: 'Carrier / Courier Partner', hint: 'e.g. BlueDart Express', controller: carrierCtrl),
              const SizedBox(height: 12),
              WoodTextField(label: 'Internal Audit Note', hint: 'e.g. Dispatched from Bengaluru hub', controller: noteCtrl),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(adminActionsProvider).updateOrderStatus(
                    orderId: order.id,
                    status: newStatus,
                    trackingNumber: trackingCtrl.text.trim(),
                    carrier: carrierCtrl.text.trim(),
                    note: noteCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order #${order.orderNumber} updated to $newStatus and customer notified via FCM! 🪵')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              },
              child: const Text('Save & Notify Customer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider(_selectedStatusFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Orders', style: AppTypography.headingLarge(color: AppColors.espresso)),
                const SizedBox(height: 4),
                const Text('Review customer purchases, assign courier tracking numbers, and update order statuses.'),
              ],
            ),

            const SizedBox(height: 24),

            // Status Filter Chips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warmBorder),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterStatusChip(
                      label: 'All Orders',
                      isSelected: _selectedStatusFilter == 'ALL',
                      onTap: () => setState(() => _selectedStatusFilter = 'ALL'),
                    ),
                    ...AppConstants.orderStatuses.map((st) {
                      return _FilterStatusChip(
                        label: st,
                        isSelected: _selectedStatusFilter == st,
                        onTap: () => setState(() => _selectedStatusFilter = st),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Orders Table
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warmBorder),
              ),
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No orders found matching filter.')));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Order ID')),
                        DataColumn(label: Text('Customer Info')),
                        DataColumn(label: Text('Items')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Payment')),
                        DataColumn(label: Text('Order Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: orders.map((ord) {
                        final custName = ord.user is Map ? ord.user['name'] : (ord.shippingAddress['fullName'] ?? 'Customer');
                        final custPhone = ord.user is Map ? ord.user['phone'] : (ord.shippingAddress['phone'] ?? '');

                        return DataRow(
                          cells: [
                            DataCell(Text(ord.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(custName ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (custPhone != null && custPhone.isNotEmpty)
                                    Text(custPhone, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(Text('${ord.items.length} pcs')),
                            DataCell(Text(Formatters.formatCurrency(ord.total), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(
                              Text(
                                '${ord.payment['method'] ?? 'RAZORPAY'} (${ord.payment['status'] ?? 'PENDING'})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ord.payment['status'] == 'PAID' ? AppColors.successGreen : AppColors.terracotta,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.softBeige.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(ord.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataCell(
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 14),
                                label: const Text('Change Status'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () => _showUpdateStatusDialog(context, ord),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => ErrorRetryView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(adminOrdersProvider(_selectedStatusFilter)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterStatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterStatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.espresso,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.espresso,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
