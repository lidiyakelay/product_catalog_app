import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProductsParams extends Equatable {
  final String query;
  final int limit;
  final int skip;

  const SearchProductsParams({required this.query, this.limit = 20, this.skip = 0});

  @override
  List<Object?> get props => [query, limit, skip];
}

class SearchProductsUseCase
    implements UseCase<PaginatedProducts, SearchProductsParams> {
  final ProductRepository repository;

  const SearchProductsUseCase(this.repository);

  @override
  Future<PaginatedProducts> call(SearchProductsParams params) {
    return repository.searchProducts(
      query: params.query,
      limit: params.limit,
      skip: params.skip,
    );
  }
}
