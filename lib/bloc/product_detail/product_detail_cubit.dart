import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final ProductRepository _repository;

  ProductDetailCubit({required ProductRepository repository})
    : _repository = repository,
      super(const ProductDetailState());

  Future<void> loadProduct(int id) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));
    try {
      final product = await _repository.getProduct(id);
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
