import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/products/data/models/product_model.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/price_tag.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/rating_bar.dart';
import '../../../../shared/widgets/app_search_bar.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final theme = _isDark ? AppTheme.dark() : AppTheme.light();

    return Theme(
      data: theme,
      child: Builder(
        builder: (themedContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Component Showcase'),
              actions: [
                IconButton(
                  icon: Icon(_isDark ? Iconsax.sun_1 : Iconsax.moon),
                  onPressed: () => setState(() => _isDark = !_isDark),
                  tooltip: 'Toggle theme',
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _section(themedContext, 'RatingBar'),
                const Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    RatingBar(rating: 5.0),
                    RatingBar(rating: 3.5),
                    RatingBar(rating: 1.0),
                    RatingBar(rating: 0.0),
                    RatingBar(rating: 4.2, reviewCount: 128),
                  ],
                ),
                _divider(),

                _section(themedContext, 'PriceTag'),
                const Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    PriceTag(price: 49.99),
                    PriceTag(price: 99.99, discountPercentage: 20),
                    PriceTag(price: null),
                  ],
                ),
                const SizedBox(height: 8),
                const PriceTag(price: 1299.99, discountPercentage: 15.5, fontSize: 20),
                _divider(),

                _section(themedContext, 'CategoryChip'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    CategoryChip(label: 'All', isSelected: true, onTap: () {}),
                    CategoryChip(label: 'Electronics', isSelected: false, onTap: () {}),
                    CategoryChip(label: 'Furniture', isSelected: false, onTap: () {}),
                    CategoryChip(label: 'Fragrances', isSelected: false, onTap: () {}),
                  ],
                ),
                _divider(),

                _section(themedContext, 'AppSearchBar'),
                AppSearchBar(onChanged: (_) {}),
                _divider(),

                _section(themedContext, 'ErrorState'),
                SizedBox(
                  height: 300,
                  child: ErrorState(
                    message: 'Failed to load products. Please check your connection.',
                    onRetry: () {},
                  ),
                ),
                _divider(),

                _section(themedContext, 'EmptyState'),
                const SizedBox(
                  height: 240,
                  child: EmptyState(
                    title: 'No products found',
                    subtitle: 'Try adjusting your search or filter.',
                  ),
                ),
                _divider(),

                _section(themedContext, 'LoadingShimmer'),
                const SizedBox(
                  height: 400,
                  child: LoadingShimmer(itemCount: 4),
                ),
                _divider(),

                _section(themedContext, 'ProductCard'),
                SizedBox(
                  height: 320,
                  child: Row(
                    children: [
                      Expanded(
                        child: ProductCard(
                          product: _sampleProduct,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProductCard(
                          product: _sampleProductNoDiscount,
                          onTap: () {},
                          isSelected: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(BuildContext themedContext, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(themedContext).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1),
    );
  }

  static const _sampleProduct = ProductModel(
    id: 1,
    title: 'iPhone 15 Pro Max',
    description: 'The latest iPhone with advanced features.',
    category: 'smartphones',
    price: 1499.99,
    discountPercentage: 12.5,
    rating: 4.7,
    stock: 25,
    brand: 'Apple',
    thumbnail: 'https://cdn.dummyjson.com/products/images/smartphones/iPhone%2015%20Pro%20Max/thumbnail.png',
    images: [],
    availabilityStatus: 'In Stock',
  );

  static const _sampleProductNoDiscount = ProductModel(
    id: 2,
    title: 'Samsung Galaxy S24',
    description: 'Premium Samsung smartphone.',
    category: 'smartphones',
    price: 899.99,
    discountPercentage: 0,
    rating: 4.3,
    stock: 0,
    brand: 'Samsung',
    thumbnail: 'https://cdn.dummyjson.com/products/images/smartphones/Samsung%20Galaxy%20S24/thumbnail.png',
    images: [],
    availabilityStatus: 'Out of Stock',
  );
}
