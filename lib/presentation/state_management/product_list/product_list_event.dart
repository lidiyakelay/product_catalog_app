import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class ProductListFetched extends ProductListEvent {
  const ProductListFetched();
}

class ProductListNextPageFetched extends ProductListEvent {
  const ProductListNextPageFetched();
}

class ProductListSearchChanged extends ProductListEvent {
  final String query;

  const ProductListSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductListCategorySelected extends ProductListEvent {
  final String? category;

  const ProductListCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class ProductListRefreshed extends ProductListEvent {
  const ProductListRefreshed();
}

class ProductListCategoriesFetched extends ProductListEvent {
  const ProductListCategoriesFetched();
}
