import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/state_views.dart';
import '../../providers/admin_provider.dart';

class AdminCustomersScreen extends ConsumerWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(adminCustomersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Directory', style: AppTypography.headingLarge(color: AppColors.espresso)),
                const SizedBox(height: 4),
                const Text('Review registered collectors and manage account access status.'),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warmBorder),
              ),
              child: customersAsync.when(
                data: (customers) {
                  if (customers.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No customers registered yet.')));
                  }

                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Customer Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Addresses')),
                      DataColumn(label: Text('Account Active')),
                      DataColumn(label: Text('Toggle Status')),
                    ],
                    rows: customers.map((cust) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.espresso,
                                  child: Text(
                                    (cust.name.isNotEmpty ? cust.name[0] : 'U').toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          DataCell(Text(cust.email)),
                          DataCell(Text(cust.phone.isNotEmpty ? cust.phone : '—')),
                          DataCell(Text('${cust.addresses.length} saved')),
                          DataCell(
                            Text(
                              cust.isActive ? 'Active' : 'Disabled',
                              style: TextStyle(
                                color: cust.isActive ? AppColors.successGreen : AppColors.errorRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: cust.isActive,
                              activeColor: AppColors.espresso,
                              onChanged: (_) async {
                                await ref.read(adminActionsProvider).toggleCustomerStatus(cust.id);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => ErrorRetryView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(adminCustomersProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
