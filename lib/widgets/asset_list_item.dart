import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';

class AssetListItem extends StatelessWidget {
  final Asset asset;
  final int daysUsed;
  final double dailyCost;
  final bool useSeparator;
  final bool showDays;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AssetListItem({
    super.key,
    required this.asset,
    required this.daysUsed,
    required this.dailyCost,
    this.useSeparator = false,
    this.showDays = true,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (asset.status) {
      case '服役中':
        return Colors.green;
      case '已退役':
        return Colors.orange;
      case '已卖出':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatPrice(double v) {
    if (useSeparator) {
      return '¥${NumberFormat('#,##0.00').format(v)}';
    }
    return '¥${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final timeDisplay = showDays ? '$daysUsed天' : asset.purchaseDate;

    return Dismissible(
      key: Key('asset_${asset.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ListTile(
        onTap: onTap,
        onLongPress: onDelete,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(asset.iconEmoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_formatPrice(asset.price)} · ${asset.status} · $timeDisplay · ${_formatPrice(dailyCost)}/天',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            asset.status,
            style: TextStyle(
              fontSize: 12,
              color: _statusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
