import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'auth_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// 当前数据归属空间（来自登录状态），游客为 guest，登录后为账号名
final currentOwnerProvider = Provider<String>((ref) {
  final authAsync = ref.watch(authProvider);
  return authAsync.value?.owner ?? 'guest';
});

/// 当前空间下的资产列表，登录/切换账号时会自动重建
final assetListProvider = FutureProvider<List<Asset>>((ref) async {
  final db = ref.watch(databaseProvider);
  final owner = ref.watch(currentOwnerProvider);
  return db.getAssetsByOwner(owner);
});

/// 月度趋势数据点：某月份的累计资产总价值
class MonthlyValue {
  const MonthlyValue(this.month, this.value);

  /// 格式为 yyyy-MM
  final String month;
  final double value;
}

/// 按购买月份累计资产总价值，用于趋势图（X 为月份，Y 为累计金额）
final assetMonthlyTrendProvider = FutureProvider<List<MonthlyValue>>((
  ref,
) async {
  final assets = await ref.watch(assetListProvider.future);
  final map = <String, double>{};
  for (final a in assets) {
    String month;
    try {
      month = a.purchaseDate.substring(0, 7);
    } catch (_) {
      month = '未知';
    }
    map[month] = (map[month] ?? 0) + a.price;
  }
  final monthList = map.keys.toList()..sort();
  var cumulative = 0.0;
  return monthList.map((m) {
    cumulative += map[m]!;
    return MonthlyValue(m, cumulative);
  }).toList();
});
