import '../../app/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_data_source.dart';
import '../datasources/remote/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<PaginatedProducts> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final result =
          await remoteDataSource.getProducts(limit: limit, skip: skip);
      await localDataSource.cacheProducts(result.products);
      return PaginatedProducts(
        products: result.products,
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } on ServerException {
      final cached = await localDataSource.getCachedProducts(
        limit: limit,
        skip: skip,
        maxAge: AppConstants.cacheMaxAge,
      );
      if (cached.products.isNotEmpty) {
        return cached;
      }
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
      await localDataSource.cacheProducts(result.products);
      return PaginatedProducts(
        products: result.products,
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } on ServerException {
      final cached = await localDataSource.searchCachedProducts(
        query: query,
        limit: limit,
        skip: skip,
        maxAge: AppConstants.cacheMaxAge,
      );
      if (cached.products.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } on ServerException {
      final cached = await localDataSource.getCachedCategories(
        maxAge: AppConstants.cacheMaxAge,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
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
      await localDataSource.cacheProducts(result.products);
      return PaginatedProducts(
        products: result.products,
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } on ServerException {
      final cached = await localDataSource.getCachedProductsByCategory(
        category: category,
        limit: limit,
        skip: skip,
        maxAge: AppConstants.cacheMaxAge,
      );
      if (cached.products.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    try {
      return await remoteDataSource.getProduct(id);
    } on ServerException {
      final cached = await localDataSource.getCachedProductById(
        id: id,
        maxAge: AppConstants.cacheMaxAge,
      );
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }
}
