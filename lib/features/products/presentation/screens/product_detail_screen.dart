import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/product_providers.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_info_section.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: productAsync.whenOrNull(
          data: (product) => Text(product.title),
        ),
      ),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (product) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageGallery(images: product.images),
              ProductInfoSection(product: product),
            ],
          ),
        ),
      ),
    );
  }
}
