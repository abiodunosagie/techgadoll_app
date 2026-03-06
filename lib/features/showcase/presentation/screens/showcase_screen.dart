import 'package:flutter/material.dart';
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
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final theme = _themeMode == ThemeMode.dark
        ? ThemeData.dark(useMaterial3: true)
        : Theme.of(context);

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Showcase'),
          actions: [
            IconButton(
              icon: Icon(
                _themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
              tooltip: 'Toggle theme',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('RatingBar'),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                RatingBar(rating: 5.0),
                RatingBar(rating: 3.5),
                RatingBar(rating: 1.0),
                RatingBar(rating: 0.0),
                RatingBar(rating: 4.2, reviewCount: 128),
              ],
            ),
            const Divider(height: 32),

            _sectionTitle('PriceTag'),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                PriceTag(price: 49.99),
                PriceTag(price: 99.99, discountPercentage: 20),
                PriceTag(price: null),
                PriceTag(price: 1299.99, discountPercentage: 15.5, fontSize: 20),
              ],
            ),
            const Divider(height: 32),

            _sectionTitle('CategoryChip'),
            const SizedBox(height: 8),
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
            const Divider(height: 32),

            _sectionTitle('AppSearchBar'),
            const SizedBox(height: 8),
            AppSearchBar(onChanged: (_) {}),
            const Divider(height: 32),

            _sectionTitle('ErrorState'),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ErrorState(
                message: 'Failed to load products. Please check your connection.',
                onRetry: () {},
              ),
            ),
            const Divider(height: 32),

            _sectionTitle('EmptyState'),
            const SizedBox(height: 8),
            const SizedBox(
              height: 200,
              child: EmptyState(
                title: 'No products found',
                subtitle: 'Try adjusting your search or filter.',
              ),
            ),
            const Divider(height: 32),

            _sectionTitle('LoadingShimmer'),
            const SizedBox(height: 8),
            const SizedBox(
              height: 400,
              child: LoadingShimmer(itemCount: 4),
            ),
            const Divider(height: 32),

            _sectionTitle('ProductCard'),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
