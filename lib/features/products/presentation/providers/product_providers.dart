import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/cache/product_cache.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/products_response.dart';
import '../../data/repositories/product_repository.dart';

// -- Infrastructure providers --

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(() => client.dispose());
  return client;
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(apiClient: ref.watch(apiClientProvider));
});

// -- UI state providers --

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final selectedProductIdProvider = StateProvider<int?>((ref) => null);

// -- Data providers --

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getCategories();
});

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repo, ref);
});

final productDetailProvider =
    FutureProvider.family<ProductModel, int>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductById(id);
});

// -- Product list state --

enum ProductListStatus { initial, loading, loaded, error }

class ProductListState {
  final List<ProductModel> products;
  final ProductListStatus status;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isFromCache;
  final String errorMessage;
  final String? paginationError;

  const ProductListState({
    this.products = const [],
    this.status = ProductListStatus.initial,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isFromCache = false,
    this.errorMessage = '',
    this.paginationError,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    ProductListStatus? status,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isFromCache,
    String? errorMessage,
    String? paginationError,
  }) {
    return ProductListState(
      products: products ?? this.products,
      status: status ?? this.status,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: errorMessage ?? this.errorMessage,
      paginationError: paginationError,
    );
  }

  bool get isEmpty =>
      status == ProductListStatus.loaded && products.isEmpty;
}

// -- Product list notifier --

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repository;
  final Ref _ref;
  Timer? _debounceTimer;

  ProductListNotifier(this._repository, this._ref)
      : super(const ProductListState()) {
    _ref.listen(searchQueryProvider, (prev, next) {
      _onSearchChanged(next);
    });
    _ref.listen(selectedCategoryProvider, (prev, next) {
      _onCategoryChanged(next);
    });
    fetchProducts();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: AppConstants.debounceDurationMs),
      () => fetchProducts(),
    );
  }

  void _onCategoryChanged(String? category) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(
      status: ProductListStatus.loading,
      hasReachedMax: false,
      products: [],
      isFromCache: false,
    );

    try {
      final result = await _fetchPage(0);
      state = state.copyWith(
        status: ProductListStatus.loaded,
        products: result.response.products,
        hasReachedMax: !result.response.hasMore,
        isFromCache: result.fromCache,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductListStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _fetchPage(state.products.length);
      state = state.copyWith(
        products: [...state.products, ...result.response.products],
        hasReachedMax: !result.response.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        paginationError: 'Failed to load more products. Please try again.',
      );
    }
  }

  void clearPaginationError() {
    state = state.copyWith(paginationError: null);
  }

  Future<void> refresh() async {
    await ProductCache.clear();
    await fetchProducts();
  }

  Future<_FetchResult> _fetchPage(int skip) async {
    final query = _ref.read(searchQueryProvider);
    final category = _ref.read(selectedCategoryProvider);

    if (query.isNotEmpty && category != null) {
      final result = await _repository.searchProducts(
        query,
        limit: 100,
        skip: 0,
      );
      final filtered = result.data.products
          .where((p) => p.category == category)
          .toList();
      return _FetchResult(
        response: ProductsResponse(
          products: filtered,
          total: filtered.length,
          skip: 0,
          limit: filtered.length,
        ),
        fromCache: result.fromCache,
      );
    } else if (query.isNotEmpty) {
      final result = await _repository.searchProducts(
        query,
        limit: AppConstants.pageSize,
        skip: skip,
      );
      return _FetchResult(response: result.data, fromCache: result.fromCache);
    } else if (category != null) {
      final result = await _repository.getProductsByCategory(
        category,
        limit: AppConstants.pageSize,
        skip: skip,
      );
      return _FetchResult(response: result.data, fromCache: result.fromCache);
    } else {
      final result = await _repository.getProducts(
        limit: AppConstants.pageSize,
        skip: skip,
      );
      return _FetchResult(response: result.data, fromCache: result.fromCache);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class _FetchResult {
  final ProductsResponse response;
  final bool fromCache;

  const _FetchResult({required this.response, required this.fromCache});
}
