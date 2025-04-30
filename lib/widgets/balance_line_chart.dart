// lib/widgets/balance_line_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BalanceLineChart extends StatelessWidget {
  final List<double> saldoDiario; // índice 0 = día 1, etc.
  const BalanceLineChart(this.saldoDiario, {super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        // Cámbialo por:
lineTouchData: LineTouchData(
  enabled: true,
  handleBuiltInTouches: true,
  touchTooltipData: LineTouchTooltipData(
    tooltipPadding: const EdgeInsets.all(8),
    tooltipMargin: 4,
    getTooltipColor: (spot) => Colors.grey.shade200, // ← Nuevo
    getTooltipItems: (spots) {
      return spots.map((spot) {
        return LineTooltipItem(
          'Día ${spot.x.toInt()}: ${spot.y.toStringAsFixed(2)}€',
          TextStyle(color: Theme.of(context).colorScheme.onSurface),
        );
      }).toList();
    },
    fitInsideHorizontally: true,
    fitInsideVertically: true,
  ),
),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 5, getTitlesWidget: (v, _) {
              return Text(v.toInt().toString());
            }),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
                saldoDiario.length,
                (i) => FlSpot(i + 1.0, saldoDiario[i])),
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: false),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
