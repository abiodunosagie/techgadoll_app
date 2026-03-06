import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;

  const RatingBar({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (rating >= starValue) {
            return Icon(Icons.star_rounded, color: AppColors.starFilled, size: size);
          } else if (rating >= starValue - 0.5) {
            return Icon(Icons.star_half_rounded, color: AppColors.starFilled, size: size);
          } else {
            return Icon(Icons.star_outline_rounded, color: AppColors.starEmpty, size: size);
          }
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.75,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
