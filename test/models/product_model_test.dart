import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Phone',
        'description': 'A smart phone',
        'price': 100,
        'discountPercentage': 10,
        'rating': 4.5,
        'stock': 20,
        'brand': 'TechBrand',
        'category': 'smartphones',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/img1.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Phone');
      expect(product.discountedPrice, 90);
      expect(product.hasValidPrice, isTrue);
      expect(product.brand, 'TechBrand');
    });

    test('uses fallback values for missing fields', () {
      final json = {'id': 2};

      final product = Product.fromJson(json);

      expect(product.title, 'Untitled Product');
      expect(product.brand, 'Unknown brand');
      expect(product.category, 'Uncategorized');
      expect(product.hasValidPrice, isFalse);
    });

    test('handles invalid price as unavailable', () {
      final json = {'id': 3, 'title': 'Broken product', 'price': -10};

      final product = Product.fromJson(json);

      expect(product.hasValidPrice, isFalse);
      expect(product.price, -1);
      expect(product.discountedPrice, 0);
    });
  });

  group('ProductsResponse.fromJson', () {
    test('parses products response and hasMore correctly', () {
      final json = {
        'products': [
          {'id': 1, 'title': 'Phone', 'price': 200},
        ],
        'total': 100,
        'skip': 0,
        'limit': 20,
      };

      final response = ProductsResponse.fromJson(json);

      expect(response.products.length, 1);
      expect(response.total, 100);
      expect(response.hasMore, isTrue);
    });
  });
}
