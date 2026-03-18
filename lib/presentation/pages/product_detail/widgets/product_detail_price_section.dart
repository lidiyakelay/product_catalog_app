import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../domain/entities/product.dart';

class ProductDetailPriceSection extends StatelessWidget {
  final Product product;
  final bool isDark;

  const ProductDetailPriceSection({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!product.hasValidPrice) {
      return Text(
        'Price unavailable',
        style: theme.textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.errorDark : AppColors.errorLight,
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      children: [
        Text(
          '\$${product.discountedPrice.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (product.discountPercentage > 0) ...[
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.discountDark : AppColors.discountLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
