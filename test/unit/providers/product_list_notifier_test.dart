import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techgadoll_app/features/products/data/models/products_response.dart';
import 'package:techgadoll_app/features/products/data/repositories/product_repository.dart';
import 'package:techgadoll_app/features/products/presentation/providers/product_providers.dart';
import '../../helpers/mock_data.dart';

class MockProductRepository extends Mock implements ProductRepository {}

Future<void> pumpEventQueue() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

void main() {
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
  });

  ProviderContainer createContainer({
    String searchQuery = '',
    String? selectedCategory,
  }) {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
        searchQueryProvider.overrideWith((ref) => searchQuery),
        selectedCategoryProvider.overrideWith((ref) => selectedCategory),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ProductListNotifier', () {
    test('initial fetch loads products and transitions to loaded', () async {
      when(() => mockRepo.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => CachedResult(
          data: ProductsResponse.fromJson(validProductsResponseJson),
          fromCache: false,
        ),
      );

      final container = createContainer();
      container.read(productListProvider);
      await pumpEventQueue();

      final state = container.read(productListProvider);
      expect(state.status, ProductListStatus.loaded);
      expect(state.products.length, 1);
      expect(state.isFromCache, isFalse);
    });

    test('emits error state on fetch failure', () async {
      when(() => mockRepo.getProducts(limit: 20, skip: 0))
          .thenThrow(Exception('Network error'));

      final container = createContainer();
      container.read(productListProvider);
      await pumpEventQueue();

      final state = container.read(productListProvider);
      expect(state.status, ProductListStatus.error);
      expect(state.errorMessage, contains('Network error'));
    });

    test('loadMore appends products', () async {
      when(() => mockRepo.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => CachedResult(
          data: ProductsResponse(
            products: [sampleProduct],
            total: 2,
            skip: 0,
            limit: 20,
          ),
          fromCache: false,
        ),
      );
      when(() => mockRepo.getProducts(limit: 20, skip: 1)).thenAnswer(
        (_) async => CachedResult(
          data: ProductsResponse(
            products: [sampleProduct],
            total: 2,
            skip: 1,
            limit: 20,
          ),
          fromCache: false,
        ),
      );

      final container = createContainer();
      container.read(productListProvider);
      await pumpEventQueue();

      final notifier = container.read(productListProvider.notifier);
      await notifier.loadMore();

      final state = container.read(productListProvider);
      expect(state.products.length, 2);
    });

    test('loadMore does nothing when hasReachedMax', () async {
      when(() => mockRepo.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => CachedResult(
          data: ProductsResponse.fromJson(emptyProductsResponseJson),
          fromCache: false,
        ),
      );

      final container = createContainer();
      container.read(productListProvider);
      await pumpEventQueue();

      final stateBeforeMore = container.read(productListProvider);
      expect(stateBeforeMore.hasReachedMax, isTrue);

      final notifier = container.read(productListProvider.notifier);
      await notifier.loadMore();

      verify(() => mockRepo.getProducts(limit: 20, skip: 0)).called(1);
    });

    test('empty state when no products returned', () async {
      when(() => mockRepo.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => CachedResult(
          data: ProductsResponse.fromJson(emptyProductsResponseJson),
          fromCache: false,
        ),
      );

      final container = createContainer();
      container.read(productListProvider);
      await pumpEventQueue();

      final state = container.read(productListProvider);
      expect(state.status, ProductListStatus.loaded);
      expect(state.isEmpty, isTrue);
    });

    test('shows isFromCache when data served from cache', () async {
      when(() => mockRepo.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => CachedResult(
          data: ProductsResponse.fromJson(validProductsResponseJson),
          fromCache: true,
        ),
      );

      final container = createContainer();
      container.read(productListProvider);
      await pumpEventQueue();

      final state = container.read(productListProvider);
      expect(state.status, ProductListStatus.loaded);
      expect(state.isFromCache, isTrue);
    });
  });
}
