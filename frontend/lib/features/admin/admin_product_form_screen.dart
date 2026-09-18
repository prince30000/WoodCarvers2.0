import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/products_provider.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  final String? productId; // Null when adding a new product

  const AdminProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  final _stockCtrl = TextEditingController(text: '10');
  final _materialCtrl = TextEditingController(text: 'Seasoned Dark Walnut Wood');
  final _lengthCtrl = TextEditingController(text: '20');
  final _widthCtrl = TextEditingController(text: '15');
  final _heightCtrl = TextEditingController(text: '10');
  final _weightCtrl = TextEditingController(text: '800');
  final _imageUrlCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String? _selectedCategoryId;
  bool _isFeatured = false;
  bool _isBestseller = false;
  bool _isNewArrival = true;
  List<ProductImage> _images = [];
  bool _isSaving = false;
  bool _isLoadingProduct = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductData();
    } else {
      _images.add(ProductImage(
        url: 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80',
        isPrimary: true,
      ));
    }
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoadingProduct = true);
    try {
      final product = await ref.read(productDetailsProvider(widget.productId!).future);
      _titleCtrl.text = product.title;
      _skuCtrl.text = product.sku;
      _descCtrl.text = product.description;
      _priceCtrl.text = product.price.toString();
      _discountCtrl.text = product.discountPercent.toString();
      _stockCtrl.text = product.stock.toString();
      _materialCtrl.text = product.material;
      _lengthCtrl.text = (product.dimensions['length'] ?? 0).toString();
      _widthCtrl.text = (product.dimensions['width'] ?? 0).toString();
      _heightCtrl.text = (product.dimensions['height'] ?? 0).toString();
      _weightCtrl.text = (product.weight['value'] ?? 0).toString();
      _tagsCtrl.text = product.tags.join(', ');
      _isFeatured = product.isFeatured;
      _isBestseller = product.isBestseller;
      _isNewArrival = product.isNewArrival;
      _images = List.from(product.images);
      if (product.category != null) {
        _selectedCategoryId = product.category is Map ? product.category['_id'] : product.category.toString();
      }
    } catch (_) {}
    setState(() => _isLoadingProduct = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _stockCtrl.dispose();
    _materialCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _imageUrlCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _addImageUrl() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _images.add(ProductImage(url: url, isPrimary: _images.isEmpty));
        _imageUrlCtrl.clear();
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach at least one product image')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final categories = ref.read(categoriesProvider).value ?? [];
      final categoryId = _selectedCategoryId ?? (categories.isNotEmpty ? categories.first.id : '');

      final payload = {
        'title': _titleCtrl.text.trim(),
        'sku': _skuCtrl.text.trim().toUpperCase(),
        'description': _descCtrl.text.trim(),
        'category': categoryId,
        'price': num.tryParse(_priceCtrl.text) ?? 0,
        'discountPercent': num.tryParse(_discountCtrl.text) ?? 0,
        'stock': int.tryParse(_stockCtrl.text) ?? 0,
        'material': _materialCtrl.text.trim(),
        'dimensions': {
          'length': num.tryParse(_lengthCtrl.text) ?? 0,
          'width': num.tryParse(_widthCtrl.text) ?? 0,
          'height': num.tryParse(_heightCtrl.text) ?? 0,
          'unit': 'cm',
        },
        'weight': {
          'value': num.tryParse(_weightCtrl.text) ?? 0,
          'unit': 'g',
        },
        'tags': _tagsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'isFeatured': _isFeatured,
        'isBestseller': _isBestseller,
        'isNewArrival': _isNewArrival,
        'images': _images.map((img) => img.toJson()).toList(),
      };

      final adminActions = ref.read(adminActionsProvider);
      if (widget.productId != null) {
        await adminActions.updateProduct(widget.productId!, payload);
      } else {
        await adminActions.createProduct(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.productId != null ? 'Product updated successfully' : 'Product created successfully')),
        );
        context.go('/admin/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    if (_isLoadingProduct) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productId != null ? 'Edit Wooden Product' : 'Add New Wooden Product',
                        style: AppTypography.headingLarge(color: AppColors.espresso),
                      ),
                      const SizedBox(height: 4),
                      const Text('Fill out product craftsmanship specifications and manage Cloudinary media.'),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go('/admin/products'),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      WoodButton(
                        text: widget.productId != null ? 'Save Changes' : 'Publish Product',
                        variant: WoodButtonVariant.gold,
                        isLoading: _isSaving,
                        onPressed: _handleSave,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Form Cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Core info
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
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
                              Text('Basic Information', style: AppTypography.headingSmall()),
                              const SizedBox(height: 16),
                              WoodTextField(
                                label: 'Product Title *',
                                hint: 'e.g. Hand-Carved Walnut Tree of Life Wall Medallion',
                                controller: _titleCtrl,
                                validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'SKU Identifier *',
                                      hint: 'e.g. WC-WH-004',
                                      controller: _skuCtrl,
                                      validator: (v) => v?.isEmpty == true ? 'SKU is required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: categoriesAsync.when(
                                      data: (cats) {
                                        if (_selectedCategoryId == null && cats.isNotEmpty) {
                                          _selectedCategoryId = cats.first.id;
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Category *', style: AppTypography.headingSmall().copyWith(fontSize: 13)),
                                            const SizedBox(height: 6),
                                            DropdownButtonFormField<String>(
                                              value: _selectedCategoryId,
                                              items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                                              onChanged: (v) => setState(() => _selectedCategoryId = v),
                                              decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                                            ),
                                          ],
                                        );
                                      },
                                      loading: () => const SizedBox(),
                                      error: (_, __) => const SizedBox(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              WoodTextField(
                                label: 'Description *',
                                hint: 'Artisanal description of the piece, motif inspiration, chisel techniques...',
                                controller: _descCtrl,
                                maxLines: 5,
                                validator: (v) => v?.isEmpty == true ? 'Description is required' : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Pricing & Stock
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
                              Text('Pricing & Inventory', style: AppTypography.headingSmall()),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Regular Price (INR ₹) *',
                                      hint: 'e.g. 2999',
                                      controller: _priceCtrl,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v?.isEmpty == true ? 'Price required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Discount Percent (%)',
                                      hint: '0 to 90',
                                      controller: _discountCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Stock Quantity *',
                                      hint: 'Available inventory',
                                      controller: _stockCtrl,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v?.isEmpty == true ? 'Stock required' : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Specifications
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
                              Text('Wood Craftsmanship Specs', style: AppTypography.headingSmall()),
                              const SizedBox(height: 16),
                              WoodTextField(
                                label: 'Timber Material',
                                hint: 'e.g. Seasoned Dark Walnut, Natural Teak',
                                controller: _materialCtrl,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Length (cm)',
                                      controller: _lengthCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Width (cm)',
                                      controller: _widthCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Height (cm)',
                                      controller: _heightCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Weight (g)',
                                      controller: _weightCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              WoodTextField(
                                label: 'Search Tags (comma separated)',
                                hint: 'wall art, walnut, tree of life, carved',
                                controller: _tagsCtrl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right: Cloudinary Images & Badges
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // Media Manager
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
                              Text('Product Photography (Cloudinary)', style: AppTypography.headingSmall()),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: WoodTextField(
                                      hint: 'Enter Image URL or Cloudinary CDN link',
                                      controller: _imageUrlCtrl,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  WoodButton(
                                    text: 'Add',
                                    height: 46,
                                    onPressed: _addImageUrl,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_images.isEmpty)
                                const Text('No images attached yet.', style: TextStyle(color: AppColors.textMuted))
                              else
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _images.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final img = entry.value;

                                    return Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: img.isPrimary ? AppColors.naturalWood : AppColors.warmBorder,
                                              width: img.isPrimary ? 2 : 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl: img.url,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() => _images.removeAt(idx));
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close, size: 14, color: AppColors.errorRed),
                                            ),
                                          ),
                                        ),
                                        if (img.isPrimary)
                                          Positioned(
                                            bottom: 2,
                                            left: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.naturalWood,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: const Text('Primary', style: TextStyle(color: Colors.white, fontSize: 9)),
                                            ),
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Badges & Visibility
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
                              Text('Status & Promotional Flags', style: AppTypography.headingSmall()),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                title: const Text('Featured Product'),
                                subtitle: const Text('Highlighted in home carousel', style: TextStyle(fontSize: 12)),
                                value: _isFeatured,
                                activeColor: AppColors.espresso,
                                onChanged: (v) => setState(() => _isFeatured = v),
                              ),
                              SwitchListTile(
                                title: const Text('Bestseller'),
                                subtitle: const Text('Shows gold Bestseller badge', style: TextStyle(fontSize: 12)),
                                value: _isBestseller,
                                activeColor: AppColors.antiqueGold,
                                onChanged: (v) => setState(() => _isBestseller = v),
                              ),
                              SwitchListTile(
                                title: const Text('New Arrival'),
                                subtitle: const Text('Flagged as fresh from the wood studio', style: TextStyle(fontSize: 12)),
                                value: _isNewArrival,
                                activeColor: AppColors.forestSage,
                                onChanged: (v) => setState(() => _isNewArrival = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
