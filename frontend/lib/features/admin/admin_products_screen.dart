import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../core/widgets/state_views.dart';
import '../../providers/admin_provider.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(adminProductsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Catalog', style: AppTypography.headingLarge(color: AppColors.espresso)),
                    const SizedBox(height: 4),
                    const Text('Manage artisanal pieces, inventory levels, pricing, and media.'),
                  ],
                ),
                WoodButton(
                  text: 'Add New Product',
                  icon: Icons.add,
                  variant: WoodButtonVariant.gold,
                  onPressed: () => context.push('/admin/products/new'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search and Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warmBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: WoodTextField(
                      hint: 'Search by product title or SKU...',
                      controller: _searchCtrl,
                      prefixIcon: const Icon(Icons.search, color: AppColors.naturalWood, size: 20),
                      onSubmitted: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  WoodButton(
                    text: 'Filter',
                    variant: WoodButtonVariant.primary,
                    height: 46,
                    onPressed: () => setState(() => _searchQuery = _searchCtrl.text.trim()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Products Table
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warmBorder),
              ),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No products found.'),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Thumbnail')),
                        DataColumn(label: Text('Title & SKU')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Active')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: products.map((prod) {
                        return DataRow(
                          cells: [
                            DataCell(
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: prod.primaryImageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(prod.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('SKU: ${prod.sku}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(Text(prod.categoryName)),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(Formatters.formatCurrency(prod.discountedPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (prod.discountPercent > 0)
                                    Text(
                                      Formatters.formatCurrency(prod.price),
                                      style: const TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: AppColors.textMuted),
                                    ),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: prod.stock <= 5 ? AppColors.terracotta.withOpacity(0.15) : AppColors.successGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${prod.stock} in stock',
                                  style: TextStyle(
                                    color: prod.stock <= 5 ? AppColors.terracotta : AppColors.successGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: prod.isActive,
                                activeColor: AppColors.espresso,
                                onChanged: (val) async {
                                  await ref.read(adminActionsProvider).updateProduct(prod.id, {'isActive': val});
                                },
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.naturalWood),
                                    tooltip: 'Edit',
                                    onPressed: () => context.push('/admin/products/edit/${prod.id}'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                                    tooltip: 'Delete',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          title: const Text('Delete Product?'),
                                          content: Text('Are you sure you want to delete "${prod.title}"?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(c, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await ref.read(adminActionsProvider).deleteProduct(prod.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Product deleted successfully')),
                                        );
                                      }
                                    },
                                  ),
                                ],
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
                  onRetry: () => ref.invalidate(adminProductsProvider(_searchQuery)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
