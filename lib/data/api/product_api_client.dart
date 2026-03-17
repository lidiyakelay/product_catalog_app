import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ProductApiClient {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';

  ProductApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<ProductsResponse> getProducts({int limit = 20, int skip = 0}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    return _fetchProducts(uri);
  }

  Future<ProductsResponse> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/products/search?q=${Uri.encodeComponent(query)}&limit=$limit&skip=$skip',
    );
    return _fetchProducts(uri);
  }

  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$_baseUrl/products/categories');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load categories',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = json.decode(response.body);
    // The API returns a list of category objects with slug and name
    return data
        .map((e) {
          if (e is String) return e;
          if (e is Map<String, dynamic>) return e['slug'] as String? ?? '';
          return '';
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<ProductsResponse> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/products/category/${Uri.encodeComponent(category)}?limit=$limit&skip=$skip',
    );
    return _fetchProducts(uri);
  }

  Future<Product> getProduct(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load product $id',
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return Product.fromJson(data);
  }

  Future<ProductsResponse> _fetchProducts(Uri uri) async {
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load products',
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return ProductsResponse.fromJson(data);
  }

  void dispose() {
    _client.close();
  }
}
