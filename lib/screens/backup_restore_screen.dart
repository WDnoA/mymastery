import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../providers/asset_provider.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final _importController = TextEditingController();
  bool _importing = false;

  Future<void> _exportData() async {
    final db = ref.read(databaseProvider);
    final assets = await db.getAllAssets();

    if (assets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('暂无数据可导出')),
        );
      }
      return;
    }

    final jsonList = assets.map((a) => {
          'name': a.name,
          'price': a.price,
          'purchaseDate': a.purchaseDate,
          'status': a.status,
          'iconEmoji': a.iconEmoji,
          'categoryId': a.categoryId,
        }).toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);

    await Clipboard.setData(ClipboardData(text: jsonStr));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导出 ${assets.length} 条资产数据到剪贴板'),
          action: SnackBarAction(
            label: '查看',
            onPressed: () => _showPreview(jsonStr),
          ),
        ),
      );
    }
  }

  void _showPreview(String json) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导出数据预览'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData() async {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请粘贴 JSON 数据')),
      );
      return;
    }

    setState(() => _importing = true);

    try {
      final List<dynamic> jsonList = jsonDecode(text);
      final db = ref.read(databaseProvider);

      int count = 0;
      for (final item in jsonList) {
        if (item is Map<String, dynamic> &&
            item.containsKey('name') &&
            item.containsKey('price')) {
          await db.insertAsset(AssetsCompanion(
            name: Value(item['name'].toString()),
            price: Value((item['price'] as num).toDouble()),
            purchaseDate: Value(item['purchaseDate']?.toString() ?? '2024-01-01'),
            status: Value(item['status']?.toString() ?? '服役中'),
            iconEmoji: Value(item['iconEmoji']?.toString() ?? '📱'),
            categoryId: item['categoryId'] != null
                ? Value<int?>(item['categoryId'] as int?)
                : const Value.absent(),
          ));
          count++;
        }
      }

      ref.invalidate(assetListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 $count 条资产数据')),
        );
        _importController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      setState(() => _importing = false);
    }
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '导出数据',
            icon: Icons.backup_outlined,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '将所有资产数据导出为 JSON 格式，复制到剪贴板后可以保存到文件或发送给他人。',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.copy),
                  label: const Text('导出到剪贴板'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '导入数据',
            icon: Icons.restore_outlined,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _importController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '粘贴 JSON 数据',
                    hintText: '将之前导出的 JSON 数据粘贴到这里',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FilledButton.icon(
                  onPressed: _importing ? null : _importData,
                  icon: _importing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_upload),
                  label: Text(_importing ? '导入中...' : '导入数据'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.amber[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '导入数据不会覆盖已有数据，新数据会追加到现有列表中。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}