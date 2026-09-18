import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null && token != null;
  bool get isAdmin => user != null && user!.isAdmin;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    initAuth();
  }

  Future<void> initAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final userJson = prefs.getString(AppConstants.userKey);

      if (token != null && token.isNotEmpty) {
        apiClient.setToken(token);
        UserModel? user;
        if (userJson != null) {
          user = UserModel.fromJson(jsonDecode(userJson));
        }

        // Verify with /auth/me
        try {
          final res = await apiClient.get(ApiEndpoints.me);
          if (res['data'] != null) {
            user = UserModel.fromJson(res['data']);
            await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
          }
        } catch (_) {}

        state = AuthState(token: token, user: user, isLoading: false);
        return;
      }
    } catch (_) {}
    state = AuthState(isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiClient.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });

      final token = res['data']['token'];
      final user = UserModel.fromJson(res['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

      apiClient.setToken(token);
      state = AuthState(token: token, user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {String? phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiClient.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone ?? '',
      });

      final token = res['data']['token'];
      final user = UserModel.fromJson(res['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

      apiClient.setToken(token);
      state = AuthState(token: token, user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    apiClient.clearToken();
    state = AuthState();
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    try {
      final res = await apiClient.post(ApiEndpoints.address, data: addressData);
      if (state.user != null && res['data'] is List) {
        final updatedAddresses = (res['data'] as List)
            .map((i) => AddressModel.fromJson(i as Map<String, dynamic>))
            .toList();
        final updatedUser = UserModel(
          id: state.user!.id,
          name: state.user!.name,
          email: state.user!.email,
          role: state.user!.role,
          phone: state.user!.phone,
          avatarUrl: state.user!.avatarUrl,
          addresses: updatedAddresses,
          isActive: state.user!.isActive,
        );
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
