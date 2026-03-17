import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductsResponseModel> getProducts({int limit, int skip});
  Future<ProductsResponseModel> searchProducts({
    required String query,
    int limit,
    int skip,
  });
  Future<List<String>> getCategories();
  Future<ProductsResponseModel> getProductsByCategory({
    required String category,
    int limit,
    int skip,
  });
  Future<ProductModel> getProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  const ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<ProductsResponseModel> getProducts({
    int limit = AppConstants.pageSize,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products?limit=$limit&skip=$skip',
    );
    return _fetchProducts(uri);
  }

  @override
  Future<ProductsResponseModel> searchProducts({
    required String query,
    int limit = AppConstants.pageSize,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products/search?q=${Uri.encodeComponent(query)}&limit=$limit&skip=$skip',
    );
    return _fetchProducts(uri);
  }

  @override
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/category-list');
    final response = await _get(uri);
    final decoded = jsonDecode(response.body);
    return List<String>.from(decoded as List);
  }

  @override
  Future<ProductsResponseModel> getProductsByCategory({
    required String category,
    int limit = AppConstants.pageSize,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/products/category/${Uri.encodeComponent(category)}?limit=$limit&skip=$skip',
    );
    return _fetchProducts(uri);
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/products/$id');
    final response = await _get(uri);
    return ProductModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ProductsResponseModel> _fetchProducts(Uri uri) async {
    final response = await _get(uri);
    return ProductsResponseModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) return response;
      throw ServerException(
        'Server error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }
}
