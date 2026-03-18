import 'package:logger/logger.dart';
import 'dart:convert';
import '../../core/utils/image_validator.dart';
import '../../domain/entities/product.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));
const int _maxWarningLogsPerType = 5;
final Map<String, int> _warningLogCounts = <String, int>{};

void _logWarningThrottled(String key, String message) {
  final count = _warningLogCounts[key] ?? 0;
  if (count >= _maxWarningLogsPerType) return;

  _log.w(message);
  _warningLogCounts[key] = count + 1;

  if (count + 1 == _maxWarningLogsPerType) {
    _log.i('Further "$key" warnings are suppressed for this session.');
  }
}

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
      if (v == null) {
        if (field == 'price') {
          _log.e('Product $id: Missing price, defaulting to 0');
        } else {
          _logWarningThrottled(
            'missing_$field',
            'Product $id: Missing $field, defaulting to 0',
          );
        }
        return 0.0;
      }

      final d =
          (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
      if (d < 0) {
        if (field == 'price') {
          _log.e('Product $id: Missing or negative price ($d), defaulting to 0');
        } else {
          _logWarningThrottled(
            'negative_$field',
            'Product $id: Negative $field ($d), defaulting to 0',
          );
        }
        return 0.0;
      }
      return d;
    }

    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages
            .map((e) => validateImageUrl(e.toString(), 'image', id))
            .where((url) => url.isNotEmpty)
            .toList()
        : <String>[];

    final validatedThumbnail = validateImageUrl(
      json['thumbnail']?.toString() ?? '',
      'thumbnail',
      id,
    );

    final thumbnail = validatedThumbnail.isNotEmpty
        ? validatedThumbnail
        : (images.isNotEmpty ? images.first : '');

    final rawBrand = json['brand']?.toString().trim();
    if (rawBrand == null || rawBrand.isEmpty) {
      _logWarningThrottled(
        'missing_brand',
        'Product $id: Missing brand, using default',
      );
    }

    if (images.isEmpty && thumbnail.isEmpty) {
      _logWarningThrottled(
        'missing_images',
        'Product $id: No valid images available, UI will show placeholder',
      );
    }

    final rawTitle = json['title']?.toString().trim();
    final rawCategory = json['category']?.toString().trim();

    return ProductModel(
      id: id,
      title: (rawTitle == null || rawTitle.isEmpty)
          ? 'Untitled Product'
          : rawTitle,
      description: json['description']?.toString().trim() ?? '',
      price: parseDouble(json['price'], 'price'),
      discountPercentage:
          parseDouble(json['discountPercentage'], 'discountPercentage')
              .clamp(0.0, 100.0),
      rating:
          parseDouble(json['rating'], 'rating').clamp(0.0, 5.0),
      stock: (json['stock'] as int?) ?? 0,
      brand: (rawBrand == null || rawBrand.isEmpty) ? 'Unknown brand' : rawBrand,
      category: (rawCategory == null || rawCategory.isEmpty)
          ? 'Uncategorized'
          : rawCategory,
      thumbnail: thumbnail,
      images: images,
    );
  }

  factory ProductModel.fromDbMap(Map<String, dynamic> map) {
    final rawImages = map['images']?.toString() ?? '[]';
    final decodedImages = jsonDecode(rawImages);

    return ProductModel(
      id: (map['id'] as int?) ?? 0,
      title: map['title']?.toString() ?? 'Untitled Product',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (map['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as int?) ?? 0,
      brand: map['brand']?.toString() ?? 'Unknown brand',
      category: map['category']?.toString() ?? 'Uncategorized',
      thumbnail: map['thumbnail']?.toString() ?? '',
      images: decodedImages is List
          ? decodedImages.map((e) => e.toString()).toList()
          : const <String>[],
    );
  }

  Map<String, dynamic> toDbMap({required int cachedAtMs}) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discount_percentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': jsonEncode(images),
      'cached_at': cachedAtMs,
    };
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
