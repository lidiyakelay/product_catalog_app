import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/local/product_local_data_source.dart';
import '../../data/datasources/remote/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_product_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../presentation/state_management/product_detail/product_detail_bloc.dart';
import '../../presentation/state_management/product_list/product_list_bloc.dart';
import '../../presentation/state_management/theme/theme_cubit.dart';
import '../routes/app_router.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Data sources
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));

  // State management (factories so each page gets a fresh instance)
  sl.registerFactory(
    () => ProductListBloc(
      getProducts: sl(),
      searchProducts: sl(),
      getCategories: sl(),
      getProductsByCategory: sl(),
    ),
  );
  sl.registerFactory(() => ProductDetailBloc(getProduct: sl()));
  sl.registerLazySingleton(() => ThemeCubit());

  // Router
  sl.registerLazySingleton(() => AppRouter());
}
