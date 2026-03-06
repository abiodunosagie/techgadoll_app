class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  static String products({int limit = 20, int skip = 0}) =>
      '$baseUrl/products?limit=$limit&skip=$skip';

  static String searchProducts(String query, {int limit = 20, int skip = 0}) =>
      '$baseUrl/products/search?q=$query&limit=$limit&skip=$skip';

  static String categories() => '$baseUrl/products/categories';

  static String productsByCategory(String slug, {int limit = 20, int skip = 0}) =>
      '$baseUrl/products/category/$slug?limit=$limit&skip=$skip';

  static String productById(int id) => '$baseUrl/products/$id';
}
