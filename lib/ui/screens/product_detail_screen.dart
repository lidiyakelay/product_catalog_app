import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/product_detail/product_detail_cubit.dart';
import '../../bloc/product_detail/product_detail_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../components/product_card.dart';
import '../components/state_widgets.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  final ProductRepository repository;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductDetailCubit(repository: repository)..loadProduct(productId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case ProductDetailStatus.initial:
              case ProductDetailStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ProductDetailStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Failed to load product',
                  onRetry: () =>
                      context.read<ProductDetailCubit>().loadProduct(productId),
                );
              case ProductDetailStatus.loaded:
                if (state.product == null) {
                  return const EmptyStateWidget(
                    title: 'No product found',
                    message: 'The requested product does not exist',
                  );
                }
                return ProductDetailContent(product: state.product!);
            }
          },
        ),
      ),
    );
  }
}

class ProductDetailContent extends StatelessWidget {
  final Product product;

  const ProductDetailContent({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          SizedBox(
            height: 280,
            child: PageView.builder(
              itemCount: product.images.isNotEmpty ? product.images.length : 1,
              itemBuilder: (context, index) {
                final imageUrl = product.images.isNotEmpty
                    ? product.images[index]
                    : product.thumbnail;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusLarge,
                    ),
                    child: Hero(
                      tag: index == 0
                          ? 'product-image-${product.id}'
                          : 'product-image-${product.id}-$index',
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: isDark
                                    ? AppColors.backgroundDark
                                    : AppColors.backgroundLight,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => _placeholder(isDark),
                            )
                          : _placeholder(isDark),
                    ),
                  ),
                );
              },
            ),
          ),

          // Product title and brand
          Text(
            product.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            product.brand,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Category chip
          Chip(
            label: Text(product.category),
            avatar: const Icon(Icons.category_outlined, size: 18),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Price section
          _PriceSection(product: product),
          const SizedBox(height: AppTheme.spacingMd),

          // Rating and stock
          Row(
            children: [
              RatingDisplay(rating: product.rating, size: 20),
              const SizedBox(width: AppTheme.spacingMd),
              StockBadge(stock: product.stock),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Description
          Text('Description', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _placeholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 60,
        color: isDark
            ? AppColors.onSurfaceVariantDark
            : AppColors.onSurfaceVariantLight,
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  final Product product;

  const _PriceSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!product.hasValidPrice) {
      return Text(
        'Price unavailable',
        style: theme.textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.errorDark : AppColors.errorLight,
        ),
      );
    }

    return Row(
      children: [
        Text(
          '\$${product.discountedPrice.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (product.discountPercentage > 0) ...[
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          DiscountBadge(percentage: product.discountPercentage),
        ],
      ],
    );
  }
}
