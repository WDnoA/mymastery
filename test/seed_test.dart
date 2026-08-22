import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mymastery/database/database.dart';
import 'package:mymastery/utils/calculator.dart';
import 'package:mymastery/utils/seed_data.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('测试 1: 创建数据库并加载示例数据', () async {
    var assets = await db.getAllAssets();
    expect(assets.length, 0, reason: '初始数据应为空');

    await seedSampleData(db);
    assets = await db.getAllAssets();
    expect(assets.length, 12, reason: '应有 12 条数据');
  });

  test('测试 2: 验证资产数据完整性', () async {
    await seedSampleData(db);
    final assets = await db.getAllAssets();

    for (final a in assets) {
      final days = calculateDaysUsed(a.purchaseDate);
      final cost = calculateDailyCost(a.price, days);

      expect(a.name.isNotEmpty, true);
      expect(a.price, greaterThan(0));
      expect(a.purchaseDate.isNotEmpty, true);
      expect(['服役中', '已退役', '已卖出'].contains(a.status), true);
      expect(a.iconEmoji.isNotEmpty, true);
      expect(days, greaterThanOrEqualTo(0));
      expect(cost, greaterThan(0));
    }
  });

  test('测试 3: 统计计算正确性', () async {
    await seedSampleData(db);
    final assets = await db.getAllAssets();

    final totalValue = assets.fold<double>(0, (sum, a) => sum + a.price);
    final activeCount = assets.where((a) => a.status == '服役中').length;
    final retiredCount = assets.where((a) => a.status == '已退役').length;
    final soldCount = assets.where((a) => a.status == '已卖出').length;
    final avgDailyCost =
        assets.fold<double>(0, (sum, a) {
          final days = calculateDaysUsed(a.purchaseDate);
          return sum + calculateDailyCost(a.price, days);
        }) /
        assets.length;

    expect(activeCount, 9, reason: '应有 9 个服役中');
    expect(retiredCount, 1, reason: '应有 1 个已退役');
    expect(soldCount, 2, reason: '应有 2 个已卖出');
    expect(totalValue, greaterThan(0), reason: '总价值应大于 0');
    expect(avgDailyCost, greaterThan(0), reason: '日均成本应大于 0');
  });

  test('测试 4: 重复加载不重复写入', () async {
    await seedSampleData(db);
    await seedSampleData(db);
    final assets = await db.getAllAssets();
    expect(assets.length, 12, reason: '重复加载不应增加数据');
  });

  test('测试 5: CRUD 操作', () async {
    await seedSampleData(db);

    final newId = await db.insertAsset(
      AssetsCompanion(
        name: const Value('测试资产'),
        price: const Value(999.0),
        purchaseDate: const Value('2026-01-01'),
        status: const Value('服役中'),
        iconEmoji: const Value('🧪'),
        categoryId: const Value(0),
      ),
    );
    expect(newId, greaterThan(0), reason: '插入应返回有效 ID');

    var fetched = await db.getAssetById(newId);
    expect(fetched, isNotNull);
    expect(fetched!.name, '测试资产');
    expect(fetched.categoryId, 0);

    final updated = fetched.copyWith(name: '已更新资产');
    await db.updateAsset(updated);
    fetched = await db.getAssetById(newId);
    expect(fetched!.name, '已更新资产');

    await db.deleteAsset(newId);
    final deleted = await db.getAssetById(newId);
    expect(deleted, isNull, reason: '删除后应查不到');

    final assets = await db.getAllAssets();
    expect(assets.length, 12, reason: '最终数据量应为 12');
  });

  test('测试 6: 分类功能', () async {
    await seedSampleData(db);

    final categories = await db.getAllCategories();
    final electronicCat =
        categories.firstWhere((c) => c.name == '电子产品');
    final homeCat =
        categories.firstWhere((c) => c.name == '家居家具');

    final electronicAssets =
        await db.getAssetsByCategory(electronicCat.id);
    expect(electronicAssets.length, 9, reason: '电子产品应有 9 件');

    final homeAssets = await db.getAssetsByCategory(homeCat.id);
    expect(homeAssets.length, 1, reason: '家居应有 1 件');
  });

  test('测试 7: 金额格式化', () {
    expect(formatCurrency(1234.5, useSeparator: true), '¥1,234.50');
    expect(formatCurrency(1234.5, useSeparator: false), '¥1234.50');
    expect(formatPrice(1234.56), '¥1234.56');
  });
}
