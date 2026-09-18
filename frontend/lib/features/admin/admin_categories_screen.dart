import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../core/widgets/state_views.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../providers/category_provider.dart';

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {String? id, String? initialName, String? initialDesc}) {
    final nameCtrl = TextEditingController(text: initialName ?? '');
    final descCtrl = TextEditingController(text: initialDesc ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(id != null ? 'Edit Category' : 'Add New Category', style: AppTypography.headingSmall()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WoodTextField(label: 'Category Name', controller: nameCtrl),
            const SizedBox(height: 12),
            WoodTextField(label: 'Description', controller: descCtrl, maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              try {
                if (id != null) {
                  await apiClient.put('${ApiEndpoints.adminCategories}/$id', data: {
                    'name': name,
                    'description': descCtrl.text.trim(),
                  });
                } else {
                  await apiClient.post(ApiEndpoints.adminCategories, data: {
                    'name': name,
                    'description': descCtrl.text.trim(),
                  });
                }
                ref.invalidate(categoriesProvider);
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Categories', style: AppTypography.headingLarge(color: AppColors.espresso)),
                    const SizedBox(height: 4),
                    const Text('Manage artisanal catalog classifications and displays.'),
                  ],
                ),
                WoodButton(
                  text: 'Add Category',
                  icon: Icons.add,
                  variant: WoodButtonVariant.gold,
                  onPressed: () => _showCategoryDialog(context, ref),
                ),
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
              child: categoriesAsync.when(
                data: (cats) {
                  if (cats.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No categories found.')));
                  }

                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Category Name')),
                      DataColumn(label: Text('Slug URL')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: cats.map((cat) {
                      return DataRow(
                        cells: [
                          DataCell(Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(cat.slug)),
                          DataCell(SizedBox(width: 300, child: Text(cat.description, maxLines: 1, overflow: TextOverflow.ellipsis))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.naturalWood),
                                  onPressed: () => _showCategoryDialog(context, ref, id: cat.id, initialName: cat.name, initialDesc: cat.description),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                                  onPressed: () async {
                                    try {
                                      await apiClient.delete('${ApiEndpoints.adminCategories}/${cat.id}');
                                      ref.invalidate(categoriesProvider);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot delete: $e')));
                                    }
                                  },
                                ),
                              ],
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
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
