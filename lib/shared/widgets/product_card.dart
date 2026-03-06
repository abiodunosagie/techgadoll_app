import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/wishlist/presentation/providers/wishlist_provider.dart';
import 'price_tag.dart';
import 'rating_bar.dart';

class ProductCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInWishlist = ref.watch(wishlistProvider).contains(product.id);
    final isInCart = ref.watch(cartProvider).containsProduct(product.id);

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
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: Hero(
                        tag: 'product-image-${product.id}',
                        child: _buildImage(colorScheme),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _WishlistButton(
                        isInWishlist: isInWishlist,
                        onTap: () {
                          ref.read(wishlistProvider.notifier).toggle(product);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
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
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart ? AppColors.primary : colorScheme.onSurface,
                        foregroundColor: isInCart ? Colors.white : colorScheme.surface,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isInCart ? 'Added' : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
          child: Icon(Iconsax.gallery_slash, size: 40, color: iconColor),
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
          child: Icon(Iconsax.gallery_slash, size: 40, color: iconColor),
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final bool isInWishlist;
  final VoidCallback onTap;

  const _WishlistButton({required this.isInWishlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isInWishlist ? Iconsax.heart5 : Iconsax.heart,
              key: ValueKey(isInWishlist),
              size: 16,
              color: isInWishlist ? AppColors.error : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
