import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyBarChart extends StatelessWidget {
  final Map<int, double> ingresos;
  final Map<int, double> gastos;
  final int diasEnMes;

  const DailyBarChart({
    super.key,
    required this.ingresos,
    required this.gastos,
    required this.diasEnMes,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos un ancho razonable por día
    const barWidth = 8.0;
    const groupSpacing = 4.0;
    final chartWidth = diasEnMes * (barWidth + groupSpacing) + 32;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.start,
            maxY: [
              ...gastos.values,
              ...ingresos.values,
            ].fold(0.0, (a, b) => a > b ? a : b) *
                1.2,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,         // espacio para la etiqueta
                  getTitlesWidget: (value, meta) {
                    final day = value.toInt();
                    return SideTitleWidget(
                      meta: meta,
                      child: Transform.rotate(
                        angle: -0.6,          // rota ~ -35º
                        child: Text(
                          '$day',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: null),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(diasEnMes, (i) {
              final day = i + 1;
              return BarChartGroupData(
                x: day,
                barsSpace: 2,
                barRods: [
                  BarChartRodData(
                    toY: gastos[day] ?? 0,
                    width: barWidth,
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: ingresos[day] ?? 0,
                    width: barWidth,
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
            groupsSpace: groupSpacing,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 4,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final tipo = rodIndex == 0 ? 'Gasto' : 'Ingreso';
                  return BarTooltipItem(
                    '$tipo día ${group.x}\n${rod.toY.toStringAsFixed(2)}€',
                    const TextStyle(color: Colors.black),
                  );
                },
                fitInsideHorizontally: true,
                fitInsideVertically: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
