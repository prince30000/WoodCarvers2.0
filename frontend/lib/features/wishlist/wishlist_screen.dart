import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/state_views.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final wishlist = ref.watch(wishlistProvider);

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
                vertical: 28,
              ),
              color: AppColors.espresso,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURATED FAVORITES', style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Your Saved Pieces', style: AppTypography.displayMedium(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // Wishlist Grid
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: wishlist.isEmpty
                    ? EmptyStateView(
                        icon: Icons.favorite_border_rounded,
                        title: 'Your Wishlist is Empty',
                        message: 'Save your favorite handcrafted statues, wall hangings, and decor items here for easy access.',
                        buttonText: 'Browse Collection',
                        onButtonPressed: () => context.go('/shop'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${wishlist.length} Saved Artifacts',
                            style: AppTypography.headingSmall(color: AppColors.espresso),
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 280,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: wishlist.length,
                            itemBuilder: (context, index) {
                              final product = wishlist[index];
                              return ProductCard(
                                product: product,
                                isWishlisted: true,
                                onToggleWishlist: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                                onAddToCart: () => ref.read(cartProvider.notifier).addToCart(product.id),
                              );
                            },
                          ),
                        ],
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
