import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/product_model.dart';

// Home Screen Feature Providers
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final response = await apiClient.get(ApiEndpoints.featuredProducts, queryParameters: {'limit': 8});
  if (response['data'] is List) {
    return (response['data'] as List)
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return [];
});

final newArrivalsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final response = await apiClient.get(ApiEndpoints.newArrivals, queryParameters: {'limit': 8});
  if (response['data'] is List) {
    return (response['data'] as List)
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return [];
});

final bestsellersProvider = FutureProvider<List<ProductModel>>((ref) async {
  final response = await apiClient.get(ApiEndpoints.bestsellers, queryParameters: {'limit': 8});
  if (response['data'] is List) {
    return (response['data'] as List)
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return [];
});

// Single Product Details Provider
final productDetailsProvider = FutureProvider.family<ProductModel, String>((ref, slugOrId) async {
  final endpoint = slugOrId.length == 24
      ? '${ApiEndpoints.products}/$slugOrId'
      : '${ApiEndpoints.productBySlug}/$slugOrId';
  final response = await apiClient.get(endpoint);
  return ProductModel.fromJson(response['data']);
});

// Related Products Provider
final relatedProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, id) async {
  final response = await apiClient.get('${ApiEndpoints.relatedProducts}/$id');
  if (response['data'] is List) {
    return (response['data'] as List)
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return [];
});

// Shop Filtering State
class ShopFilterState {
  final String search;
  final String? categorySlug;
  final num? minPrice;
  final num? maxPrice;
  final bool inStock;
  final String sort;
  final int page;
  final int limit;

  const ShopFilterState({
    this.search = '',
    this.categorySlug,
    this.minPrice,
    this.maxPrice,
    this.inStock = false,
    this.sort = 'newest',
    this.page = 1,
    this.limit = 12,
  });

  ShopFilterState copyWith({
    String? search,
    String? categorySlug,
    num? minPrice,
    num? maxPrice,
    bool? inStock,
    String? sort,
    int? page,
    int? limit,
  }) {
    return ShopFilterState(
      search: search ?? this.search,
      categorySlug: categorySlug ?? this.categorySlug,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStock: inStock ?? this.inStock,
      sort: sort ?? this.sort,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
      'sort': sort,
    };
    if (search.isNotEmpty) params['search'] = search;
    if (categorySlug != null && categorySlug!.isNotEmpty && categorySlug != 'all') {
      params['category'] = categorySlug;
    }
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (inStock) params['inStock'] = 'true';
    return params;
  }
}

class PaginatedProductsResponse {
  final List<ProductModel> products;
  final int total;
  final int totalPages;
  final int currentPage;

  PaginatedProductsResponse({
    required this.products,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });
}

final shopFilterProvider = StateProvider<ShopFilterState>((ref) {
  return const ShopFilterState();
});

final shopProductsProvider = FutureProvider<PaginatedProductsResponse>((ref) async {
  final filter = ref.watch(shopFilterProvider);
  final response = await apiClient.get(ApiEndpoints.products, queryParameters: filter.toQueryParams());

  List<ProductModel> prods = [];
  if (response['data'] is List) {
    prods = (response['data'] as List)
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  final pagination = response['pagination'] ?? {};
  return PaginatedProductsResponse(
    products: prods,
    total: pagination['total'] ?? prods.length,
    totalPages: pagination['totalPages'] ?? 1,
    currentPage: pagination['page'] ?? 1,
  );
});
