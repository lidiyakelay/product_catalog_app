import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/product_detail/product_detail_cubit.dart';
import '../../bloc/product_detail/product_detail_state.dart';
import '../../bloc/product_list/product_list_bloc.dart';
import '../../bloc/product_list/product_list_event.dart';
import '../../bloc/product_list/product_list_state.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/product_repository.dart';
import '../components/category_chips.dart';
import '../components/product_card.dart';
import '../components/search_bar_widget.dart';
import '../components/shimmer_loading.dart';
import '../components/state_widgets.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final ProductRepository repository;
  final int? selectedProductId;

  const ProductListScreen({
    super.key,
    required this.repository,
    this.selectedProductId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final ScrollController _scrollController;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.selectedProductId;
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ProductListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProductId != oldWidget.selectedProductId) {
      _selectedProductId = widget.selectedProductId;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent * 0.9;
    if (_scrollController.position.pixels >= threshold) {
      context.read<ProductListBloc>().add(const ProductListNextPageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductListBloc(repository: widget.repository)
            ..add(const ProductListCategoriesFetched())
            ..add(const ProductListFetched()),
        ),
        if (isWide)
          BlocProvider(
            create: (_) =>
                ProductDetailCubit(repository: widget.repository)
                  ..loadProduct(_selectedProductId ?? 1),
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Catalog'),
          actions: [
            IconButton(
              onPressed: () => context.push('/showcase'),
              icon: const Icon(Icons.view_quilt_outlined),
              tooltip: 'Design System Showcase',
            ),
          ],
        ),
        body: isWide ? _buildWideLayout(context) : _buildPhoneLayout(context),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ProductListBloc, ProductListState>(
          builder: (context, state) {
            return SearchBarWidget(
              initialQuery: state.searchQuery,
              onChanged: (query) {
                context.read<ProductListBloc>().add(
                  ProductListSearchChanged(query),
                );
              },
            );
          },
        ),
        BlocBuilder<ProductListBloc, ProductListState>(
          builder: (context, state) {
            return CategoryChips(
              categories: state.categories,
              selectedCategory: state.selectedCategory,
              onSelected: (category) {
                context.read<ProductListBloc>().add(
                  ProductListCategorySelected(category),
                );
              },
            );
          },
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Expanded(
          child: _ProductListContent(
            scrollController: _scrollController,
            onProductTap: (id) => context.push('/products/$id'),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              BlocBuilder<ProductListBloc, ProductListState>(
                builder: (context, state) {
                  return SearchBarWidget(
                    initialQuery: state.searchQuery,
                    onChanged: (query) {
                      context.read<ProductListBloc>().add(
                        ProductListSearchChanged(query),
                      );
                    },
                  );
                },
              ),
              BlocBuilder<ProductListBloc, ProductListState>(
                builder: (context, state) {
                  return CategoryChips(
                    categories: state.categories,
                    selectedCategory: state.selectedCategory,
                    onSelected: (category) {
                      context.read<ProductListBloc>().add(
                        ProductListCategorySelected(category),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Expanded(
                child: _ProductListContent(
                  scrollController: _scrollController,
                  selectedProductId: _selectedProductId,
                  onProductTap: (id) {
                    setState(() {
                      _selectedProductId = id;
                    });
                    context.read<ProductDetailCubit>().loadProduct(id);
                    context.go('/products?selected=$id');
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedProductId == null
              ? const NoSelectionWidget()
              : BlocBuilder<ProductDetailCubit, ProductDetailState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case ProductDetailStatus.initial:
                      case ProductDetailStatus.loading:
                        return const Center(child: CircularProgressIndicator());
                      case ProductDetailStatus.error:
                        return ErrorStateWidget(
                          message:
                              state.errorMessage ?? 'Failed to load product',
                          onRetry: () => context
                              .read<ProductDetailCubit>()
                              .loadProduct(_selectedProductId!),
                        );
                      case ProductDetailStatus.loaded:
                        if (state.product == null) {
                          return const NoSelectionWidget();
                        }
                        return ProductDetailContent(product: state.product!);
                    }
                  },
                ),
        ),
      ],
    );
  }
}

class _ProductListContent extends StatelessWidget {
  final ScrollController scrollController;
  final ValueChanged<int> onProductTap;
  final int? selectedProductId;

  const _ProductListContent({
    required this.scrollController,
    required this.onProductTap,
    this.selectedProductId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        if (state.status == ProductListStatus.loading &&
            state.products.isEmpty) {
          return const ShimmerLoadingList();
        }

        if (state.status == ProductListStatus.error && state.products.isEmpty) {
          return ErrorStateWidget(
            message: state.errorMessage ?? 'Failed to load products',
            onRetry: () =>
                context.read<ProductListBloc>().add(const ProductListFetched()),
          );
        }

        if (state.products.isEmpty) {
          return const EmptyStateWidget(
            title: 'No products found',
            message: 'Try changing your search or selected category',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProductListBloc>().add(const ProductListRefreshed());
          },
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final product = state.products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                child: AnimatedSlide(
                  duration: Duration(
                    milliseconds: 150 + (index * 20).clamp(0, 300),
                  ),
                  offset: Offset.zero,
                  child: ProductCard(
                    product: product,
                    isSelected: selectedProductId == product.id,
                    onTap: () => onProductTap(product.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
