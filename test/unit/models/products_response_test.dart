import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/features/products/data/models/products_response.dart';
import '../../helpers/mock_data.dart';

void main() {
  group('ProductsResponse.fromJson', () {
    test('parses valid response', () {
      final response = ProductsResponse.fromJson(validProductsResponseJson);

      expect(response.products.length, 1);
      expect(response.total, 100);
      expect(response.skip, 0);
      expect(response.limit, 20);
    });

    test('hasMore returns true when more products exist', () {
      final response = ProductsResponse.fromJson(validProductsResponseJson);
      expect(response.hasMore, isTrue);
    });

    test('hasMore returns false for empty response', () {
      final response = ProductsResponse.fromJson(emptyProductsResponseJson);
      expect(response.hasMore, isFalse);
    });

    test('hasMore returns false when all loaded', () {
      final response = ProductsResponse.fromJson({
        'products': [validProductJson],
        'total': 1,
        'skip': 0,
        'limit': 20,
      });
      expect(response.hasMore, isFalse);
    });
  });
}
