import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/cart_model.dart';
import 'auth_provider.dart';

class CartNotifier extends StateNotifier<AsyncValue<CartModel?>> {
  final Ref ref;

  CartNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      state = AsyncValue.data(CartModel(id: 'guest', items: []));
      return;
    }

    try {
      final response = await apiClient.get(ApiEndpoints.cart);
      final cart = CartModel.fromJson(response['data']);
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Please sign in to add items to your cart.');
    }

    try {
      final response = await apiClient.post(ApiEndpoints.cartAdd, data: {
        'productId': productId,
        'quantity': quantity,
      });
      final updatedCart = CartModel.fromJson(response['data']);
      state = AsyncValue.data(updatedCart);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final response = await apiClient.put(ApiEndpoints.cartUpdate, data: {
        'productId': productId,
        'quantity': quantity,
      });
      final updatedCart = CartModel.fromJson(response['data']);
      state = AsyncValue.data(updatedCart);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final response = await apiClient.delete('${ApiEndpoints.cartRemove}/$productId');
      final updatedCart = CartModel.fromJson(response['data']);
      state = AsyncValue.data(updatedCart);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await apiClient.delete(ApiEndpoints.cartClear);
      state = AsyncValue.data(CartModel(id: '', items: []));
    } catch (e) {
      rethrow;
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<CartModel?>>((ref) {
  return CartNotifier(ref);
});
