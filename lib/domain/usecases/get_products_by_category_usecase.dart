import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryParams extends Equatable {
  final String category;
  final int limit;
  final int skip;

  const GetProductsByCategoryParams({
    required this.category,
    this.limit = 20,
    this.skip = 0,
  });

  @override
  List<Object?> get props => [category, limit, skip];
}

class GetProductsByCategoryUseCase
    implements UseCase<PaginatedProducts, GetProductsByCategoryParams> {
  final ProductRepository repository;

  const GetProductsByCategoryUseCase(this.repository);

  @override
  Future<PaginatedProducts> call(GetProductsByCategoryParams params) {
    return repository.getProductsByCategory(
      category: params.category,
      limit: params.limit,
      skip: params.skip,
    );
  }
}
