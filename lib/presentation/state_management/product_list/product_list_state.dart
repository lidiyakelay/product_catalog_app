import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

enum ProductListStatus { initial, loading, loaded, error, empty }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<Product> products;
  final bool hasMore;
  final int currentPage;
  final String? selectedCategory;
  final String searchQuery;
  final List<String> categories;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool isFromCache;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.hasMore = true,
    this.currentPage = 0,
    this.selectedCategory,
    this.searchQuery = '',
    this.categories = const [],
    this.errorMessage,
    this.isLoadingMore = false,
    this.isFromCache = false,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    bool? hasMore,
    int? currentPage,
    String? Function()? selectedCategory,
    String? searchQuery,
    List<String>? categories,
    String? Function()? errorMessage,
    bool? isLoadingMore,
    bool? isFromCache,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        hasMore,
        currentPage,
        selectedCategory,
        searchQuery,
        categories,
        errorMessage,
        isLoadingMore,
        isFromCache,
      ];
}
