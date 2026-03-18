import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog_app/app/constants/app_constants.dart';
import 'package:product_catalog_app/core/usecases/usecase.dart';
import 'package:product_catalog_app/domain/entities/product.dart';
import 'package:product_catalog_app/domain/usecases/get_categories_usecase.dart';
import 'package:product_catalog_app/domain/usecases/get_products_by_category_usecase.dart';
import 'package:product_catalog_app/domain/usecases/get_products_usecase.dart';
import 'package:product_catalog_app/domain/usecases/search_products_usecase.dart';
import 'package:product_catalog_app/presentation/state_management/product_list/product_list_bloc.dart';
import 'package:product_catalog_app/presentation/state_management/product_list/product_list_event.dart';
import 'package:product_catalog_app/presentation/state_management/product_list/product_list_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

class FakeGetProductsParams extends Fake implements GetProductsParams {}

class FakeSearchProductsParams extends Fake implements SearchProductsParams {}

class FakeGetProductsByCategoryParams extends Fake
    implements GetProductsByCategoryParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late GetProductsUseCase getProducts;
  late SearchProductsUseCase searchProducts;
  late GetCategoriesUseCase getCategories;
  late GetProductsByCategoryUseCase getProductsByCategory;

  setUpAll(() {
    registerFallbackValue(FakeGetProductsParams());
    registerFallbackValue(FakeSearchProductsParams());
    registerFallbackValue(FakeGetProductsByCategoryParams());
    registerFallbackValue(FakeNoParams());
  });

  final sampleProducts = [
    const Product(
      id: 1,
      title: 'Phone',
      description: 'Description',
      price: 100.0,
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
    getProducts = MockGetProductsUseCase();
    searchProducts = MockSearchProductsUseCase();
    getCategories = MockGetCategoriesUseCase();
    getProductsByCategory = MockGetProductsByCategoryUseCase();

    when(() => searchProducts(any())).thenAnswer(
      (_) async => const PaginatedProducts(
        products: [],
        total: 0,
        skip: 0,
        limit: 20,
      ),
    );
    when(() => getCategories(any())).thenAnswer((_) async => const []);
    when(() => getProductsByCategory(any())).thenAnswer(
      (_) async => const PaginatedProducts(
        products: [],
        total: 0,
        skip: 0,
        limit: 20,
      ),
    );
  });

  blocTest<ProductListBloc, ProductListState>(
    'emits loading then loaded when fetch succeeds',
    build: () {
      when(() => getProducts(any())).thenAnswer(
        (_) async => PaginatedProducts(
          products: sampleProducts,
          total: 1,
          skip: 0,
          limit: 20,
        ),
      );
      return ProductListBloc(
        getProducts: getProducts,
        searchProducts: searchProducts,
        getCategories: getCategories,
        getProductsByCategory: getProductsByCategory,
      );
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
      when(() => getProducts(any())).thenThrow(Exception('network error'));
      return ProductListBloc(
        getProducts: getProducts,
        searchProducts: searchProducts,
        getCategories: getCategories,
        getProductsByCategory: getProductsByCategory,
      );
    },
    act: (bloc) => bloc.add(const ProductListFetched()),
    expect: () => [
      const ProductListState(status: ProductListStatus.loading),
      isA<ProductListState>()
          .having((s) => s.status, 'status', ProductListStatus.error)
          .having(
            (s) => s.errorMessage,
            'errorMessage',
            AppConstants.productListErrorMessage,
          ),
    ],
  );

  blocTest<ProductListBloc, ProductListState>(
    'updates selected category and fetches products',
    build: () {
      when(() => getProductsByCategory(any())).thenAnswer(
        (_) async => PaginatedProducts(
          products: sampleProducts,
          total: 1,
          skip: 0,
          limit: 20,
        ),
      );
      return ProductListBloc(
        getProducts: getProducts,
        searchProducts: searchProducts,
        getCategories: getCategories,
        getProductsByCategory: getProductsByCategory,
      );
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
