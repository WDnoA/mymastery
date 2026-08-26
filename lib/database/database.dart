import 'package:drift/drift.dart';

import 'connection_io.dart' if (dart.library.html) 'connection_web.dart';

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconEmoji => text().withDefault(const Constant('📦'))();
  // 数据归属空间：guest=游客，登录后为账号名
  TextColumn get owner => text().withDefault(const Constant('guest'))();
}

class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get purchaseDate => text()();
  TextColumn get status => text()();
  TextColumn get iconEmoji => text().withDefault(const Constant('📱'))();
  IntColumn get categoryId => integer().nullable()();
  // 数据归属空间：guest=游客，登录后为账号名
  TextColumn get owner => text().withDefault(const Constant('guest'))();
}

@DriftDatabase(tables: [Categories, Assets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // 从版本 1 升级：新增 owner 列（默认 guest，保留现有数据）
      if (from < 2) {
        await m.addColumn(categories, categories.owner);
        await m.addColumn(assets, assets.owner);
      }
    },
  );

  // ===== Categories =====
  Future<List<Category>> getCategoriesByOwner(String owner) =>
      (select(categories)..where((t) => t.owner.equals(owner))).get();

  /// 兼容旧调用：导入/测试使用默认游客空间
  Future<List<Category>> getAllCategories() => getCategoriesByOwner('guest');

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  // ===== Assets =====
  Future<List<Asset>> getAssetsByOwner(String owner) =>
      (select(assets)..where((t) => t.owner.equals(owner))).get();

  /// 兼容旧调用：导入/测试使用默认游客空间
  Future<List<Asset>> getAllAssets() => getAssetsByOwner('guest');

  Future<Asset?> getAssetById(int id) =>
      (select(assets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Asset>> getAssetsByCategory(int categoryId) =>
      (select(assets)..where((t) => t.categoryId.equals(categoryId))).get();

  Future<int> insertAsset(AssetsCompanion entry) => into(assets).insert(entry);

  Future<bool> updateAsset(Asset asset) => update(assets).replace(asset);

  Future<int> deleteAsset(int id) =>
      (delete(assets)..where((t) => t.id.equals(id))).go();

  /// 删除某数据归属空间的所有资产和分类（账号删除时清理数据）
  Future<void> deleteDataByOwner(String owner) async {
    await (delete(assets)..where((t) => t.owner.equals(owner))).go();
    await (delete(categories)..where((t) => t.owner.equals(owner))).go();
  }
}
