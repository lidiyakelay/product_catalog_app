import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductRepository _repository;
  static const int _pageSize = 20;
  Timer? _debounceTimer;

  ProductListBloc({required ProductRepository repository})
    : _repository = repository,
      super(const ProductListState()) {
    on<ProductListFetched>(_onFetched);
    on<ProductListNextPageFetched>(_onNextPageFetched);
    on<ProductListSearchChanged>(_onSearchChanged);
    on<ProductListCategorySelected>(_onCategorySelected);
    on<ProductListRefreshed>(_onRefreshed);
    on<ProductListCategoriesFetched>(_onCategoriesFetched);
  }

  Future<void> _onFetched(
    ProductListFetched event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(status: ProductListStatus.loading));
    try {
      final response = await _fetchProducts(skip: 0);
      final products = response.products;
      emit(
        state.copyWith(
          status: products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: products,
          hasMore: response.hasMore,
          currentPage: 0,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onNextPageFetched(
    ProductListNextPageFetched event,
    Emitter<ProductListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final response = await _fetchProducts(skip: nextPage * _pageSize);
      final allProducts = [...state.products, ...response.products];
      emit(
        state.copyWith(
          products: allProducts,
          hasMore: response.hasMore,
          currentPage: nextPage,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSearchChanged(
    ProductListSearchChanged event,
    Emitter<ProductListState> emit,
  ) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(const ProductListFetched());
    });

    emit(state.copyWith(searchQuery: event.query, currentPage: 0));
    // Don't await the debounce - it will trigger a new event
  }

  Future<void> _onCategorySelected(
    ProductListCategorySelected event,
    Emitter<ProductListState> emit,
  ) async {
    emit(
      state.copyWith(selectedCategory: () => event.category, currentPage: 0),
    );
    add(const ProductListFetched());
  }

  Future<void> _onRefreshed(
    ProductListRefreshed event,
    Emitter<ProductListState> emit,
  ) async {
    add(const ProductListFetched());
  }

  Future<void> _onCategoriesFetched(
    ProductListCategoriesFetched event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {
      // Categories are non-critical, silently fail
    }
  }

  Future<_FetchResult> _fetchProducts({required int skip}) async {
    final query = state.searchQuery;
    final category = state.selectedCategory;

    if (query.isNotEmpty && category != null) {
      // Search within category: search first, then filter client-side
      final response = await _repository.searchProducts(
        query: query,
        limit: _pageSize,
        skip: skip,
      );
      final filtered = response.products
          .where((p) => p.category == category)
          .toList();
      return _FetchResult(products: filtered, hasMore: response.hasMore);
    } else if (query.isNotEmpty) {
      final response = await _repository.searchProducts(
        query: query,
        limit: _pageSize,
        skip: skip,
      );
      return _FetchResult(
        products: response.products,
        hasMore: response.hasMore,
      );
    } else if (category != null) {
      final response = await _repository.getProductsByCategory(
        category: category,
        limit: _pageSize,
        skip: skip,
      );
      return _FetchResult(
        products: response.products,
        hasMore: response.hasMore,
      );
    } else {
      final response = await _repository.getProducts(
        limit: _pageSize,
        skip: skip,
      );
      return _FetchResult(
        products: response.products,
        hasMore: response.hasMore,
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

class _FetchResult {
  final List<Product> products;
  final bool hasMore;

  _FetchResult({required this.products, required this.hasMore});
}
