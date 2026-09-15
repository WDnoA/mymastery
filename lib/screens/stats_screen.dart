import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/asset_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/calculator.dart';
import '../widgets/asset_trend_chart.dart';
import '../widgets/empty_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetListProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return assetsAsync.when(
      data: (assets) {
        if (assets.isEmpty) {
          return const EmptyState(
            icon: Icons.bar_chart,
            title: '暂无统计数据',
            subtitle: '添加资产后将自动生成统计图表',
          );
        }

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

        final useSeparator = settingsAsync.value?.useSeparator ?? false;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '资产统计',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTrendSection(context, ref),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              '总资产价值',
              formatCurrency(totalValue, useSeparator: useSeparator),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
            _buildStatRow(
              context,
              '日均使用成本',
              formatCurrency(avgDailyCost, useSeparator: useSeparator),
              Icons.trending_down,
              Colors.orange,
            ),
            _buildStatRow(
              context,
              '资产总数',
              '${assets.length} 件',
              Icons.inventory_2,
              Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              '状态分布',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatusBar(
              context,
              '服役中',
              activeCount,
              assets.length,
              Colors.green,
            ),
            _buildStatusBar(
              context,
              '已退役',
              retiredCount,
              assets.length,
              Colors.orange,
            ),
            _buildStatusBar(
              context,
              '已卖出',
              soldCount,
              assets.length,
              Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              '价值排行',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...assets
                .sortedBy((a) => -a.price)
                .take(10)
                .map((a) => _buildRankItem(context, a, useSeparator)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildTrendSection(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(assetMonthlyTrendProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '价值趋势（累计）',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            trendAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 200,
                child: Center(child: Text('趋势加载失败: $e')),
              ),
              data: (data) => AssetTrendChart(data: data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final ratio = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(
                '$count 件 (${(ratio * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(BuildContext context, Asset asset, bool useSeparator) {
    final days = calculateDaysUsed(asset.purchaseDate);
    final cost = calculateDailyCost(asset.price, days);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Text(asset.iconEmoji, style: const TextStyle(fontSize: 24)),
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('$days天 · ${asset.status}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(asset.price, useSeparator: useSeparator),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${formatCurrency(cost, useSeparator: useSeparator)}/天',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  List<T> sortedBy(num Function(T) compare) {
    final list = toList();
    list.sort((a, b) => compare(a).compareTo(compare(b)));
    return list;
  }
}
