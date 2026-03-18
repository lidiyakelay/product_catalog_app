import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../state_management/product_list/product_list_bloc.dart';
import '../../../state_management/product_list/product_list_event.dart';
import '../../../state_management/product_list/product_list_state.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/state_widgets.dart';

class ProductListContent extends StatelessWidget {
  final ScrollController scrollController;
  final ValueChanged<int> onProductTap;
  final int? selectedProductId;

  const ProductListContent({
    super.key,
    required this.scrollController,
    required this.onProductTap,
    this.selectedProductId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        if ((state.status == ProductListStatus.initial ||
                state.status == ProductListStatus.loading) &&
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
