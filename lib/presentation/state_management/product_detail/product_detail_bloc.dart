import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../app/constants/app_constants.dart';
import '../../../domain/usecases/get_product_usecase.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductUseCase getProduct;
  final Logger _logger = Logger();

  ProductDetailBloc({required this.getProduct})
      : super(const ProductDetailInitial()) {
    on<ProductDetailRequested>(_onProductDetailRequested);
  }

  Future<void> _onProductDetailRequested(
    ProductDetailRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());
    try {
      final product = await getProduct(event.productId);
      emit(ProductDetailLoaded(product));
    } catch (e, st) {
      _logger.e(
        'Failed to load product detail for id=${event.productId}',
        error: e,
        stackTrace: st,
      );
      emit(const ProductDetailError(AppConstants.productDetailErrorMessage));
    }
  }
}
