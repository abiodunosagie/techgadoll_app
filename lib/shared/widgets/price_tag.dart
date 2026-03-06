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
    if (price == null) {
      return Text(
        'Price unavailable',
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final hasDiscount = discountPercentage > 0;
    final discountedPrice = hasDiscount ? price! * (1 - discountPercentage / 100) : price!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '\$${discountedPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 6),
          Text(
            '\$${price!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize * 0.8,
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textTertiary,
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
    );
  }
}
