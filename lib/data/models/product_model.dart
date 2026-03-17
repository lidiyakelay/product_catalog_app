import 'package:logger/logger.dart';
import '../../domain/entities/product.dart';

final _log = Logger();

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.category,
    required super.thumbnail,
    required super.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;

    double parseDouble(dynamic v, String field) {
      if (v == null) return 0.0;
      final d = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
      if (d < 0) {
        _log.w('ProductModel[$id]: negative $field ($d), defaulting to 0');
        return 0.0;
      }
      return d;
    }

    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((e) => e.toString()).where(_isValidUrl).toList()
        : <String>[];

    final thumbnail = _isValidUrl(json['thumbnail']?.toString())
        ? json['thumbnail'].toString()
        : (images.isNotEmpty ? images.first : '');

    return ProductModel(
      id: id,
      title: json['title']?.toString().trim() ?? 'Unknown Product',
      description: json['description']?.toString().trim() ?? '',
      price: parseDouble(json['price'], 'price'),
      discountPercentage:
          parseDouble(json['discountPercentage'], 'discountPercentage')
              .clamp(0.0, 100.0),
      rating:
          parseDouble(json['rating'], 'rating').clamp(0.0, 5.0),
      stock: (json['stock'] as int?) ?? 0,
      brand: json['brand']?.toString().trim() ?? 'Unknown',
      category: json['category']?.toString().trim() ?? 'uncategorized',
      thumbnail: thumbnail,
      images: images,
    );
  }
}

class ProductsResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    final list = json['products'] as List? ?? [];
    return ProductsResponseModel(
      products: list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}

bool _isValidUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final lower = url.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}
