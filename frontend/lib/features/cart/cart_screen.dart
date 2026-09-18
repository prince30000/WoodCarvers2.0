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
import '../../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 32,
              ),
              color: AppColors.espresso,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR SELECTION', style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Artisanal Shopping Bag', style: AppTypography.displayMedium(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: cartAsync.when(
                  data: (cart) {
                    if (cart == null || cart.items.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Your Shopping Bag is Empty',
                        message: 'Explore our handcrafted wooden decorative pieces to bring authentic artisanal character to your home.',
                        buttonText: 'Start Shopping',
                        onButtonPressed: () => context.go('/shop'),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Item list
                        Expanded(
                          flex: isDesktop ? 7 : 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${cart.totalItemCount} Items in your bag',
                                    style: AppTypography.headingSmall(color: AppColors.espresso),
                                  ),
                                  TextButton(
                                    onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                                    child: const Text('Clear Bag', style: TextStyle(color: AppColors.errorRed)),
                                  ),
                                ],
                              ),
                              const Divider(color: AppColors.warmBorder),
                              const SizedBox(height: 12),

                              // Items List
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cart.items.length,
                                separatorBuilder: (_, __) => const Divider(color: AppColors.warmBorder),
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  final product = item.productData;
                                  final prodTitle = product?.title ?? 'Handcrafted Wooden Piece';
                                  final prodImage = product?.primaryImageUrl ?? '';
                                  final unitPrice = item.priceAtAddition;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product Thumbnail
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.ivory,
                                            child: CachedNetworkImage(
                                              imageUrl: prodImage,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                prodTitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(fontSize: 15),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Formatters.formatCurrency(unitPrice),
                                                style: AppTypography.priceMedium(color: AppColors.naturalWood),
                                              ),
                                              const SizedBox(height: 8),

                                              // Quantity Controls
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: AppColors.warmBorder),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons.remove, size: 14),
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                                          onPressed: item.quantity > 1
                                                              ? () => ref.read(cartProvider.notifier).updateQuantity(
                                                                    product?.id ?? '',
                                                                    item.quantity - 1,
                                                                  )
                                                              : null,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                                          child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.add, size: 14),
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(
                                                                product?.id ?? '',
                                                                item.quantity + 1,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                                                    tooltip: 'Remove',
                                                    onPressed: () => ref.read(cartProvider.notifier).removeItem(product?.id ?? ''),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        if (isDesktop) const SizedBox(width: 48),

                        // Right: Order Summary Card
                        if (isDesktop)
                          Expanded(
                            flex: 5,
                            child: _buildSummaryCard(context, cart.subtotal, cart.shipping, cart.total),
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => ErrorRetryView(
                    message: err.toString(),
                    onRetry: () => ref.read(cartProvider.notifier).fetchCart(),
                  ),
                ),
              ),
            ),

            // Mobile summary card fallback
            if (!isDesktop && cartAsync.value != null && cartAsync.value!.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSummaryCard(
                  context,
                  cartAsync.value!.subtotal,
                  cartAsync.value!.shipping,
                  cartAsync.value!.total,
                ),
              ),

            const SizedBox(height: 48),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, num subtotal, num shipping, num total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTypography.headingMedium(color: AppColors.espresso)),
          const SizedBox(height: 16),
          const Divider(color: AppColors.warmBorder),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTypography.bodyMedium()),
              Text(Formatters.formatCurrency(subtotal), style: AppTypography.bodyMedium(color: AppColors.espresso)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Artisanal Packaging & Courier', style: AppTypography.bodyMedium()),
              Text(
                shipping == 0 ? 'FREE' : Formatters.formatCurrency(shipping),
                style: TextStyle(
                  color: shipping == 0 ? AppColors.successGreen : AppColors.espresso,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtotal >= 1999 ? '✓ You unlocked Free Courier Shipping!' : 'Add items worth ₹${(1999 - subtotal).clamp(0, 1999)} more for Free Shipping',
            style: AppTypography.bodySmall(color: subtotal >= 1999 ? AppColors.successGreen : AppColors.textMuted),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.warmBorder),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Total', style: AppTypography.headingSmall(color: AppColors.espresso)),
              Text(Formatters.formatCurrency(total), style: AppTypography.priceMedium(color: AppColors.espresso)),
            ],
          ),
          const SizedBox(height: 24),

          WoodButton(
            text: 'Proceed to Checkout',
            icon: Icons.lock_outline,
            variant: WoodButtonVariant.gold,
            height: 52,
            width: double.infinity,
            onPressed: () => context.push('/checkout'),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield_outlined, size: 16, color: AppColors.textMuted),
              SizedBox(width: 6),
              Text('Safe & Encrypted 256-Bit Checkout', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
