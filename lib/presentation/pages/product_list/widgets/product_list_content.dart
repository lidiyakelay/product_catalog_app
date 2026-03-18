import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../state_management/product_list/product_list_bloc.dart';
import '../../../state_management/product_list/product_list_event.dart';
import '../../../state_management/product_list/product_list_state.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/state_widgets.dart';

class ProductListContent extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<int> onProductTap;
  final int? selectedProductId;

  const ProductListContent({
    super.key,
    required this.scrollController,
    required this.onProductTap,
    this.selectedProductId,
  });

  @override
  State<ProductListContent> createState() => _ProductListContentState();
}

class _ProductListContentState extends State<ProductListContent> {
  Future<void> _handleRefresh() async {
    final bloc = context.read<ProductListBloc>();
    final done = Completer<void>();

    late final StreamSubscription<ProductListState> subscription;
    subscription = bloc.stream.listen((state) {
      if (state.status != ProductListStatus.loading && !done.isCompleted) {
        done.complete();
      }
    });

    bloc.add(const ProductListRefreshed());

    await done.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
    await subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        if ((state.status == ProductListStatus.initial ||
                state.status == ProductListStatus.loading) &&
            state.products.isEmpty) {
          return const ShimmerLoadingList();
        }

        if (state.status == ProductListStatus.error && state.products.isEmpty) {
          return ErrorStateWidget(
            message: state.errorMessage ?? 'Failed to load products',
            onRetry: () =>
                context.read<ProductListBloc>().add(const ProductListFetched()),
          );
        }

        if (state.products.isEmpty) {
          return const EmptyStateWidget(
            title: 'No products found',
            message: 'Try changing your search or selected category',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isFromCache)
              Container(
                width: MediaQuery.of(context).size.width/4,
                margin: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  0,
                  AppTheme.spacingMd,
                  AppTheme.spacingSm,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'offline mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                  ),
                  itemCount:
                      state.products.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.products.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMd,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final product = state.products[index];
                    return _StaggeredListItem(
                      key: ValueKey('product-${product.id}'),
                      index: index,
                      enabled: state.currentPage == 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacingSm,
                        ),
                        child: ProductCard(
                          product: product,
                          isSelected: widget.selectedProductId == product.id,
                          onTap: () => widget.onProductTap(product.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StaggeredListItem extends StatefulWidget {
  final int index;
  final bool enabled;
  final Widget child;

  const _StaggeredListItem({
    super.key,
    required this.index,
    required this.enabled,
    required this.child,
  });

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) {
      _visible = true;
      return;
    }

    Future<void>.delayed(
      Duration(milliseconds: 30 * widget.index.clamp(0, 8)),
      () {
        if (mounted) setState(() => _visible = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
