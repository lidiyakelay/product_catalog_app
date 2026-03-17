import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog_app/bloc/product_list/product_list_bloc.dart';
import 'package:product_catalog_app/bloc/product_list/product_list_event.dart';
import 'package:product_catalog_app/bloc/product_list/product_list_state.dart';
import 'package:product_catalog_app/data/models/product.dart';
import 'package:product_catalog_app/data/repositories/product_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ProductRepository repository;

  final sampleProducts = [
    const Product(
      id: 1,
      title: 'Phone',
      description: 'Description',
      price: 100,
      discountPercentage: 10,
      rating: 4.5,
      stock: 10,
      brand: 'Brand',
      category: 'smartphones',
      thumbnail: 'https://example.com/thumb.jpg',
      images: ['https://example.com/img.jpg'],
    ),
  ];

  setUp(() {
    repository = MockProductRepository();
  });

  blocTest<ProductListBloc, ProductListState>(
    'emits loading then loaded when fetch succeeds',
    build: () {
      when(() => repository.getProducts(limit: 20, skip: 0)).thenAnswer(
        (_) async => ProductsResponse(
          products: sampleProducts,
          total: 1,
          skip: 0,
          limit: 20,
        ),
      );
      return ProductListBloc(repository: repository);
    },
    act: (bloc) => bloc.add(const ProductListFetched()),
    expect: () => [
      const ProductListState(status: ProductListStatus.loading),
      ProductListState(
        status: ProductListStatus.loaded,
        products: sampleProducts,
        hasMore: false,
        currentPage: 0,
      ),
    ],
  );

  blocTest<ProductListBloc, ProductListState>(
    'emits loading then error when fetch fails',
    build: () {
      when(
        () => repository.getProducts(limit: 20, skip: 0),
      ).thenThrow(Exception('network error'));
      return ProductListBloc(repository: repository);
    },
    act: (bloc) => bloc.add(const ProductListFetched()),
    expect: () => [
      const ProductListState(status: ProductListStatus.loading),
      isA<ProductListState>()
          .having((s) => s.status, 'status', ProductListStatus.error)
          .having((s) => s.errorMessage, 'errorMessage', contains('Exception')),
    ],
  );

  blocTest<ProductListBloc, ProductListState>(
    'updates selected category and fetches products',
    build: () {
      when(
        () => repository.getProductsByCategory(
          category: 'smartphones',
          limit: 20,
          skip: 0,
        ),
      ).thenAnswer(
        (_) async => ProductsResponse(
          products: sampleProducts,
          total: 1,
          skip: 0,
          limit: 20,
        ),
      );
      return ProductListBloc(repository: repository);
    },
    act: (bloc) => bloc.add(const ProductListCategorySelected('smartphones')),
    expect: () => [
      isA<ProductListState>().having(
        (s) => s.selectedCategory,
        'selectedCategory',
        'smartphones',
      ),
      isA<ProductListState>().having(
        (s) => s.status,
        'status',
        ProductListStatus.loading,
      ),
      isA<ProductListState>()
          .having((s) => s.status, 'status', ProductListStatus.loaded)
          .having((s) => s.products.length, 'products.length', 1),
    ],
  );
}
