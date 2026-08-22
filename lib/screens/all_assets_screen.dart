import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/database.dart';
import '../providers/asset_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/calculator.dart';
import '../utils/seed_data.dart';
import '../widgets/asset_list_item.dart';
import '../widgets/empty_state.dart';

class AllAssetsScreen extends ConsumerWidget {
  const AllAssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetListProvider);
    final settings = ref.watch(settingsProvider);

    return assetsAsync.when(
      data: (assets) {
        if (assets.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: '还没有资产记录',
            subtitle: '点击右下角 + 按钮添加资产',
            actionLabel: '加载示例数据',
            onAction: () async {
              final db = ref.read(databaseProvider);
              await seedSampleData(db);
              ref.invalidate(assetListProvider);
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            final daysUsed = calculateDaysUsed(asset.purchaseDate);
            final dailyCost = calculateDailyCost(asset.price, daysUsed);
            final showDays = settings.durationFormat == '天数';

            return AssetListItem(
              asset: asset,
              daysUsed: daysUsed,
              dailyCost: dailyCost,
              useSeparator: settings.useSeparator,
              showDays: showDays,
              onTap: () => context.push('/assets/${asset.id}/edit'),
              onDelete: () => _showDeleteDialog(context, ref, asset),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('加载失败: $error')),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Asset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${asset.name}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final db = ref.read(databaseProvider);
              await db.deleteAsset(asset.id);
              ref.invalidate(assetListProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}