import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import '../providers/asset_provider.dart';

class AddEditAssetScreen extends ConsumerStatefulWidget {
  final int? assetId;

  const AddEditAssetScreen({super.key, this.assetId});

  @override
  ConsumerState<AddEditAssetScreen> createState() => _AddEditAssetScreenState();
}

class _AddEditAssetScreenState extends ConsumerState<AddEditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late DateTime _purchaseDate;
  late String _status;
  late String _selectedEmoji;
  int? _categoryId;

  bool get isEditing => widget.assetId != null;

  static const _emojis = [
    '📱',
    '💻',
    '⌚',
    '🎧',
    '📷',
    '🎮',
    '🖥',
    '📺',
    '🚗',
    '🏍',
    '🚲',
    '🏠',
    '🛋',
    '🪑',
    '🛏',
    '🔧',
    '🎸',
    '🎹',
    '🥁',
    '🎨',
    '📚',
    '🎒',
    '👟',
    '⌨',
  ];

  static const _statuses = ['服役中', '已退役', '已卖出'];

  static const _categories = [
    {'name': '电子产品', 'emoji': '📱'},
    {'name': '家居家具', 'emoji': '🛋'},
    {'name': '交通工具', 'emoji': '🚗'},
    {'name': '乐器设备', 'emoji': '🎸'},
    {'name': '运动户外', 'emoji': '👟'},
    {'name': '书籍文具', 'emoji': '📚'},
    {'name': '其他', 'emoji': '📦'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _purchaseDate = DateTime.now();
    _status = '服役中';
    _selectedEmoji = '📱';
    _categoryId = null;

    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAsset();
      });
    }
  }

  Future<void> _loadAsset() async {
    final db = ref.read(databaseProvider);
    final asset = await db.getAssetById(widget.assetId!);
    if (asset != null && mounted) {
      setState(() {
        _nameController.text = asset.name;
        _priceController.text = asset.price.toString();
        _purchaseDate = DateTime.parse(asset.purchaseDate);
        _status = asset.status;
        _selectedEmoji = asset.iconEmoji;
        _categoryId = asset.categoryId;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);
    final entry = AssetsCompanion(
      name: Value(_nameController.text.trim()),
      price: Value(double.parse(_priceController.text.trim())),
      purchaseDate: Value(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
      status: Value(_status),
      iconEmoji: Value(_selectedEmoji),
      categoryId: Value<int?>(_categoryId),
    );

    if (isEditing) {
      final existing = await db.getAssetById(widget.assetId!);
      if (existing != null) {
        final updated = existing.copyWith(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          purchaseDate: DateFormat('yyyy-MM-dd').format(_purchaseDate),
          status: _status,
          iconEmoji: _selectedEmoji,
          categoryId: Value<int?>(_categoryId),
        );
        await db.updateAsset(updated);
      }
    } else {
      await db.insertAsset(entry);
    }

    ref.invalidate(assetListProvider);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? '编辑资产' : '添加资产')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '选择图标',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final selected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '资产名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入资产名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '购买价格',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '¥ ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入购买价格';
                final price = double.tryParse(v.trim());
                if (price == null || price <= 0) return '请输入有效的价格';
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _purchaseDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '购买日期',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_purchaseDate)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: '资产分类',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('未分类')),
                for (int i = 0; i < _categories.length; i++)
                  DropdownMenuItem<int?>(
                    value: i,
                    child: Text(
                      '${_categories[i]['emoji']} ${_categories[i]['name']}',
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? '保存修改' : '添加资产'),
            ),
          ],
        ),
      ),
    );
  }
}
