import 'package:drift/drift.dart' show Value;

import '../database/database.dart';

Future<Map<String, int>> _seedCategories(AppDatabase db, String owner) async {
  final existingCategories = await db.getCategoriesByOwner(owner);
  if (existingCategories.isNotEmpty) {
    final map = <String, int>{};
    for (final c in existingCategories) {
      map[c.name] = c.id;
    }
    return map;
  }

  const defaults = [
    ('电子产品', '📱'),
    ('家居家具', '🛋'),
    ('交通工具', '🚗'),
    ('乐器设备', '🎸'),
    ('运动户外', '👟'),
    ('书籍文具', '📚'),
    ('其他', '📦'),
  ];

  final map = <String, int>{};
  for (final (name, emoji) in defaults) {
    final id = await db.insertCategory(
      CategoriesCompanion(
        name: Value(name),
        iconEmoji: Value(emoji),
        owner: Value(owner),
      ),
    );
    map[name] = id;
  }
  return map;
}

Future<void> seedSampleData(AppDatabase db, String owner) async {
  final existing = await db.getAssetsByOwner(owner);
  if (existing.isNotEmpty) return;

  final catIds = await _seedCategories(db, owner);

  final samples = [
    (
      name: 'iPhone 15 Pro',
      price: 8999.0,
      purchaseDate: '2024-09-22',
      status: '服役中',
      iconEmoji: '📱',
      categoryName: '电子产品',
    ),
    (
      name: 'MacBook Pro 14',
      price: 14999.0,
      purchaseDate: '2024-03-15',
      status: '服役中',
      iconEmoji: '💻',
      categoryName: '电子产品',
    ),
    (
      name: 'AirPods Pro 2',
      price: 1899.0,
      purchaseDate: '2024-06-10',
      status: '服役中',
      iconEmoji: '🎧',
      categoryName: '电子产品',
    ),
    (
      name: 'iPad Air',
      price: 4799.0,
      purchaseDate: '2023-11-05',
      status: '服役中',
      iconEmoji: '📱',
      categoryName: '电子产品',
    ),
    (
      name: 'Sony PS5',
      price: 3899.0,
      purchaseDate: '2023-08-20',
      status: '服役中',
      iconEmoji: '🎮',
      categoryName: '电子产品',
    ),
    (
      name: '戴森吸尘器 V15',
      price: 4990.0,
      purchaseDate: '2023-06-18',
      status: '服役中',
      iconEmoji: '🔧',
      categoryName: '家居家具',
    ),
    (
      name: '小米电动滑板车',
      price: 1999.0,
      purchaseDate: '2022-05-01',
      status: '已退役',
      iconEmoji: '🛴',
      categoryName: '交通工具',
    ),
    (
      name: 'Kindle Paperwhite',
      price: 1068.0,
      purchaseDate: '2021-12-12',
      status: '已卖出',
      iconEmoji: '📚',
      categoryName: '书籍文具',
    ),
    (
      name: 'Nintendo Switch',
      price: 2199.0,
      purchaseDate: '2022-03-08',
      status: '已卖出',
      iconEmoji: '🎮',
      categoryName: '电子产品',
    ),
    (
      name: 'Apple Watch S9',
      price: 3199.0,
      purchaseDate: '2024-01-20',
      status: '服役中',
      iconEmoji: '⌚',
      categoryName: '电子产品',
    ),
    (
      name: '机械键盘 HHKB',
      price: 1699.0,
      purchaseDate: '2023-09-15',
      status: '服役中',
      iconEmoji: '⌨',
      categoryName: '电子产品',
    ),
    (
      name: '4K 显示器 Dell U2723',
      price: 3499.0,
      purchaseDate: '2023-04-22',
      status: '服役中',
      iconEmoji: '🖥',
      categoryName: '电子产品',
    ),
  ];

  for (final s in samples) {
    await db.insertAsset(
      AssetsCompanion(
        name: Value(s.name),
        price: Value(s.price),
        purchaseDate: Value(s.purchaseDate),
        status: Value(s.status),
        iconEmoji: Value(s.iconEmoji),
        categoryId: Value(catIds[s.categoryName]),
        owner: Value(owner),
      ),
    );
  }
}
