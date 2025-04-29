import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/movimiento.dart';
import '../widgets/daily_bar_chart.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/balance_line_chart.dart';

class ResumenScreen extends StatefulWidget {
  const ResumenScreen({Key? key}) : super(key: key);

  @override
  State<ResumenScreen> createState() => _ResumenScreenState();
}

class _ResumenScreenState extends State<ResumenScreen> {
  late final Box<Movimiento> _movBox;
  late final Box<double> _presuBox;

  Map<int, double> _ingresosPorDia = {};
  Map<int, double> _gastosPorDia = {};
  Map<String, double> _expensePorCategoria = {};
  double _totalIngresos = 0;
  double _totalGastos = 0;
  double _saldo = 0;

  @override
  void initState() {
    super.initState();
    _movBox = Hive.box<Movimiento>('movimientos');
    _presuBox = Hive.box<double>('presupuestos');
  }

  /// Formatea un número quitando ceros innecesarios: 10.00→10, 10.50→10.5
  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Widget _buildBudgetIndicator(String title, double used, double budget, Color color) {
    final pct = budget > 0 ? (used / budget).clamp(0.0, 1.0) : 0.0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '${_formatNumber(used)} / ${_formatNumber(budget)}€',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  void _calcularResumen(Iterable<Movimiento> movimientos) {
    final ahora = DateTime.now();
    final diasEnMes = DateTime(ahora.year, ahora.month + 1, 0).day;

    _ingresosPorDia = {for (var d = 1; d <= diasEnMes; d++) d: 0};
    _gastosPorDia = {for (var d = 1; d <= diasEnMes; d++) d: 0};
    _expensePorCategoria.clear();
    _totalIngresos = 0;
    _totalGastos = 0;

    for (var mov in movimientos) {
      if (mov.fecha.year == ahora.year && mov.fecha.month == ahora.month) {
        final dia = mov.fecha.day;
        if (mov.esIngreso) {
          _ingresosPorDia[dia] = _ingresosPorDia[dia]! + mov.cantidad;
          _totalIngresos += mov.cantidad;
        } else {
          _gastosPorDia[dia] = _gastosPorDia[dia]! + mov.cantidad;
          _totalGastos += mov.cantidad;
          _expensePorCategoria[mov.categoria] =
              (_expensePorCategoria[mov.categoria] ?? 0) + mov.cantidad;
        }
      }
    }
    _saldo = _totalIngresos - _totalGastos;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final globalBudget = _presuBox.get('Global') ?? 0.0;

    final budgetCats = _presuBox.keys
        .where((k) => k != 'Global' && (_presuBox.get(k) ?? 0) > 0)
        .cast<String>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen Mensual')),
      body: ValueListenableBuilder<Box<Movimiento>>(
        valueListenable: _movBox.listenable(),
        builder: (_, box, __) {
          _calcularResumen(box.values);

          final ahora = DateTime.now();
          final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
          final gastosSemana = {for (var i = 1; i <= 7; i++) i: 0.0};
          for (var mov in box.values) {
            if (!mov.esIngreso && mov.fecha.isAfter(inicioSemana.subtract(const Duration(seconds: 1))) &&
                mov.fecha.isBefore(inicioSemana.add(const Duration(days: 7)))) {
              gastosSemana[mov.fecha.weekday] = gastosSemana[mov.fecha.weekday]! + mov.cantidad;
            }
          }

          final diasEnMes = DateTime(ahora.year, ahora.month + 1, 0).day;
          double acumulado = 0;
          final saldoDiarioList = <double>[];
          for (var d = 1; d <= diasEnMes; d++) {
            acumulado += (_ingresosPorDia[d] ?? 0) - (_gastosPorDia[d] ?? 0);
            saldoDiarioList.add(acumulado);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Resumen Mensual',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text('Ingresos', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                Text(
                                  '+${_formatNumber(_totalIngresos)}€',
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Gastos', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                Text(
                                  '-${_formatNumber(_totalGastos)}€',
                                  style: TextStyle(
                                    color: cs.error,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Saldo', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                Text(
                                  '${_formatNumber(_saldo)}€',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text('Gasto diario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: WeeklyBarChart(
                    gastosSemana: gastosSemana,
                    maxValue: globalBudget,
                  ),
                ),
                const SizedBox(height: 24),
                if (globalBudget > 0) ...[
                  _buildBudgetIndicator('Presupuesto Global', _totalGastos, globalBudget, cs.primary),
                  const SizedBox(height: 24),
                ],
                const Text('Presupuesto por Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (budgetCats.isEmpty)
                  Text('No hay presupuestos definidos.', style: TextStyle(color: cs.onSurfaceVariant)),
                for (var cat in budgetCats)
                  _buildBudgetIndicator(cat, _expensePorCategoria[cat] ?? 0.0, (_presuBox.get(cat) ?? 0.0), cs.secondary),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: CategoryPieChart(_expensePorCategoria),
                ),
                const SizedBox(height: 24),
                // SizedBox(
                //   height: 200,
                //   child: BalanceLineChart(saldoDiarioList),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}