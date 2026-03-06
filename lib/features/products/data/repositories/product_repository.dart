import 'dart:developer' as developer;
import '../../../../core/cache/product_cache.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/products_response.dart';

class CachedResult<T> {
  final T data;
  final bool fromCache;

  const CachedResult({required this.data, required this.fromCache});
}

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<CachedResult<ProductsResponse>> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final cacheKey = 'products_${limit}_$skip';
    try {
      final data = await _apiClient.get(ApiEndpoints.products(limit: limit, skip: skip));
      final json = data as Map<String, dynamic>;
      await ProductCache.put(cacheKey, json);
      return CachedResult(data: ProductsResponse.fromJson(json), fromCache: false);
    } catch (e) {
      final cached = await ProductCache.get(cacheKey);
      if (cached != null) {
        developer.log('Serving products from cache', name: 'ProductRepository');
        return CachedResult(data: ProductsResponse.fromJson(cached), fromCache: true);
      }
      rethrow;
    }
  }

  Future<CachedResult<ProductsResponse>> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    final cacheKey = 'search_${query}_${limit}_$skip';
    try {
      final data = await _apiClient.get(
        ApiEndpoints.searchProducts(query, limit: limit, skip: skip),
      );
      final json = data as Map<String, dynamic>;
      await ProductCache.put(cacheKey, json);
      return CachedResult(data: ProductsResponse.fromJson(json), fromCache: false);
    } catch (e) {
      final cached = await ProductCache.get(cacheKey);
      if (cached != null) {
        developer.log('Serving search results from cache', name: 'ProductRepository');
        return CachedResult(data: ProductsResponse.fromJson(cached), fromCache: true);
      }
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final cacheKey = 'categories';
    try {
      final data = await _apiClient.get(ApiEndpoints.categories());
      final list = data as List<dynamic>;
      await ProductCache.put(cacheKey, {'categories': list});
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      final cached = await ProductCache.get(cacheKey);
      if (cached != null) {
        developer.log('Serving categories from cache', name: 'ProductRepository');
        return (cached['categories'] as List<dynamic>)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<CachedResult<ProductsResponse>> getProductsByCategory(
    String slug, {
    int limit = 20,
    int skip = 0,
  }) async {
    final cacheKey = 'category_${slug}_${limit}_$skip';
    try {
      final data = await _apiClient.get(
        ApiEndpoints.productsByCategory(slug, limit: limit, skip: skip),
      );
      final json = data as Map<String, dynamic>;
      await ProductCache.put(cacheKey, json);
      return CachedResult(data: ProductsResponse.fromJson(json), fromCache: false);
    } catch (e) {
      final cached = await ProductCache.get(cacheKey);
      if (cached != null) {
        developer.log('Serving category products from cache', name: 'ProductRepository');
        return CachedResult(data: ProductsResponse.fromJson(cached), fromCache: true);
      }
      rethrow;
    }
  }

  Future<ProductModel> getProductById(int id) async {
    final cacheKey = 'product_$id';
    try {
      final data = await _apiClient.get(ApiEndpoints.productById(id));
      final json = data as Map<String, dynamic>;
      await ProductCache.put(cacheKey, json);
      return ProductModel.fromJson(json);
    } catch (e) {
      final cached = await ProductCache.get(cacheKey);
      if (cached != null) {
        developer.log('Serving product $id from cache', name: 'ProductRepository');
        return ProductModel.fromJson(cached);
      }
      rethrow;
    }
  }
}
