import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;
  final bool isWishlisted;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onToggleWishlist,
    this.isWishlisted = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product.discountPercent > 0;
    final isOutOfStock = widget.product.stock <= 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('/product/${widget.product.slug.isNotEmpty ? widget.product.slug : widget.product.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? AppColors.naturalWood.withOpacity(0.5) : AppColors.warmBorder,
              width: _isHovered ? 1.2 : 0.8,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.espresso.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Badges & Wishlist Button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: Container(
                        color: AppColors.ivory,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.primaryImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.softBeige.withOpacity(0.3),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.naturalWood),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.softBeige.withOpacity(0.4),
                            child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top Left Badges (Sale / Bestseller / New)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.espresso,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${widget.product.discountPercent}%',
                              style: AppTypography.buttonText(color: Colors.white).copyWith(fontSize: 11),
                            ),
                          ),
                        if (widget.product.isBestseller)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.antiqueGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BESTSELLER',
                              style: AppTypography.buttonText(color: AppColors.espresso).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Top Right Wishlist Toggle
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: widget.onToggleWishlist,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: widget.isWishlisted ? AppColors.terracotta : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Out of Stock Overlay
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.espresso,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OUT OF STOCK',
                              style: AppTypography.buttonText(color: Colors.white).copyWith(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product Info Body
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.categoryName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(color: AppColors.naturalWood).copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.antiqueGold),
                            const SizedBox(width: 2),
                            Text(
                              widget.product.ratingsAverage.toStringAsFixed(1),
                              style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      widget.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingSmall(color: AppColors.textPrimary).copyWith(
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Wood Material Tag
                    Text(
                      widget.product.material,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(color: AppColors.textMuted).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 10),

                    // Price and Add to Cart Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount)
                                Text(
                                  Formatters.formatCurrency(widget.product.price),
                                  style: AppTypography.priceStrikeThrough(),
                                ),
                              Text(
                                Formatters.formatCurrency(widget.product.discountedPrice),
                                style: AppTypography.priceMedium(color: AppColors.espresso),
                              ),
                            ],
                          ),
                        ),
                        if (!isOutOfStock && widget.onAddToCart != null)
                          Material(
                            color: AppColors.espresso,
                            borderRadius: BorderRadius.circular(6),
                            child: InkWell(
                              onTap: widget.onAddToCart,
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
