import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PriceTag extends StatelessWidget {
  final double? price;
  final double discountPercentage;
  final double fontSize;

  const PriceTag({
    super.key,
    required this.price,
    this.discountPercentage = 0,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (price == null) {
      return Semantics(
        label: 'Price unavailable',
        child: Text(
          'Price unavailable',
          style: TextStyle(
            fontSize: fontSize,
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final hasDiscount = discountPercentage > 0;
    final discountedPrice = hasDiscount ? price! * (1 - discountPercentage / 100) : price!;
    final semanticLabel = hasDiscount
        ? '\$${discountedPrice.toStringAsFixed(2)}, was \$${price!.toStringAsFixed(2)}, ${discountPercentage.toStringAsFixed(0)} percent off'
        : '\$${price!.toStringAsFixed(2)}';

    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '\$${discountedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          if (hasDiscount) ...[
            const SizedBox(width: 6),
            Text(
              '\$${price!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: fontSize * 0.8,
                color: colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.discountSurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${discountPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: fontSize * 0.7,
                  fontWeight: FontWeight.w600,
                  color: AppColors.discount,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
