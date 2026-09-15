import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/asset_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/calculator.dart';
import '../utils/seed_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/asset_summary_card.dart';
import '../widgets/empty_state.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final useSeparator = settingsAsync.value?.useSeparator ?? false;

    return assetsAsync.when(
      data: (assets) {
        if (assets.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: '还没有资产记录',
            subtitle: '点击右下角 + 按钮添加你的第一笔资产',
            actionLabel: '加载示例数据',
            onAction: () async {
              final db = ref.read(databaseProvider);
              final owner = ref.read(currentOwnerProvider);
              await seedSampleData(db, owner);
              ref.invalidate(assetListProvider);
            },
          );
        }

        final totalValue = assets.fold<double>(0, (sum, a) => sum + a.price);
        final activeCount = assets.where((a) => a.status == '服役中').length;
        final inactiveCount = assets.where((a) => a.status != '服役中').length;
        final avgDailyCost = assets.isEmpty
            ? 0.0
            : assets.fold<double>(0, (sum, a) {
                    final days = calculateDaysUsed(a.purchaseDate);
                    return sum + calculateDailyCost(a.price, days);
                  }) /
                  assets.length;

        final recentAssets = assets.take(5).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '总资产价值',
                    value: formatCurrency(
                      totalValue,
                      useSeparator: useSeparator,
                    ),
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: '日均使用成本',
                    value: formatCurrency(
                      avgDailyCost,
                      useSeparator: useSeparator,
                    ),
                    icon: Icons.trending_down,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: '服役中',
                    value: '$activeCount',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: '已退役/已卖出',
                    value: '$inactiveCount',
                    icon: Icons.archive,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '最近添加',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recentAssets.map(
              (asset) => AssetSummaryCard(
                asset: asset,
                onTap: () => context.push('/assets/${asset.id}/edit'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
    );
  }
}
