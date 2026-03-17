import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsParams extends Equatable {
  final int limit;
  final int skip;

  const GetProductsParams({this.limit = 20, this.skip = 0});

  @override
  List<Object?> get props => [limit, skip];
}

class GetProductsUseCase implements UseCase<PaginatedProducts, GetProductsParams> {
  final ProductRepository repository;

  const GetProductsUseCase(this.repository);

  @override
  Future<PaginatedProducts> call(GetProductsParams params) {
    return repository.getProducts(limit: params.limit, skip: params.skip);
  }
}
