import 'package:equatable/equatable.dart';

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
  bool get isLowStock => stock > 0 && stock <= 5;

  @override
  List<Object?> get props => [
        id, title, description, price, discountPercentage,
        rating, stock, brand, category, thumbnail, images,
      ];
}

class PaginatedProducts extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;
  final bool isFromCache;

  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
    this.isFromCache = false,
  });

  bool get hasMore => skip + limit < total;

  @override
  List<Object?> get props => [products, total, skip, limit, isFromCache];
}
