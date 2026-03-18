import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../state_management/product_detail/product_detail_bloc.dart';
import '../../../state_management/product_detail/product_detail_event.dart';
import '../../../state_management/product_detail/product_detail_state.dart';
import '../../../widgets/state_widgets.dart';
import '../../product_detail/product_detail_page.dart';

class ProductListDetailPanel extends StatelessWidget {
  final int? selectedProductId;

  const ProductListDetailPanel({
    super.key,
    required this.selectedProductId,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedProductId == null) {
      return const NoSelectionWidget();
    }

    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        if (state is ProductDetailInitial || state is ProductDetailLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ProductDetailError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () => context
                .read<ProductDetailBloc>()
                .add(ProductDetailRequested(selectedProductId!)),
          );
        }

        if (state is ProductDetailLoaded) {
          return ProductDetailContent(product: state.product);
        }

        return const NoSelectionWidget();
      },
    );
  }
}
