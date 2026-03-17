import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/di/injection_container.dart';
import '../../../app/theme/app_theme.dart';
import '../../../presentation/state_management/product_detail/product_detail_cubit.dart';
import '../../../presentation/state_management/product_detail/product_detail_state.dart';
import '../../../presentation/state_management/product_list/product_list_bloc.dart';
import '../../../presentation/state_management/product_list/product_list_event.dart';
import '../../../presentation/state_management/product_list/product_list_state.dart';
import '../../../presentation/widgets/category_chips.dart';
import '../../../presentation/widgets/product_card.dart';
import '../../../presentation/widgets/search_bar_widget.dart';
import '../../../presentation/widgets/shimmer_loading.dart';
import '../../../presentation/widgets/state_widgets.dart';
import '../product_detail/product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final int? selectedProductId;

  const ProductListPage({super.key, this.selectedProductId});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ScrollController _scrollController;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.selectedProductId;
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ProductListPage oldWidget) {
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
    final isWide =
        MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProductListBloc>()
            ..add(const ProductListCategoriesFetched())
            ..add(const ProductListFetched()),
        ),
        if (isWide)
          BlocProvider(
            create: (_) => sl<ProductDetailCubit>()
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
              tooltip: 'Design Showcase',
            ),
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => ctx.push('/showcase'),
                icon: const Icon(Icons.brightness_6_outlined),
                tooltip: 'Toggle Theme',
              ),
            ),
          ],
        ),
        body: isWide ? _buildWideLayout() : _buildPhoneLayout(),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Column(
      children: [
        _SearchBar(),
        _CategoryChipsBar(),
        const SizedBox(height: 4),
        Expanded(
          child: _ProductListContent(
            scrollController: _scrollController,
            onProductTap: (id) => context.push('/products/$id'),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        SizedBox(
          width: AppConstants.listPanelWidth,
          child: Column(
            children: [
              _SearchBar(),
              _CategoryChipsBar(),
              const SizedBox(height: 4),
              Expanded(
                child: _ProductListContent(
                  scrollController: _scrollController,
                  selectedProductId: _selectedProductId,
                  onProductTap: (id) {
                    setState(() => _selectedProductId = id);
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
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case ProductDetailStatus.error:
                        return ErrorStateWidget(
                          message:
                              state.errorMessage ?? 'Failed to load product',
                          onRetry: () => context
                              .read<ProductDetailCubit>()
                              .loadProduct(_selectedProductId!),
                        );
                      case ProductDetailStatus.loaded:
                        if (state.product == null) return const NoSelectionWidget();
                        return ProductDetailContent(product: state.product!);
                    }
                  },
                ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        return SearchBarWidget(
          initialQuery: state.searchQuery,
          onChanged: (query) {
            context.read<ProductListBloc>().add(ProductListSearchChanged(query));
          },
        );
      },
    );
  }
}

class _CategoryChipsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (prev, curr) =>
          prev.categories != curr.categories ||
          prev.selectedCategory != curr.selectedCategory,
      builder: (context, state) {
        return CategoryChips(
          categories: state.categories,
          selectedCategory: state.selectedCategory,
          onSelected: (category) {
            context
                .read<ProductListBloc>()
                .add(ProductListCategorySelected(category));
          },
        );
      },
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            itemCount:
                state.products.length + (state.isLoadingMore ? 1 : 0),
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
                child: ProductCard(
                  product: product,
                  isSelected: selectedProductId == product.id,
                  onTap: () => onProductTap(product.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
