import '../entities/product.dart';

abstract class ProductRepository {
  Future<PaginatedProducts> getProducts({int limit, int skip});

  Future<PaginatedProducts> searchProducts({
    required String query,
    int limit,
    int skip,
  });

  Future<List<String>> getCategories();

  Future<PaginatedProducts> getProductsByCategory({
    required String category,
    int limit,
    int skip,
  });

  Future<Product> getProduct(int id);
}
