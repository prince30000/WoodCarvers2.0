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
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: orderAsync.when(
        data: (order) {
          final isCancelled = order.status == 'Cancelled' || order.status == 'Refunded';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ORDER TRACKING', style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () => context.go('/orders'),
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                              label: const Text('All Orders', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(order.orderNumber, style: AppTypography.displayMedium(color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Placed on ${Formatters.formatDate(order.createdAt)}', style: AppTypography.bodySmall(color: AppColors.cream)),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 20,
                    vertical: 36,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. VISUAL ORDER TRACKING TIMELINE
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
                              Text('Visual Delivery Timeline', style: AppTypography.headingMedium(color: AppColors.espresso)),
                              const SizedBox(height: 24),
                              if (isCancelled)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cancel, color: AppColors.errorRed),
                                      const SizedBox(width: 12),
                                      Text(
                                        'This order is marked as ${order.status.toUpperCase()}.',
                                        style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                _buildVisualTimeline(order.status),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 2. Order Items and Shipping Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Items purchased
                            Expanded(
                              flex: isDesktop ? 7 : 12,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.warmBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Items in this Package', style: AppTypography.headingMedium(color: AppColors.espresso)),
                                    const SizedBox(height: 16),
                                    const Divider(color: AppColors.warmBorder),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: order.items.length,
                                      separatorBuilder: (_, __) => const Divider(color: AppColors.warmBorder),
                                      itemBuilder: (context, index) {
                                        final item = order.items[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: CachedNetworkImage(
                                                  imageUrl: item.image,
                                                  width: 64,
                                                  height: 64,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(item.title, style: AppTypography.headingSmall()),
                                                    const SizedBox(height: 4),
                                                    Text('SKU: ${item.sku}', style: AppTypography.bodySmall()),
                                                    const SizedBox(height: 4),
                                                    Text('${item.quantity} x ${Formatters.formatCurrency(item.price)}', style: AppTypography.bodyMedium(color: AppColors.naturalWood)),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                Formatters.formatCurrency(item.price * item.quantity),
                                                style: AppTypography.priceMedium(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (isDesktop) const SizedBox(width: 32),

                            // Right: Delivery Address & Receipt
                            if (isDesktop)
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    _buildAddressCard(order.shippingAddress),
                                    const SizedBox(height: 24),
                                    _buildPaymentSummaryCard(order),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // Mobile fallback for address & payment
                        if (!isDesktop) ...[
                          const SizedBox(height: 24),
                          _buildAddressCard(order.shippingAddress),
                          const SizedBox(height: 24),
                          _buildPaymentSummaryCard(order),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                const FooterWidget(),
              ],
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(
          body: ErrorRetryView(
            message: err.toString(),
            onRetry: () => ref.invalidate(orderDetailsProvider(orderId)),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualTimeline(String currentStatus) {
    final stages = [
      'Placed',
      'Confirmed',
      'Processing',
      'Packed',
      'Shipped',
      'Out for Delivery',
      'Delivered',
    ];

    int currentIndex = stages.indexOf(currentStatus);
    if (currentIndex == -1) {
      if (currentStatus == 'Paid') currentIndex = 1;
      else currentIndex = 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stages.asMap().entries.map((entry) {
          final idx = entry.key;
          final name = entry.value;
          final isCompleted = idx <= currentIndex;
          final isCurrent = idx == currentIndex;

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.espresso : AppColors.ivory,
                      border: Border.all(
                        color: isCompleted ? AppColors.espresso : AppColors.warmBorder,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle_outlined,
                      size: 18,
                      color: isCompleted ? (isCurrent ? AppColors.antiqueGold : Colors.white) : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted ? AppColors.espresso : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (idx < stages.length - 1)
                Container(
                  width: 50,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 24),
                  color: idx < currentIndex ? AppColors.espresso : AppColors.softBeige,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
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
          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: AppColors.naturalWood, size: 20),
              SizedBox(width: 8),
              Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Text(addr['fullName'] ?? '', style: AppTypography.headingSmall()),
          const SizedBox(height: 4),
          Text(addr['street'] ?? '', style: AppTypography.bodyMedium()),
          if (addr['landmark'] != null && addr['landmark'].isNotEmpty)
            Text('Near ${addr['landmark']}', style: AppTypography.bodyMedium(color: AppColors.textMuted)),
          Text('${addr['city'] ?? ''}, ${addr['state'] ?? ''} - ${addr['postalCode'] ?? ''}', style: AppTypography.bodyMedium()),
          const SizedBox(height: 4),
          Text('Phone: ${addr['phone'] ?? ''}', style: AppTypography.bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(OrderModel order) {
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
          Text('Payment & Total', style: AppTypography.headingSmall()),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Method', style: AppTypography.bodySmall()),
              Text(order.payment['method'] ?? 'RAZORPAY', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Status', style: AppTypography.bodySmall()),
              Text(
                (order.payment['status'] ?? 'PAID').toUpperCase(),
                style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.warmBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid', style: AppTypography.headingSmall()),
              Text(Formatters.formatCurrency(order.total), style: AppTypography.priceLarge()),
            ],
          ),
        ],
      ),
    );
  }
}
