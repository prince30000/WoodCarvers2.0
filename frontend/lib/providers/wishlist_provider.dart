import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/product_model.dart';
import 'auth_provider.dart';

class WishlistNotifier extends StateNotifier<List<ProductModel>> {
  final Ref ref;

  WishlistNotifier(this.ref) : super([]) {
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      state = [];
      return;
    }

    try {
      final response = await apiClient.get(ApiEndpoints.wishlist);
      if (response['data'] is List) {
        state = (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> toggle(String productId) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Please sign in to save items to your wishlist.');
    }

    try {
      final response = await apiClient.post(ApiEndpoints.wishlistToggle, data: {'productId': productId});
      if (response['data'] != null && response['data']['products'] is List) {
        state = (response['data']['products'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  bool contains(String productId) {
    return state.any((prod) => prod.id == productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<ProductModel>>((ref) {
  return WishlistNotifier(ref);
});
