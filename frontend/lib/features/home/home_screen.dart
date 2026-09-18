import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/animations/woodcarver_transitions.dart';
import '../../providers/products_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final bestsellersAsync = ref.watch(bestsellersProvider);
    final newArrivalsAsync = ref.watch(newArrivalsProvider);
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HERO SECTION
            CarvedRevealWidget(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 24,
                  vertical: isDesktop ? 80 : 40,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.espresso,
                      AppColors.darkWalnut,
                      AppColors.warmBrown.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Hero Copy
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.antiqueGold.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.antiqueGold.withOpacity(0.4)),
                                ),
                                child: Text(
                                  'PURE ARTISANAL WOODCRAFT',
                                  style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Handcrafted wooden pieces made to bring character to your space.',
                                style: (isDesktop ? AppTypography.displayLarge(color: Colors.white) : AppTypography.displayMedium(color: Colors.white)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sculpted from sustainably sourced seasoned walnut, teak, and rosewood. Each heirloom piece is individually carved by master generational craftsmen.',
                                style: AppTypography.bodyLarge(color: AppColors.cream.withOpacity(0.9)),
                              ),
                              const SizedBox(height: 32),
                              Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                children: [
                                  WoodButton(
                                    text: 'Explore Collection',
                                    icon: Icons.explore_outlined,
                                    variant: WoodButtonVariant.gold,
                                    height: 52,
                                    onPressed: () => context.push('/shop'),
                                  ),
                                  WoodButton(
                                    text: 'Our Artisanal Story',
                                    variant: WoodButtonVariant.outline,
                                    height: 52,
                                    onPressed: () => context.push('/shop?category=wall-hangings'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (isDesktop) const SizedBox(width: 48),

                        // Right Hero Feature Visual
                        if (isDesktop)
                          Expanded(
                            flex: 5,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 440,
                                  height: 480,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.warmGold.withOpacity(0.3), width: 1.5),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80',
                                    width: 420,
                                    height: 460,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.espresso.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.antiqueGold.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.verified, color: AppColors.antiqueGold, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tree of Life Wall Medallion • Walnut',
                                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. BRAND PROMISE / INTRODUCTION STRIP
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              color: AppColors.cream,
              child: Center(
                child: Wrap(
                  spacing: 48,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeaturePill(icon: Icons.brush_outlined, label: 'Hand-Chiseled Detailing'),
                    _FeaturePill(icon: Icons.eco_outlined, label: 'Ethically Sourced Hardwoods'),
                    _FeaturePill(icon: Icons.workspace_premium_outlined, label: 'Generational Craftsmanship'),
                    _FeaturePill(icon: Icons.local_shipping_outlined, label: 'Zero-Damage Delivery Guarantee'),
                  ],
                ),
              ),
            ),

            // 3. EXPLORE CATEGORIES
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURATED COLLECTIONS', style: AppTypography.bodySmall(color: AppColors.naturalWood).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Explore by Category', style: AppTypography.headingLarge()),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/shop'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.espresso),
                        label: const Text('View All', style: TextStyle(color: AppColors.espresso, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  categoriesAsync.when(
                    data: (categories) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisExtent(
                          crossAxisCount: isDesktop ? 4 : (ResponsiveLayout.isTablet(context) ? 3 : 2),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: categories.length > 8 ? 8 : categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return InkWell(
                            onTap: () => context.push('/shop?category=${cat.slug}'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    cat.imageUrl.isNotEmpty
                                        ? cat.imageUrl
                                        : 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=600&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.35),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),

            // 4. FEATURED PRODUCTS GRID
            Container(
              color: AppColors.cream.withOpacity(0.5),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HANDPICKED BY MASTER CARVERS', style: AppTypography.bodySmall(color: AppColors.naturalWood).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Featured Wooden Artifacts', style: AppTypography.headingLarge()),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/shop?isFeatured=true'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.espresso),
                        label: const Text('See All Featured', style: TextStyle(color: AppColors.espresso, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  featuredAsync.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(child: Text('No featured products at the moment.'));
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.length > 4 ? 4 : products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isWishlisted = wishlist.any((w) => w.id == product.id);
                          return ProductCard(
                            product: product,
                            isWishlisted: isWishlisted,
                            onToggleWishlist: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                            onAddToCart: () async {
                              try {
                                await ref.read(cartProvider.notifier).addToCart(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${product.title} to cart! 🪵')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () => const ProductGridShimmer(count: 4),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),

            // 5. PROMOTIONAL / CRAFTSMANSHIP SPOTLIGHT BANNER
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: 64,
              ),
              color: AppColors.darkWalnut,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Row(
                    children: [
                      if (isDesktop)
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
                              height: 380,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (isDesktop) const SizedBox(width: 48),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE WOOD CARVERS PHILOSOPHY',
                              style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Where Raw Timber Becomes Timeless Art',
                              style: AppTypography.displayMedium(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Every piece in our studio begins as a carefully chosen block of kiln-seasoned hardwood. Our sculptors work exclusively with hand-chisels, gouges, and rasps, following the organic grain lines of the tree to release sculptures that carry warmth and organic energy.',
                              style: AppTypography.bodyMedium(color: AppColors.cream.withOpacity(0.9)),
                            ),
                            const SizedBox(height: 24),
                            WoodButton(
                              text: 'Explore Artisan Sculptures',
                              variant: WoodButtonVariant.gold,
                              onPressed: () => context.push('/shop?category=sculptures'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 6. BEST SELLERS SECTION
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CUSTOMER FAVORITES', style: AppTypography.bodySmall(color: AppColors.naturalWood).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Best Sellers', style: AppTypography.headingLarge()),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/shop?isBestseller=true'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.espresso),
                        label: const Text('View All', style: TextStyle(color: AppColors.espresso, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  bestsellersAsync.when(
                    data: (products) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.length > 4 ? 4 : products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isWishlisted = wishlist.any((w) => w.id == product.id);
                          return ProductCard(
                            product: product,
                            isWishlisted: isWishlisted,
                            onToggleWishlist: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                            onAddToCart: () async {
                              try {
                                await ref.read(cartProvider.notifier).addToCart(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${product.title} to cart! 🪵')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () => const ProductGridShimmer(count: 4),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),

            // 7. FOOTER
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.naturalWood),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(fontSize: 13),
        ),
      ],
    );
  }
}
