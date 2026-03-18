import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/injection_container.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../../../presentation/state_management/product_detail/product_detail_bloc.dart';
import '../../../presentation/state_management/product_detail/product_detail_event.dart';
import '../../../presentation/state_management/product_detail/product_detail_state.dart';
import '../../../presentation/widgets/product_card.dart';
import '../../../presentation/widgets/state_widgets.dart';
import 'widgets/product_detail_details_card.dart';
import 'widgets/product_detail_image_gallery.dart';
import 'widgets/product_detail_price_section.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProductDetailBloc>()..add(ProductDetailRequested(productId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: BlocListener<ProductDetailBloc, ProductDetailState>(
          listener: (_, __) {},
          child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailInitial || state is ProductDetailLoading) {
                return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductDetailError) {
                return ErrorStateWidget(
                  message: state.message,
                  onRetry: () => context
                      .read<ProductDetailBloc>()
                      .add(ProductDetailRequested(productId)),
                );
            }

            if (state is ProductDetailLoaded) {
              return ProductDetailContent(product: state.product);
            }

            return const EmptyStateWidget(
              title: 'No product found',
              message: 'The requested product does not exist',
            );
          },
          ),
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
          child: ProductDetailImageGallery(
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
              Align(
                alignment: Alignment.topLeft,
                child: Chip(
                  label: Text(product.category),
                  avatar: const Icon(Icons.category_outlined, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 16),

              // Price section
              ProductDetailPriceSection(product: product, isDark: isDark),
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
              ProductDetailDetailsCard(product: product),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}
