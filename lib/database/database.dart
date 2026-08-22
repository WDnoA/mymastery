import 'package:drift/drift.dart';

import 'connection_io.dart' if (dart.library.html) 'connection_web.dart';

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconEmoji => text().withDefault(const Constant('📦'))();
}

class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get purchaseDate => text()();
  TextColumn get status => text()();
  TextColumn get iconEmoji => text().withDefault(const Constant('📱'))();
  IntColumn get categoryId => integer().nullable()();
}

@DriftDatabase(tables: [Categories, Assets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ===== Categories =====
  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ===== Assets =====
  Future<List<Asset>> getAllAssets() => select(assets).get();

  Future<Asset?> getAssetById(int id) =>
      (select(assets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Asset>> getAssetsByCategory(int categoryId) =>
      (select(assets)..where((t) => t.categoryId.equals(categoryId))).get();

  Future<int> insertAsset(AssetsCompanion entry) => into(assets).insert(entry);

  Future<bool> updateAsset(Asset asset) => update(assets).replace(asset);

  Future<int> deleteAsset(int id) =>
      (delete(assets)..where((t) => t.id.equals(id))).go();
}
