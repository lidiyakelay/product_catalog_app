import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/injection_container.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../../../presentation/state_management/product_detail/product_detail_cubit.dart';
import '../../../presentation/state_management/product_detail/product_detail_state.dart';
import '../../../presentation/widgets/product_card.dart';
import '../../../presentation/widgets/state_widgets.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailCubit>()..loadProduct(productId),
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
                  onRetry: () => context
                      .read<ProductDetailCubit>()
                      .loadProduct(productId),
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

class ProductDetailContent extends StatefulWidget {
  final Product product;

  const ProductDetailContent({super.key, required this.product});

  @override
  State<ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<ProductDetailContent> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final product = widget.product;
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];

    return CustomScrollView(
      slivers: [
        // Image gallery as sliver
        SliverToBoxAdapter(
          child: _ImageGallery(
            images: images,
            productId: product.id,
            isDark: isDark,
            currentIndex: _currentImageIndex,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Title
              Text(product.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              // Brand
              Text(
                product.brand,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
              ),
              const SizedBox(height: 12),
              // Category
              Chip(
                label: Text(product.category),
                avatar: const Icon(Icons.category_outlined, size: 16),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 16),

              // Price section
              _PriceSection(product: product, isDark: isDark),
              const SizedBox(height: 16),

              // Rating & stock row
              Row(
                children: [
                  RatingDisplay(rating: product.rating, size: 20),
                  const SizedBox(width: 16),
                  Text(
                    '${product.rating.toStringAsFixed(1)} out of 5',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  StockBadge(stock: product.stock),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Text('Description', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 24),

              // Details card
              _DetailsCard(product: product, isDark: isDark),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final int productId;
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageGallery({
    required this.images,
    required this.productId,
    required this.isDark,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Hero(
                tag: index == 0
                    ? 'product-image-$productId'
                    : 'product-image-$productId-$index',
                child: _NetworkImage(url: images[index], isDark: isDark),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;
  final bool isDark;

  const _NetworkImage({required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Container(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF0F0F0),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isDark ? AppColors.surfaceDark : const Color(0xFFF0F0F0),
      child: const Icon(Icons.image_not_supported_outlined,
          size: 60, color: Colors.grey),
    );
  }
}

class _PriceSection extends StatelessWidget {
  final Product product;
  final bool isDark;

  const _PriceSection({required this.product, required this.isDark});

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

class _DetailsCard extends StatelessWidget {
  final Product product;
  final bool isDark;

  const _DetailsCard({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Details', style: theme.textTheme.titleMedium),
            const Divider(height: 20),
            _DetailRow(label: 'Brand', value: product.brand),
            _DetailRow(label: 'Category', value: product.category),
            _DetailRow(label: 'Stock', value: '${product.stock} units'),
            _DetailRow(
              label: 'Rating',
              value: '${product.rating.toStringAsFixed(1)} / 5.0',
            ),
            if (product.discountPercentage > 0)
              _DetailRow(
                label: 'Discount',
                value: '${product.discountPercentage.toStringAsFixed(0)}%',
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
