import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/product_card.dart';
import '../providers/product_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final bool isTabletLeftPane;
  final ValueChanged<int>? onProductSelected;

  const ProductListScreen({
    super.key,
    this.isTabletLeftPane = false,
    this.onProductSelected,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  void _onProductTap(int productId) {
    if (widget.onProductSelected != null) {
      widget.onProductSelected!(productId);
    } else {
      context.push('/products/$productId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productListState = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedProductId = ref.watch(selectedProductIdProvider);

    // Listen for pagination errors and show snackbar
    ref.listen<ProductListState>(productListProvider, (prev, next) {
      if (next.paginationError != null && prev?.paginationError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.paginationError!),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                ref.read(productListProvider.notifier).clearPaginationError();
                ref.read(productListProvider.notifier).loadMore();
              },
            ),
          ),
        );
        ref.read(productListProvider.notifier).clearPaginationError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Semantics(
              label: 'Search products',
              textField: true,
              child: AppSearchBar(
                initialValue: searchQuery,
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 48,
            child: categoriesAsync.when(
              data: (categories) => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CategoryChip(
                        label: 'All',
                        isSelected: selectedCategory == null,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        },
                      ),
                    );
                  }
                  final cat = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(
                      label: cat.name,
                      isSelected: selectedCategory == cat.slug,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            cat.slug;
                      },
                    ),
                  );
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Cache indicator
          if (productListState.isFromCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.warning.withValues(alpha: 0.15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 14, color: AppColors.warning.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  Text(
                    'Showing cached data',
                    style: TextStyle(fontSize: 12, color: AppColors.warning.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Product grid
          Expanded(
            child: _buildProductContent(
              productListState,
              selectedProductId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductContent(
    ProductListState listState,
    int? selectedProductId,
  ) {
    switch (listState.status) {
      case ProductListStatus.initial:
      case ProductListStatus.loading:
        return const LoadingShimmer();

      case ProductListStatus.error:
        return ErrorState(
          message: listState.errorMessage,
          onRetry: () => ref.read(productListProvider.notifier).fetchProducts(),
        );

      case ProductListStatus.loaded:
        if (listState.isEmpty) {
          return const EmptyState(
            title: 'No products found',
            subtitle: 'Try adjusting your search or filter.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(productListProvider.notifier).refresh(),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.isTabletLeftPane ? 1 : 2,
              childAspectRatio: widget.isTabletLeftPane ? 2.5 : 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: listState.products.length + (listState.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == listState.products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final product = listState.products[index];
              return _StaggeredFadeIn(
                index: index,
                child: ProductCard(
                  product: product,
                  isSelected: product.id == selectedProductId,
                  onTap: () => _onProductTap(product.id),
                ),
              );
            },
          ),
        );
    }
  }
}

class _StaggeredFadeIn extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredFadeIn({required this.index, required this.child});

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger the animation based on index, capped to avoid long waits
    final delay = Duration(milliseconds: (widget.index % 6) * 60);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
