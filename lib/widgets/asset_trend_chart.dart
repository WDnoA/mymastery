import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/asset_provider.dart';
import '../utils/calculator.dart';

/// 资产价值月度累计趋势折线图
class AssetTrendChart extends StatelessWidget {
  const AssetTrendChart({super.key, required this.data});

  final List<MonthlyValue> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('数据不足，暂无趋势图')),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value),
    ];

    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minY = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final yRange = maxY - minY;
    final yTop = maxY + yRange * 0.15;
    final yBottom = minY > 0 ? minY - yRange * 0.15 : 0.0;

    // 生成 4 条水平网格线的 Y 值
    final gridLines = <double>[
      for (var i = 0; i <= 4; i++) yBottom + (yTop - yBottom) * i / 4,
    ];

    // 数据点较多时，稀疏显示 X 轴标签避免重叠
    final xInterval = data.length <= 6 ? 1 : (data.length / 5).ceil();

    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = Theme.of(context).colorScheme.primary
        .withValues(alpha: 0.15);

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 8),
        child: LineChart(
          LineChartData(
            minY: yBottom,
            maxY: yTop,
            minX: -0.5,
            maxX: data.length > 1 ? data.length - 0.5 : 0.5,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (yTop - yBottom) / 4,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.shade200, strokeWidth: 0.5),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 52,
                  interval: (yTop - yBottom) / 4,
                  getTitlesWidget: (value, meta) {
                    // 只显示接近网格线的值
                    final isGridLine = gridLines.any(
                      (g) => (value - g).abs() < (yTop - yBottom) * 0.05,
                    );
                    if (!isGridLine) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        _formatYLabel(value),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: xInterval.toDouble(),
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if (index < 0 || index >= data.length) {
                      return const SizedBox.shrink();
                    }
                    // 只显示 MM 格式，如 "04"
                    final shortMonth = data[index].month.length >= 7
                        ? data[index].month.substring(5)
                        : data[index].month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        shortMonth,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: data.length > 2,
                curveSmoothness: 0.2,
                color: primaryColor,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: data.length <= 6 ? 4 : 2.5,
                      color: primaryColor,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(show: true, color: accentColor),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.x.round().clamp(0, data.length - 1);
                    return LineTooltipItem(
                      '${data[idx].month}\n${formatPrice(data[idx].value)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 将 Y 轴数值格式化为简短标签（如 1.2万、3456）
  String _formatYLabel(double value) {
    if (value.abs() >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万';
    }
    return value.toStringAsFixed(0);
  }
}
