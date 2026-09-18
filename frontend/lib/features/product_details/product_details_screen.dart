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
import '../../core/widgets/product_card.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String slugOrId;

  const ProductDetailsScreen({super.key, required this.slugOrId});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final productAsync = ref.watch(productDetailsProvider(widget.slugOrId));
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: productAsync.when(
        data: (product) {
          final isWishlisted = wishlist.any((w) => w.id == product.id);
          final hasDiscount = product.discountPercent > 0;
          final isOutOfStock = product.stock <= 0;
          final relatedAsync = ref.watch(relatedProductsProvider(product.id));

          final images = product.images.isNotEmpty
              ? product.images
              : [ProductImage(url: product.primaryImageUrl)];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Breadcrumbs bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 20,
                    vertical: 14,
                  ),
                  color: AppColors.ivory,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.go('/'),
                          child: Text('Home', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                        ),
                        const Text('  /  ', style: TextStyle(color: AppColors.textMuted)),
                        InkWell(
                          onTap: () => context.go('/shop'),
                          child: Text('Shop', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                        ),
                        const Text('  /  ', style: TextStyle(color: AppColors.textMuted)),
                        Text(
                          product.categoryName,
                          style: AppTypography.bodySmall(color: AppColors.textMuted),
                        ),
                        const Text('  /  ', style: TextStyle(color: AppColors.textMuted)),
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(color: AppColors.espresso).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1, color: AppColors.warmBorder),

                // Main Product Showcase Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 20,
                    vertical: 36,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Image Gallery
                        Expanded(
                          flex: isDesktop ? 6 : 12,
                          child: Column(
                            children: [
                              // Main Stage Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: AppColors.cream,
                                  height: isDesktop ? 480 : 340,
                                  width: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: images[_selectedImageIndex].url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Thumbnails Carousel
                              if (images.length > 1)
                                SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final isSelected = _selectedImageIndex == index;
                                      return InkWell(
                                        onTap: () => setState(() => _selectedImageIndex = index),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isSelected ? AppColors.naturalWood : AppColors.warmBorder,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl: images[index].url,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (isDesktop) const SizedBox(width: 48),

                        // Right: Product Details & Purchase Actions
                        if (isDesktop)
                          Expanded(
                            flex: 6,
                            child: _buildDetailsColumn(context, product, hasDiscount, isOutOfStock, isWishlisted),
                          ),
                      ],
                    ),
                  ),
                ),

                // Mobile details fallback
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDetailsColumn(context, product, hasDiscount, isOutOfStock, isWishlisted),
                  ),

                const SizedBox(height: 48),

                // Specifications & Information Tabs
                Container(
                  color: AppColors.cream.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 20,
                    vertical: 48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ARTISANAL SPECIFICATIONS', style: AppTypography.headingMedium(color: AppColors.espresso)),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 32,
                          runSpacing: 24,
                          children: [
                            _SpecCard(title: 'Timber Material', value: product.material, icon: Icons.forest_outlined),
                            _SpecCard(
                              title: 'Dimensions',
                              value: '${product.dimensions['length'] ?? 0} x ${product.dimensions['width'] ?? 0} x ${product.dimensions['height'] ?? 0} ${product.dimensions['unit'] ?? 'cm'}',
                              icon: Icons.square_foot_outlined,
                            ),
                            _SpecCard(
                              title: 'Weight',
                              value: '${product.weight['value'] ?? 0} ${product.weight['unit'] ?? 'g'}',
                              icon: Icons.scale_outlined,
                            ),
                            _SpecCard(title: 'SKU Identifier', value: product.sku, icon: Icons.tag),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: AppColors.warmBorder),
                        const SizedBox(height: 24),
                        Text('Care Instructions', style: AppTypography.headingSmall(color: AppColors.espresso)),
                        const SizedBox(height: 6),
                        Text(product.careInstructions, style: AppTypography.bodyMedium()),
                        const SizedBox(height: 20),
                        Text('Craftsmanship Story', style: AppTypography.headingSmall(color: AppColors.espresso)),
                        const SizedBox(height: 6),
                        Text(product.craftsmanshipInfo, style: AppTypography.bodyMedium()),
                      ],
                    ),
                  ),
                ),

                // Related Products Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 20,
                    vertical: 48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Related Handcrafted Pieces', style: AppTypography.headingLarge()),
                        const SizedBox(height: 24),
                        relatedAsync.when(
                          data: (relatedList) {
                            if (relatedList.isEmpty) return const SizedBox();
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 280,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: relatedList.length,
                              itemBuilder: (context, index) {
                                final rel = relatedList[index];
                                return ProductCard(
                                  product: rel,
                                  isWishlisted: wishlist.any((w) => w.id == rel.id),
                                  onToggleWishlist: () => ref.read(wishlistProvider.notifier).toggle(rel.id),
                                  onAddToCart: () => ref.read(cartProvider.notifier).addToCart(rel.id),
                                );
                              },
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                const FooterWidget(),
              ],
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(
          body: ErrorRetryView(
            message: err.toString(),
            onRetry: () => ref.invalidate(productDetailsProvider(widget.slugOrId)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsColumn(
    BuildContext context,
    ProductModel product,
    bool hasDiscount,
    bool isOutOfStock,
    bool isWishlisted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category and Rating Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.categoryName.toUpperCase(),
              style: AppTypography.bodySmall(color: AppColors.naturalWood).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.antiqueGold, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${product.ratingsAverage.toStringAsFixed(1)} (${product.ratingsCount} reviews)',
                  style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Title
        Text(product.title, style: AppTypography.headingLarge(color: AppColors.espresso)),

        const SizedBox(height: 16),

        // Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Formatters.formatCurrency(product.discountedPrice),
              style: AppTypography.priceLarge(color: AppColors.espresso),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 12),
              Text(
                Formatters.formatCurrency(product.price),
                style: AppTypography.priceStrikeThrough(color: AppColors.textMuted),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Save ${product.discountPercent}%',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Stock Status Indicator
        Row(
          children: [
            Icon(
              isOutOfStock ? Icons.cancel_outlined : Icons.check_circle_outline,
              size: 16,
              color: isOutOfStock ? AppColors.errorRed : AppColors.successGreen,
            ),
            const SizedBox(width: 6),
            Text(
              isOutOfStock
                  ? 'Currently Out of Stock'
                  : (product.stock <= 5 ? 'Only ${product.stock} pieces left in studio!' : 'In Stock & Ready to Dispatch'),
              style: TextStyle(
                color: isOutOfStock ? AppColors.errorRed : (product.stock <= 5 ? AppColors.terracotta : AppColors.successGreen),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: AppColors.warmBorder),
        const SizedBox(height: 20),

        // Description
        Text(product.description, style: AppTypography.bodyMedium(color: AppColors.textPrimary)),

        const SizedBox(height: 28),

        // Quantity Selector & Actions
        if (!isOutOfStock)
          Row(
            children: [
              // Quantity Counter
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.warmBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text('$_quantity', style: AppTypography.headingSmall()),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Wishlist Toggle
              OutlinedButton.icon(
                onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.terracotta : AppColors.espresso,
                ),
                label: Text(isWishlisted ? 'Saved' : 'Wishlist'),
              ),
            ],
          ),

        const SizedBox(height: 24),

        // Add to Cart & Buy Now Buttons
        Row(
          children: [
            Expanded(
              child: WoodButton(
                text: 'Add to Cart',
                icon: Icons.shopping_bag_outlined,
                variant: WoodButtonVariant.primary,
                height: 52,
                onPressed: isOutOfStock
                    ? null
                    : () async {
                        try {
                          await ref.read(cartProvider.notifier).addToCart(product.id, quantity: _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added $_quantity x ${product.title} to cart! 🪵')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WoodButton(
                text: 'Buy Now',
                icon: Icons.flash_on,
                variant: WoodButtonVariant.gold,
                height: 52,
                onPressed: isOutOfStock
                    ? null
                    : () async {
                        try {
                          await ref.read(cartProvider.notifier).addToCart(product.id, quantity: _quantity);
                          context.push('/checkout');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SpecCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SpecCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warmBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.naturalWood, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodySmall(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
