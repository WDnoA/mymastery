import 'package:intl/intl.dart';

/// 计算已使用天数
int calculateDaysUsed(String purchaseDate) {
  final purchase = DateTime.parse(purchaseDate);
  final today = DateTime.now();
  return today.difference(purchase).inDays;
}

/// 计算日均成本
double calculateDailyCost(double price, int daysUsed) {
  if (daysUsed <= 0) return price;
  return price / daysUsed;
}

/// 格式化金额（带千位分隔符，保留2位小数）
String formatCurrency(double amount, {bool useSeparator = false}) {
  if (useSeparator) {
    final formatter = NumberFormat('#,##0.00');
    return '¥${formatter.format(amount)}';
  }
  return '¥${amount.toStringAsFixed(2)}';
}

/// 价格格式化（无千位分隔符，保留2位小数）
String formatPrice(double amount) {
  return '¥${amount.toStringAsFixed(2)}';
}