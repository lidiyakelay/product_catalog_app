import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../../domain/entities/product.dart';
import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);

  Future<PaginatedProducts> getCachedProducts({
    required int limit,
    required int skip,
    required Duration maxAge,
  });

  Future<PaginatedProducts> searchCachedProducts({
    required String query,
    required int limit,
    required int skip,
    required Duration maxAge,
  });

  Future<PaginatedProducts> getCachedProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    required Duration maxAge,
  });

  Future<List<String>> getCachedCategories({required Duration maxAge});
  Future<ProductModel?> getCachedProductById({
    required int id,
    required Duration maxAge,
  });
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _dbName = 'product_catalog_cache.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'products_cache';

  Database? _database;

  Future<Database> get _db async {
    _database ??= await _openDb();
    return _database!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            discount_percentage REAL NOT NULL,
            rating REAL NOT NULL,
            stock INTEGER NOT NULL,
            brand TEXT NOT NULL,
            category TEXT NOT NULL,
            thumbnail TEXT NOT NULL,
            images TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    if (products.isEmpty) return;

    final db = await _db;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      for (final product in products) {
        await txn.insert(
          _tableName,
          product.toDbMap(cachedAtMs: nowMs),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<PaginatedProducts> getCachedProducts({
    required int limit,
    required int skip,
    required Duration maxAge,
  }) async {
    final cachedProducts = await _getValidCachedProducts(maxAge: maxAge);
    return _paginate(products: cachedProducts, limit: limit, skip: skip);
  }

  @override
  Future<PaginatedProducts> searchCachedProducts({
    required String query,
    required int limit,
    required int skip,
    required Duration maxAge,
  }) async {
    final all = await _getValidCachedProducts(maxAge: maxAge);
    final q = query.trim().toLowerCase();

    final filtered = all.where((product) {
      return product.title.toLowerCase().contains(q) ||
          product.description.toLowerCase().contains(q) ||
          product.brand.toLowerCase().contains(q);
    }).toList();

    return _paginate(products: filtered, limit: limit, skip: skip);
  }

  @override
  Future<PaginatedProducts> getCachedProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    required Duration maxAge,
  }) async {
    final all = await _getValidCachedProducts(maxAge: maxAge);

    final filtered = all.where((product) => product.category == category).toList();
    return _paginate(products: filtered, limit: limit, skip: skip);
  }

  @override
  Future<List<String>> getCachedCategories({required Duration maxAge}) async {
    final all = await _getValidCachedProducts(maxAge: maxAge);
    final set = <String>{};

    for (final product in all) {
      if (product.category.trim().isNotEmpty) {
        set.add(product.category.trim());
      }
    }

    final categories = set.toList()..sort();
    return categories;
  }

  @override
  Future<ProductModel?> getCachedProductById({
    required int id,
    required Duration maxAge,
  }) async {
    final all = await _getValidCachedProducts(maxAge: maxAge);
    for (final product in all) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<List<ProductModel>> _getValidCachedProducts({
    required Duration maxAge,
  }) async {
    final db = await _db;
    final cutoffMs = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;

    await db.delete(
      _tableName,
      where: 'cached_at < ?',
      whereArgs: [cutoffMs],
    );

    final rows = await db.query(
      _tableName,
      orderBy: 'id ASC',
    );

    return rows.map(ProductModel.fromDbMap).toList();
  }

  PaginatedProducts _paginate({
    required List<ProductModel> products,
    required int limit,
    required int skip,
  }) {
    final total = products.length;
    final start = skip.clamp(0, total);
    final end = (start + limit).clamp(start, total);

    final paged = products.sublist(start, end);

    return PaginatedProducts(
      products: paged,
      total: total,
      skip: start,
      limit: limit,
      isFromCache: true,
    );
  }
}
