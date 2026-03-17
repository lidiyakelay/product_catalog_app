import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../../../presentation/state_management/theme/theme_cubit.dart';
import '../../../presentation/widgets/category_chips.dart';
import '../../../presentation/widgets/product_card.dart';
import '../../../presentation/widgets/search_bar_widget.dart';
import '../../../presentation/widgets/shimmer_loading.dart';
import '../../../presentation/widgets/state_widgets.dart';

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    const sampleProduct = Product(
      id: 1,
      title: 'Wireless Headphones Pro',
      description: 'High quality noise-canceling wireless headphones.',
      price: 199.99,
      discountPercentage: 15,
      rating: 4.5,
      stock: 12,
      brand: 'AudioTech',
      category: 'electronics',
      thumbnail: '',
      images: [],
    );

    const outOfStockProduct = Product(
      id: 2,
      title: 'Limited Edition Watch',
      description: 'Luxury watch.',
      price: 499.99,
      discountPercentage: 0,
      rating: 4.8,
      stock: 0,
      brand: 'TimeX',
      category: 'watches',
      thumbnail: '',
      images: [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeCubit>().toggle(),
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          _SectionHeader('Search Bar'),
          SearchBarWidget(onChanged: (_) {}),
          _SectionHeader('Category Chips'),
          const CategoryChips(
            categories: ['smartphones', 'laptops', 'fragrances', 'watches'],
            selectedCategory: 'laptops',
            onSelected: _noop,
          ),
          _SectionHeader('Product Cards'),
          ProductCard(product: sampleProduct),
          const SizedBox(height: AppTheme.spacingSm),
          ProductCard(product: sampleProduct, isSelected: true),
          const SizedBox(height: AppTheme.spacingSm),
          ProductCard(product: outOfStockProduct),
          _SectionHeader('Shimmer Skeleton'),
          const SizedBox(height: 150, child: ProductCardSkeleton()),
          _SectionHeader('State Widgets'),
          const SizedBox(height: 180, child: EmptyStateWidget()),
          const SizedBox(height: AppTheme.spacingSm),
          const SizedBox(height: 180, child: NoSelectionWidget()),
          const SizedBox(height: AppTheme.spacingSm),
          SizedBox(
            height: 200,
            child: ErrorStateWidget(
              message: 'Example error message',
              onRetry: () {},
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.spacingLg,
        bottom: AppTheme.spacingSm,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

void _noop(String? _) {}
