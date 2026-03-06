import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/features/products/data/models/product_model.dart';
import '../../helpers/mock_data.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses valid JSON correctly', () {
      final product = ProductModel.fromJson(validProductJson);

      expect(product.id, 1);
      expect(product.title, 'iPhone 15 Pro');
      expect(product.description, 'Latest Apple smartphone');
      expect(product.category, 'smartphones');
      expect(product.price, 1499.99);
      expect(product.discountPercentage, 12.5);
      expect(product.rating, 4.7);
      expect(product.stock, 25);
      expect(product.brand, 'Apple');
      expect(product.thumbnail, 'https://cdn.dummyjson.com/products/images/1/thumbnail.jpg');
      expect(product.images.length, 2);
      expect(product.availabilityStatus, 'In Stock');
    });

    test('handles missing/null fields with defaults', () {
      final product = ProductModel.fromJson(missingFieldsProductJson);

      expect(product.id, 2);
      expect(product.title, 'Untitled Product');
      expect(product.description, '');
      expect(product.category, '');
      expect(product.price, isNull);
      expect(product.discountPercentage, 0.0);
      expect(product.rating, 0.0);
      expect(product.stock, 0);
      expect(product.brand, isNull);
      expect(product.thumbnail, isNull);
      expect(product.images, isEmpty);
      expect(product.availabilityStatus, 'Unknown');
    });

    test('returns null price for negative value', () {
      final product = ProductModel.fromJson(negativePriceProductJson);
      expect(product.price, isNull);
    });

    test('filters out invalid image URLs', () {
      final product = ProductModel.fromJson(invalidImagesProductJson);
      expect(product.images.length, 2);
      expect(product.images[0], 'https://valid.com/img.jpg');
      expect(product.images[1], 'https://also-valid.com/img.jpg');
    });

    test('returns null thumbnail for invalid URL', () {
      final product = ProductModel.fromJson(invalidImagesProductJson);
      expect(product.thumbnail, isNull);
    });
  });

  group('ProductModel computed properties', () {
    test('discountedPrice calculates correctly', () {
      expect(sampleProduct.discountedPrice, closeTo(1312.49, 0.01));
    });

    test('discountedPrice returns price when no discount', () {
      final product = ProductModel.fromJson({
        ...validProductJson,
        'discountPercentage': 0,
      });
      expect(product.discountedPrice, product.price);
    });

    test('discountedPrice returns null when price is null', () {
      expect(sampleProductNullPrice.discountedPrice, isNull);
    });

    test('inStock returns true when stock > 0', () {
      expect(sampleProduct.inStock, isTrue);
    });

    test('inStock returns false when stock is 0', () {
      expect(sampleProductNullPrice.inStock, isFalse);
    });
  });

  group('ProductModel equality', () {
    test('two products with same id are equal', () {
      final a = ProductModel.fromJson(validProductJson);
      final b = ProductModel.fromJson(validProductJson);
      expect(a, equals(b));
    });

    test('two products with different id are not equal', () {
      final a = ProductModel.fromJson(validProductJson);
      final b = ProductModel.fromJson({...validProductJson, 'id': 999});
      expect(a, isNot(equals(b)));
    });
  });
}
