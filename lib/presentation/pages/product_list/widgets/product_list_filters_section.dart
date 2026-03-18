import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../state_management/product_list/product_list_bloc.dart';
import '../../../state_management/product_list/product_list_event.dart';
import '../../../state_management/product_list/product_list_state.dart';
import '../../../widgets/category_chips.dart';
import '../../../widgets/search_bar_widget.dart';

class ProductListFiltersSection extends StatelessWidget {
  const ProductListFiltersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SearchBar(),
        _CategoryChipsBar(),
        SizedBox(height: 4),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        return SearchBarWidget(
          initialQuery: state.searchQuery,
          onChanged: (query) {
            context.read<ProductListBloc>().add(ProductListSearchChanged(query));
          },
        );
      },
    );
  }
}

class _CategoryChipsBar extends StatelessWidget {
  const _CategoryChipsBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (prev, curr) =>
          prev.categories != curr.categories ||
          prev.selectedCategory != curr.selectedCategory,
      builder: (context, state) {
        return CategoryChips(
          categories: state.categories,
          selectedCategory: state.selectedCategory,
          onSelected: (category) {
            context
                .read<ProductListBloc>()
                .add(ProductListCategorySelected(category));
          },
        );
      },
    );
  }
}
