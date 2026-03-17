import 'package:flutter/material.dart';
import 'app.dart';
import 'app/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ProductCatalogApp());
}
