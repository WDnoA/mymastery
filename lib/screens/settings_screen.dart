import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          context,
          title: '数值与单位',
          children: [
            _buildSwitchTile(
              context,
              title: '使用千位分隔符',
              subtitle: '金额显示如 ¥1,234.56',
              value: settings.useSeparator,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setUseSeparator(v),
            ),
            _buildSegmentedControl(
              context,
              title: '时长显示格式',
              value: settings.durationFormat,
              options: const ['天数', '日期'],
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setDurationFormat(v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: '数据管理',
          children: [
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('分类管理'),
              subtitle: const Text('管理资产分类'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/categories'),
            ),
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('备份与恢复'),
              subtitle: const Text('导出或导入数据'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/backup'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          title: '关于',
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于我的精通'),
              subtitle: const Text('版本 1.0.0'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSegmentedControl(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: options
                .map((o) => ButtonSegment<String>(value: o, label: Text(o)))
                .toList(),
            selected: {value},
            onSelectionChanged: (v) => onChanged(v.first),
          ),
        ],
      ),
    );
  }
}
