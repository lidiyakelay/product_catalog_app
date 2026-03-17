import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';
import '../components/category_chips.dart';
import '../components/product_card.dart';
import '../components/search_bar_widget.dart';
import '../components/shimmer_loading.dart';
import '../components/state_widgets.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleProduct = Product(
      id: 1,
      title: 'Wireless Headphones',
      description: 'High quality noise-canceling headphones.',
      price: 199.99,
      discountPercentage: 15,
      rating: 4.5,
      stock: 12,
      brand: 'AudioTech',
      category: 'electronics',
      thumbnail: '',
      images: const [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          Text('Search Bar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingSm),
          SearchBarWidget(onChanged: (_) {}),
          const SizedBox(height: AppTheme.spacingLg),
          Text('Category Chips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingSm),
          const CategoryChips(
            categories: ['smartphones', 'laptops', 'fragrances'],
            selectedCategory: 'laptops',
            onSelected: _noopCategory,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text('Product Card', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingSm),
          ProductCard(product: sampleProduct),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Shimmer Skeleton',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const SizedBox(height: 150, child: ProductCardSkeleton()),
          const SizedBox(height: AppTheme.spacingLg),
          Text('State Widgets', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingSm),
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
        ],
      ),
    );
  }
}

void _noopCategory(String? _) {}
