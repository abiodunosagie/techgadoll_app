import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/products/data/models/product_model.dart';
import 'price_tag.dart';
import 'rating_bar.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final bool isSelected;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final priceLabel = product.price != null
        ? '\$${product.price!.toStringAsFixed(2)}'
        : 'Price unavailable';

    return Semantics(
      label: '${product.title}, ${product.brand ?? ''}, rated ${product.rating.toStringAsFixed(1)} out of 5, $priceLabel',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? const BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
          ),
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: Hero(
                  tag: 'product-image-${product.id}',
                  child: _buildImage(colorScheme),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.brand != null)
                      Text(
                        product.brand!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RatingBar(rating: product.rating, size: 12),
                    const SizedBox(height: 4),
                    PriceTag(
                      price: product.price,
                      discountPercentage: product.discountPercentage,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme colorScheme) {
    final placeholderColor = colorScheme.surfaceContainerHighest;
    final iconColor = colorScheme.onSurfaceVariant;

    if (product.thumbnail == null) {
      return Container(
        color: placeholderColor,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, size: 40, color: iconColor),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: product.thumbnail!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: placeholderColor,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: placeholderColor,
        child: Center(
          child: Icon(Icons.broken_image_outlined, size: 40, color: iconColor),
        ),
      ),
    );
  }
}
