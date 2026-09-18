import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/state_views.dart';
import '../../providers/order_provider.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Strip
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 28,
              ),
              color: AppColors.espresso,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER HISTORY', style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Your Handcrafted Orders', style: AppTypography.displayMedium(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // Orders list
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Orders Yet',
                        message: 'You have not placed any orders for handcrafted wooden decorative artifacts yet.',
                        buttonText: 'Explore Catalog',
                        onButtonPressed: () => context.go('/shop'),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warmBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.orderNumber,
                                        style: AppTypography.headingSmall(color: AppColors.espresso),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Placed on ${Formatters.formatDate(order.createdAt)}',
                                        style: AppTypography.bodySmall(color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  _StatusChip(status: order.status),
                                ],
                              ),

                              const SizedBox(height: 16),
                              const Divider(color: AppColors.warmBorder),
                              const SizedBox(height: 12),

                              // Items Preview
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: order.items.map((item) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: item.image,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${item.title} (x${item.quantity})',
                                        style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 16),
                              const Divider(color: AppColors.warmBorder),
                              const SizedBox(height: 12),

                              // Bottom Row (Price & Action)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total Amount Paid', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                                      Text(Formatters.formatCurrency(order.total), style: AppTypography.priceMedium(color: AppColors.espresso)),
                                    ],
                                  ),
                                  WoodButton(
                                    text: 'Track Order Details',
                                    icon: Icons.timeline,
                                    variant: WoodButtonVariant.outline,
                                    height: 40,
                                    onPressed: () => context.push('/orders/${order.id}'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => ErrorRetryView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(myOrdersProvider),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Delivered':
        bg = AppColors.successGreen.withOpacity(0.12);
        fg = AppColors.successGreen;
        break;
      case 'Cancelled':
      case 'Refunded':
        bg = AppColors.errorRed.withOpacity(0.12);
        fg = AppColors.errorRed;
        break;
      case 'Shipped':
      case 'Out for Delivery':
        bg = AppColors.antiqueGold.withOpacity(0.2);
        fg = AppColors.darkWalnut;
        break;
      default:
        bg = AppColors.softBeige.withOpacity(0.6);
        fg = AppColors.espresso;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
