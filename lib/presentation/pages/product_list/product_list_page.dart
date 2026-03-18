import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/di/injection_container.dart';
import '../../../presentation/state_management/product_detail/product_detail_bloc.dart';
import '../../../presentation/state_management/product_detail/product_detail_event.dart';
import '../../../presentation/state_management/product_list/product_list_bloc.dart';
import '../../../presentation/state_management/product_list/product_list_event.dart';
import '../../../presentation/state_management/theme/theme_cubit.dart';
import 'widgets/product_list_content.dart';
import 'widgets/product_list_detail_panel.dart';
import 'widgets/product_list_filters_section.dart';

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
            create: (_) {
              final bloc = sl<ProductDetailBloc>();
              if (_selectedProductId != null) {
                bloc.add(ProductDetailRequested(_selectedProductId!));
              }
              return bloc;
            },
          ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Catalog'),
          actions: [
            IconButton(
              onPressed: () => context.push('/showcase'),
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Open component showcase',
            ),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark ||
                    (themeMode == ThemeMode.system &&
                        Theme.of(context).brightness == Brightness.dark);

                return IconButton(
                  onPressed: () => context.read<ThemeCubit>().toggle(),
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  tooltip: isDark
                      ? 'Switch to light theme'
                      : 'Switch to dark theme',
                );
              },
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
        const ProductListFiltersSection(),
        Expanded(
          child: ProductListContent(
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
              const ProductListFiltersSection(),
              Expanded(
                child: ProductListContent(
                  scrollController: _scrollController,
                  selectedProductId: _selectedProductId,
                  onProductTap: (id) {
                    setState(() => _selectedProductId = id);
                    context.read<ProductDetailBloc>().add(ProductDetailRequested(id));
                    context.go('/products?selected=$id');
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ProductListDetailPanel(selectedProductId: _selectedProductId),
        ),
      ],
    );
  }
}
