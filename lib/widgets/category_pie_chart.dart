import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  const CategoryPieChart(this.data, {Key? key}) : super(key: key);

  // Formatea un número y quita ceros y punto sobrantes: 
  // 10.00 → "10",  10.50 → "10.5",  10.25 → "10.25"
  String _formatNumber(double value, {int decimals = 2}) {
    var s = value.toStringAsFixed(decimals);
    if (s.contains('.')) {
      // quita ceros al final
      s = s.replaceAll(RegExp(r'0+$'), '');
      // si queda un punto al final, lo quita también
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final categories = data.keys.toList();
    final values     = data.values.toList();
    final total      = values.fold(0.0, (a, b) => a + b);

    final colors = <Color>[
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: List.generate(categories.length, (i) {
          final pct = values[i] / (total > 0 ? total : 1);
          final displayPct = _formatNumber(pct * 100, decimals: 1);
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: values[i],
            title: '${displayPct}%',
            radius: 60,
            showTitle: pct > 0.05,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response != null && response.touchedSection != null) {
              final idx    = response.touchedSection!.touchedSectionIndex;
              final cat    = categories[idx];
              final amount = values[idx];
              final displayAmt = _formatNumber(amount, decimals: 2);
              final snackBar = SnackBar(
                content: Text('$cat: ${displayAmt}€'),
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
        ),
      ),
    );
  }
}
