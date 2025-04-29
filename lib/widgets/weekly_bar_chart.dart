import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  /// Gastos por día de la semana (1 = Lunes ... 7 = Domingo)
  final Map<int, double> gastosSemana;
  /// Valor mínimo para escalar el eje Y (por ejemplo tu presupuesto global)
  final double? maxValue;

  const WeeklyBarChart({
    required this.gastosSemana,
    this.maxValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // 1) Encuentra el gasto máximo real en la semana
    final rawMax = gastosSemana.values.fold(0.0, (prev, e) => prev > e ? prev : e);
    // 2) Decide si usas maxValue (p.ej. presupuesto) o rawMax
    final baseMax = (maxValue != null && maxValue! > rawMax) ? maxValue! : rawMax;
    // 3) Evita que maxY sea 0, y añade un colchón del 20%
    final maxY = (baseMax == 0) ? 1.0 : baseMax * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        groupsSpace: 16,
        barGroups: List.generate(7, (i) {
          final value = gastosSemana[i + 1] ?? 0.0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 24,
                borderRadius: BorderRadius.circular(4),
                color: cs.error,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: cs.surfaceVariant,
                ),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 28,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx > 6) return const SizedBox();
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(labels[idx], style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(6),
            tooltipMargin: 4,
            getTooltipColor: (BarChartGroupData _) => cs.surface,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              return BarTooltipItem(
                '${labels[group.x]}: €${rod.toY.toStringAsFixed(2)}',
                TextStyle(color: cs.onSurface),
              );
            },
          ),
        ),
      ),
    );
  }
}
