import 'package:flutter/material.dart';

import '../database/database.dart';
import '../utils/calculator.dart';

class AssetSummaryCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const AssetSummaryCard({super.key, required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysUsed = calculateDaysUsed(asset.purchaseDate);
    final dailyCost = calculateDailyCost(asset.price, daysUsed);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(asset.iconEmoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${formatPrice(asset.price)} · $daysUsed天',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(dailyCost),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text('/天', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}