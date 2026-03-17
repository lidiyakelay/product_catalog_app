import '../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/remote/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  const ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedProducts> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final result =
          await remoteDataSource.getProducts(limit: limit, skip: skip);
      return PaginatedProducts(
        products: result.products,
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<PaginatedProducts> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final result = await remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
      );
      return PaginatedProducts(
        products: result.products,
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<PaginatedProducts> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final result = await remoteDataSource.getProductsByCategory(
        category: category,
        limit: limit,
        skip: skip,
      );
      return PaginatedProducts(
        products: result.products,
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      return await remoteDataSource.getProduct(id);
    } on ServerException {
      rethrow;
    }
  }
}
