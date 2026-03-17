import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/app.dart';
import 'package:product_catalog_app/app/di/injection_container.dart';

void main() {
  setUpAll(() async {
    await initDependencies();
  });

  testWidgets('app starts and shows product catalog title', (tester) async {
    await tester.pumpWidget(const ProductCatalogApp());
    await tester.pumpAndSettle();

    expect(find.text('Product Catalog'), findsOneWidget);
  });
}
