import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/product_repository.dart';
import '../ui/screens/product_detail_screen.dart';
import '../ui/screens/product_list_screen.dart';
import '../ui/screens/showcase_screen.dart';

class AppRouter {
  final ProductRepository repository;

  AppRouter({required this.repository});

  late final GoRouter router = GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) {
          final selectedId = int.tryParse(
            state.uri.queryParameters['selected'] ?? '',
          );
          return ProductListScreen(
            repository: repository,
            selectedProductId: selectedId,
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            name: 'product-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(
                  body: Center(child: Text('Invalid product id')),
                );
              }

              final width = MediaQuery.of(context).size.width;
              if (width >= 768) {
                return ProductListScreen(
                  repository: repository,
                  selectedProductId: id,
                );
              }

              return ProductDetailScreen(productId: id, repository: repository);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/showcase',
        name: 'showcase',
        builder: (context, state) => const ShowcaseScreen(),
      ),
    ],
  );
}
