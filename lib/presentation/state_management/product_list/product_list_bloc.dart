import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../app/constants/app_constants.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/usecases/get_products_by_category_usecase.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import '../../../domain/usecases/search_products_usecase.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetProductsUseCase getProducts;
  final SearchProductsUseCase searchProducts;
  final GetCategoriesUseCase getCategories;
  final GetProductsByCategoryUseCase getProductsByCategory;

  Timer? _debounceTimer;
  final Logger _logger = Logger();

  ProductListBloc({
    required this.getProducts,
    required this.searchProducts,
    required this.getCategories,
    required this.getProductsByCategory,
  }) : super(const ProductListState()) {
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
    await _ensureCategoriesLoaded(emit);
    try {
      final result = await _fetchProducts(skip: 0);
      emit(
        state.copyWith(
          status: result.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: result.products,
          hasMore: result.hasMore,
          currentPage: 0,
          errorMessage: () => null,
        ),
      );
    } catch (e, st) {
      _logger.e('Failed to fetch products', error: e, stackTrace: st);
      emit(
        state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => AppConstants.productListErrorMessage,
        ),
      );
    }
  }

  Future<void> _ensureCategoriesLoaded(Emitter<ProductListState> emit) async {
    if (state.categories.isNotEmpty) return;

    try {
      final categories = await getCategories(const NoParams());
      emit(state.copyWith(categories: categories));
    } catch (_) {
      // Non-critical — keep product fetch flow running and retry later.
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
      final result =
          await _fetchProducts(skip: nextPage * AppConstants.pageSize);
      final allProducts = [...state.products, ...result.products];
      emit(
        state.copyWith(
          products: allProducts,
          hasMore: result.hasMore,
          currentPage: nextPage,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      _logger.w('Failed to fetch next product page', error: e, stackTrace: st);
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSearchChanged(
    ProductListSearchChanged event,
    Emitter<ProductListState> emit,
  ) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      AppConstants.searchDebounce,
      () => add(const ProductListFetched()),
    );
    emit(state.copyWith(searchQuery: event.query, currentPage: 0));
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
      final categories = await getCategories(const NoParams());
      emit(state.copyWith(categories: categories));
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<_FetchResult> _fetchProducts({required int skip}) async {
    final query = state.searchQuery;
    final category = state.selectedCategory;
    final limit = AppConstants.pageSize;

    if (query.isNotEmpty && category != null) {
      final paginated = await searchProducts(
        SearchProductsParams(query: query, limit: limit, skip: skip),
      );
      final filtered =
          paginated.products.where((p) => p.category == category).toList();
      return _FetchResult(products: filtered, hasMore: paginated.hasMore);
    } else if (query.isNotEmpty) {
      final paginated = await searchProducts(
        SearchProductsParams(query: query, limit: limit, skip: skip),
      );
      return _FetchResult(
        products: paginated.products,
        hasMore: paginated.hasMore,
      );
    } else if (category != null) {
      final paginated = await getProductsByCategory(
        GetProductsByCategoryParams(category: category, limit: limit, skip: skip),
      );
      return _FetchResult(
        products: paginated.products,
        hasMore: paginated.hasMore,
      );
    } else {
      final paginated = await getProducts(
        GetProductsParams(limit: limit, skip: skip),
      );
      return _FetchResult(
        products: paginated.products,
        hasMore: paginated.hasMore,
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
