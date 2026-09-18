import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final response = await apiClient.get(ApiEndpoints.categories);
  if (response['data'] is List) {
    return (response['data'] as List)
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  return [];
});
