import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/products_response.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ProductsResponse> getProducts({int limit = 20, int skip = 0}) async {
    final data = await _apiClient.get(ApiEndpoints.products(limit: limit, skip: skip));
    return ProductsResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<ProductsResponse> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    final data = await _apiClient.get(
      ApiEndpoints.searchProducts(query, limit: limit, skip: skip),
    );
    return ProductsResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = await _apiClient.get(ApiEndpoints.categories());
    return (data as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductsResponse> getProductsByCategory(
    String slug, {
    int limit = 20,
    int skip = 0,
  }) async {
    final data = await _apiClient.get(
      ApiEndpoints.productsByCategory(slug, limit: limit, skip: skip),
    );
    return ProductsResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<ProductModel> getProductById(int id) async {
    final data = await _apiClient.get(ApiEndpoints.productById(id));
    return ProductModel.fromJson(data as Map<String, dynamic>);
  }
}
