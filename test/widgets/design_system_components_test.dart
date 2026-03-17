import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/core/theme/app_theme.dart';
import 'package:product_catalog_app/data/models/product.dart';
import 'package:product_catalog_app/ui/components/category_chips.dart';
import 'package:product_catalog_app/ui/components/product_card.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  testWidgets('ProductCard renders product information', (tester) async {
    const product = Product(
      id: 1,
      title: 'Test Product',
      description: 'Test Description',
      price: 150,
      discountPercentage: 20,
      rating: 4.8,
      stock: 15,
      brand: 'Test Brand',
      category: 'test-category',
      thumbnail: '',
      images: [],
    );

    await tester.pumpWidget(wrap(const ProductCard(product: product)));

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Test Brand'), findsOneWidget);
    expect(find.textContaining('\$120.00'), findsOneWidget);
    expect(find.textContaining('4.8'), findsOneWidget);
  });

  testWidgets('CategoryChips shows all and category items', (tester) async {
    String? selected;

    await tester.pumpWidget(
      wrap(
        CategoryChips(
          categories: const ['smartphones', 'laptops'],
          selectedCategory: null,
          onSelected: (value) => selected = value,
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Smartphones'), findsOneWidget);
    expect(find.text('Laptops'), findsOneWidget);

    await tester.tap(find.text('Laptops'));
    await tester.pump();

    expect(selected, 'laptops');
  });
}
