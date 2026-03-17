import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

class Product extends Equatable {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  double get discountedPrice {
    if (price <= 0) return 0;
    return price * (1 - discountPercentage / 100);
  }

  bool get hasValidPrice => price > 0;

  bool get isInStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Validate and sanitize image URLs
    final rawThumbnail = json['thumbnail'] as String? ?? '';
    final thumbnail = _validateImageUrl(rawThumbnail, 'thumbnail', json['id']);

    final rawImages =
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];
    final images = rawImages
        .map((url) => _validateImageUrl(url, 'image', json['id']))
        .where((url) => url.isNotEmpty)
        .toList();

    // Validate price
    final rawPrice = (json['price'] as num?)?.toDouble() ?? -1;
    if (rawPrice < 0) {
      _logger.e('Product ${json['id']}: Missing or negative price ($rawPrice)');
    }

    // Validate brand
    final brand = json['brand'] as String? ?? 'Unknown brand';
    if (json['brand'] == null) {
      _logger.w('Product ${json['id']}: Missing brand, using default');
    }

    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Product',
      description: json['description'] as String? ?? '',
      price: rawPrice < 0 ? -1 : rawPrice,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      brand: brand,
      category: json['category'] as String? ?? 'Uncategorized',
      thumbnail: thumbnail,
      images: images.isEmpty && thumbnail.isNotEmpty ? [thumbnail] : images,
    );
  }

  static String _validateImageUrl(String url, String field, dynamic productId) {
    if (url.isEmpty) {
      _logger.w('Product $productId: Missing $field URL');
      return '';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.hasScheme)) {
      _logger.w('Product $productId: Invalid $field URL: $url');
      return '';
    }
    return url;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    discountPercentage,
    rating,
    stock,
    brand,
    category,
    thumbnail,
    images,
  ];
}

class ProductsResponse extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + limit < total;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final productsList =
        (json['products'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductsResponse(
      products: productsList,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [products, total, skip, limit];
}
