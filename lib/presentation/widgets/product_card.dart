import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/entities/product.dart';

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: isSelected ? 4 : 1,
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
            height: 136,
            child: Row(
              children: [
                _ProductImage(product: product, isDark: isDark),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
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
                        const SizedBox(height: 4),
                        _CategoryBadge(category: product.category),
                        const Spacer(),
                        _PriceRow(product: product, isDark: isDark),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            RatingDisplay(rating: product.rating, size: 13),
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
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final Product product;
  final bool isDark;

  const _ProductImage({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      height: 136,
      child: Hero(
        tag: 'product-image-${product.id}',
        child: product.thumbnail.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? AppColors.surfaceDark : const Color(0xFFF0F0F0),
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final Product product;
  final bool isDark;

  const _PriceRow({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!product.hasValidPrice) {
      return Text(
        'Price unavailable',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final hasDiscount = product.discountPercentage > 0;
    final discountBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: isDark ? AppColors.discountDark : AppColors.discountLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '-${product.discountPercentage.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 220;

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${product.discountedPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          fontSize: isTight ? 15 : null,
                        ),
                      ),
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                          fontSize: isTight ? 10 : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 4),
              discountBadge,
            ],
          ],
        );
      },
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final double rating;
  final double size;

  const RatingDisplay({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: AppColors.warningLight),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 1,
            fontWeight: FontWeight.w600,
            color: AppColors.warningLight,
          ),
        ),
      ],
    );
  }
}

class StockBadge extends StatelessWidget {
  final int stock;

  const StockBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (stock <= 0) {
      return _badge('Out of Stock',
          isDark ? AppColors.errorDark : AppColors.errorLight);
    }
    if (stock <= 5) {
      return _badge(
        'Only $stock left',
        isDark ? AppColors.warningDark : AppColors.warningLight,
        textColor: Colors.black87,
      );
    }
    return _badge(
      'In Stock',
      isDark ? AppColors.successDark : AppColors.successLight,
    );
  }

  Widget _badge(String text, Color color, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor ?? color,
        ),
      ),
    );
  }
}
