import '../api/product_api_client.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductApiClient _apiClient;

  ProductRepository({ProductApiClient? apiClient})
    : _apiClient = apiClient ?? ProductApiClient();

  Future<ProductsResponse> getProducts({int limit = 20, int skip = 0}) {
    return _apiClient.getProducts(limit: limit, skip: skip);
  }

  Future<ProductsResponse> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) {
    return _apiClient.searchProducts(query: query, limit: limit, skip: skip);
  }

  Future<List<String>> getCategories() {
    return _apiClient.getCategories();
  }

  Future<ProductsResponse> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
  }) {
    return _apiClient.getProductsByCategory(
      category: category,
      limit: limit,
      skip: skip,
    );
  }

  Future<Product> getProduct(int id) {
    return _apiClient.getProduct(id);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
