import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/wood_button.dart';
import '../../providers/products_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';

class ShopScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final bool? isFeatured;
  final bool? isBestseller;

  const ShopScreen({
    super.key,
    this.initialCategory,
    this.isFeatured,
    this.isBestseller,
  });

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null) {
        ref.read(shopFilterProvider.notifier).update(
              (s) => s.copyWith(categorySlug: widget.initialCategory),
            );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final filter = ref.watch(shopFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(shopProductsProvider);
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Page Header Strip
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: 36,
              ),
              color: AppColors.espresso,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARTISANAL CATALOG',
                      style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Handcrafted Wooden Pieces',
                      style: AppTypography.displayMedium(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore authentic small & medium decorative wooden creations sculpted by heritage woodworkers.',
                      style: AppTypography.bodyMedium(color: AppColors.cream.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar & Filter Controls Strip
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 24,
                vertical: 18,
              ),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  children: [
                    // Backend Search Input
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.ivory,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.warmBorder),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (query) {
                            ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(search: query, page: 1));
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by wooden piece name, carving type, timber...',
                            hintStyle: AppTypography.bodySmall(),
                            prefixIcon: const Icon(Icons.search, color: AppColors.naturalWood, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(search: '', page: 1));
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Sort Dropdown
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.warmBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: filter.sort,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.espresso),
                          onChanged: (newSort) {
                            if (newSort != null) {
                              ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(sort: newSort, page: 1));
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Newest Releases')),
                            DropdownMenuItem(value: 'price-asc', child: Text('Price: Low to High')),
                            DropdownMenuItem(value: 'price-desc', child: Text('Price: High to Low')),
                            DropdownMenuItem(value: 'popularity', child: Text('Most Popular')),
                            DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: AppColors.warmBorder),

            // Main Catalog Layout (Sidebar Filters + Products Grid)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Desktop Filter Sidebar
                    if (isDesktop)
                      SizedBox(
                        width: 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORIES',
                              style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _CategoryFilterItem(
                              title: 'All Products',
                              isSelected: filter.categorySlug == null || filter.categorySlug == 'all',
                              onTap: () {
                                ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(categorySlug: 'all', page: 1));
                              },
                            ),
                            categoriesAsync.when(
                              data: (cats) => Column(
                                children: cats.map((cat) {
                                  return _CategoryFilterItem(
                                    title: cat.name,
                                    isSelected: filter.categorySlug == cat.slug,
                                    onTap: () {
                                      ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(categorySlug: cat.slug, page: 1));
                                    },
                                  );
                                }).toList(),
                              ),
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                            const SizedBox(height: 28),
                            const Divider(color: AppColors.warmBorder),
                            const SizedBox(height: 20),

                            // Availability filter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('In Stock Only', style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(fontSize: 14)),
                                Switch(
                                  value: filter.inStock,
                                  activeColor: AppColors.espresso,
                                  onChanged: (val) {
                                    ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(inStock: val, page: 1));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (isDesktop) const SizedBox(width: 36),

                    // Products Grid & Pagination
                    Expanded(
                      child: productsAsync.when(
                        data: (paginated) {
                          if (paginated.products.isEmpty) {
                            return EmptyStateView(
                              icon: Icons.search_off_rounded,
                              title: 'No Handcrafted Pieces Found',
                              message: 'We couldn\'t find any wooden items matching your current filters. Try resetting the filters or search keywords.',
                              buttonText: 'Reset Filters',
                              onButtonPressed: () {
                                _searchController.clear();
                                ref.read(shopFilterProvider.notifier).state = const ShopFilterState();
                              },
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Result count indicator
                              Text(
                                'Showing ${paginated.products.length} of ${paginated.total} artisanal items',
                                style: AppTypography.bodySmall(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 18),

                              // Products Grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 280,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: paginated.products.length,
                                itemBuilder: (context, index) {
                                  final product = paginated.products[index];
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
                              ),

                              const SizedBox(height: 36),

                              // Pagination Controls
                              if (paginated.totalPages > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left_rounded),
                                      onPressed: paginated.currentPage > 1
                                          ? () => ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(page: paginated.currentPage - 1))
                                          : null,
                                    ),
                                    Text(
                                      'Page ${paginated.currentPage} of ${paginated.totalPages}',
                                      style: AppTypography.bodyMedium(color: AppColors.espresso),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right_rounded),
                                      onPressed: paginated.currentPage < paginated.totalPages
                                          ? () => ref.read(shopFilterProvider.notifier).update((s) => s.copyWith(page: paginated.currentPage + 1))
                                          : null,
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                        loading: () => const ProductGridShimmer(count: 8),
                        error: (err, _) => ErrorRetryView(
                          message: err.toString(),
                          onRetry: () => ref.invalidate(shopProductsProvider),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.softBeige.withOpacity(0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.espresso : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, size: 16, color: AppColors.naturalWood),
            ],
          ),
        ),
      ),
    );
  }
}
