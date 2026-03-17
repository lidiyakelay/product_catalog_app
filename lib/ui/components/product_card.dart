import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool isSelected;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 130,
          child: Row(
            children: [
              // Product image
              SizedBox(
                width: 130,
                height: 130,
                child: Hero(
                  tag: 'product-image-${product.id}',
                  child: product.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? AppColors.backgroundDark
                                : AppColors.backgroundLight,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              _buildPlaceholder(isDark),
                        )
                      : _buildPlaceholder(isDark),
                ),
              ),
              // Product info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        product.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Brand
                      Text(
                        product.brand,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Price row
                      _buildPriceRow(context, isDark),
                      const SizedBox(height: 4),
                      // Rating & stock
                      Row(
                        children: [
                          RatingDisplay(rating: product.rating, size: 14),
                          const Spacer(),
                          StockBadge(stock: product.stock),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, bool isDark) {
    if (!product.hasValidPrice) {
      return Text(
        'Price unavailable',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.errorDark : AppColors.errorLight,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      children: [
        Text(
          '\$${product.discountedPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (product.discountPercentage > 0) ...[
          const SizedBox(width: 6),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(width: 4),
          DiscountBadge(percentage: product.discountPercentage),
        ],
      ],
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      ),
    );
  }
}

/// Displays a star rating
class RatingDisplay extends StatelessWidget {
  final double rating;
  final double size;

  const RatingDisplay({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: size,
          color: isDark ? AppColors.warningDark : AppColors.warningLight,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Discount percentage badge
class DiscountBadge extends StatelessWidget {
  final double percentage;

  const DiscountBadge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? AppColors.discountDark : AppColors.discountLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '-${percentage.toStringAsFixed(0)}%',
        style: TextStyle(
          color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Stock availability badge
class StockBadge extends StatelessWidget {
  final int stock;

  const StockBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInStock = stock > 0;
    final isLowStock = stock > 0 && stock <= 5;

    Color bgColor;
    String label;

    if (!isInStock) {
      bgColor = isDark ? AppColors.errorDark : AppColors.errorLight;
      label = 'Out of stock';
    } else if (isLowStock) {
      bgColor = isDark ? AppColors.warningDark : AppColors.warningLight;
      label = 'Low stock';
    } else {
      bgColor = isDark ? AppColors.successDark : AppColors.successLight;
      label = 'In stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bgColor, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
