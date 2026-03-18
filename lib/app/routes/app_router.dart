import 'package:go_router/go_router.dart';
import '../../presentation/pages/product_detail/product_detail_page.dart';
import '../../presentation/pages/product_list/product_list_page.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final selectedParam = state.uri.queryParameters['selected'];
          final selectedId =
              selectedParam != null ? int.tryParse(selectedParam) : null;
          return ProductListPage(selectedProductId: selectedId);
        },
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailPage(productId: id);
        },
      ),
      
    ],
  );
}
