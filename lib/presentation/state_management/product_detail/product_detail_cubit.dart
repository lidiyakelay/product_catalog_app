import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_product_usecase.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductUseCase getProduct;

  ProductDetailCubit({required this.getProduct})
      : super(const ProductDetailState());

  Future<void> loadProduct(int id) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));
    try {
      final product = await getProduct(id);
      emit(
        state.copyWith(
          status: ProductDetailStatus.loaded,
          product: product,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.error,
          errorMessage: () => e.toString(),
        ),
      );
    }
  }
}
