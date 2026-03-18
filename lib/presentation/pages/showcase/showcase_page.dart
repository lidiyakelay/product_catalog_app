import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_theme.dart';
import '../../../domain/entities/product.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/state_widgets.dart';

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  String? _selectedCategory;

  static const _categories = <String>[
    'smartphones',
    'laptops',
    'home-decoration',
    'skin-care',
  ];

  static const _featuredProduct = Product(
    id: 901,
    title: 'Flagship Headphones',
    description: 'Premium audio with ANC and transparency mode.',
    price: 349.99,
    discountPercentage: 18,
    rating: 4.7,
    stock: 26,
    brand: 'Soundly',
    category: 'audio',
    thumbnail: '',
    images: [],
  );

  static const _lowStockSelectedProduct = Product(
    id: 902,
    title: 'Compact Projector',
    description: 'Portable 1080p projector with auto keystone.',
    price: 899.99,
    discountPercentage: 5,
    rating: 4.3,
    stock: 3,
    brand: 'BeamTech',
    category: 'electronics',
    thumbnail: '',
    images: [],
  );

  static const _unavailablePriceProduct = Product(
    id: 903,
    title: 'Mystery Box',
    description: 'Limited edition drop with hidden surprises.',
    price: 0,
    discountPercentage: 0,
    rating: 4.0,
    stock: 0,
    brand: 'Unknown brand',
    category: 'collectibles',
    thumbnail: '',
    images: [],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          Text(
            'Design System Playground',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Preview components and states in one place.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _SectionCard(
            title: 'Theme Toggle',
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark ||
                    (themeMode == ThemeMode.system &&
                        Theme.of(context).brightness == Brightness.dark);

                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingXs,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => context.read<ThemeCubit>().toggle(),
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      tooltip: isDark
                          ? 'Switch to light theme'
                          : 'Switch to dark theme',
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      isDark ? 'Dark theme active' : 'Light theme active',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ),
          _SectionCard(
            title: 'Search Bar',
            child: Column(
              children: [
                SearchBarWidget(
                  onChanged: (_) {},
                  hintText: 'Search products...',
                ),
                SearchBarWidget(
                  initialQuery: 'wireless mouse',
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          _SectionCard(
            title: 'Category Chips',
            child: CategoryChips(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ),
          _SectionCard(
            title: 'Product Card States',
            child: Column(
              children: const [
                ProductCard(product: _featuredProduct),
                SizedBox(height: AppTheme.spacingSm),
                ProductCard(
                  product: _lowStockSelectedProduct,
                  isSelected: true,
                ),
                SizedBox(height: AppTheme.spacingSm),
                ProductCard(product: _unavailablePriceProduct),
              ],
            ),
          ),
          _SectionCard(
            title: 'Loading States',
            child: Column(
              children: const [
                ProductCardSkeleton(),
                SizedBox(height: AppTheme.spacingSm),
                ProductCardSkeleton(),
              ],
            ),
          ),
          _SectionCard(
            title: 'Feedback States',
            child: Column(
              children: [
                const EmptyStateWidget(),
                const SizedBox(height: AppTheme.spacingMd),
                const NoSelectionWidget(),
                const SizedBox(height: AppTheme.spacingMd),
                ErrorStateWidget(
                  message: 'Unable to sync component previews.',
                  onRetry: _noop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppTheme.spacingSm),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
