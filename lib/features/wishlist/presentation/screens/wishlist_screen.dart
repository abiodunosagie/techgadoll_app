import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          if (wishlist.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(wishlistProvider.notifier).clear(),
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? const EmptyState(
              title: 'Your wishlist is empty',
              subtitle: 'Tap the heart on any product to save it here.',
              icon: Iconsax.heart,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = wishlist.items[index];
                final isInCart = ref.watch(cartProvider).containsProduct(product.id);

                return GestureDetector(
                  onTap: () => context.push('/products/${product.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: product.thumbnail != null
                                ? CachedNetworkImage(
                                    imageUrl: product.thumbnail!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Iconsax.gallery_slash,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Iconsax.gallery_slash,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
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
                                ),
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '\$${(product.discountedPrice ?? product.price ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(wishlistProvider.notifier).remove(product.id);
                                    },
                                    child: const Icon(
                                      Iconsax.trash,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(cartProvider.notifier).addToCart(product);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isInCart ? AppColors.primary : colorScheme.onSurface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isInCart ? 'In Cart' : 'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isInCart ? Colors.white : colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
