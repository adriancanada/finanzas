// lib/screens/category_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/movimiento.dart';

class CategorySummaryScreen extends StatefulWidget {
  const CategorySummaryScreen({super.key});

  @override
  State<CategorySummaryScreen> createState() => _CategorySummaryScreenState();
}

class _CategorySummaryScreenState extends State<CategorySummaryScreen> {
  late final Box<Movimiento> _movBox;
  late final Box<String> _catBox;
  late final Box<double> _presuBox;
  late Map<String, double> _totales;
    static const _bannerAdUnitId = 'ca-app-pub-1945530944392812~2471263396';
  late BannerAd _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
     _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (_, __) => _isBannerLoaded = false,
      ),
    )..load();
    _movBox = Hive.box<Movimiento>('movimientos');
    _catBox = Hive.box<String>('categorias');
    _presuBox = Hive.box<double>('presupuestos');
    _calcularTotales();
  }

  void _calcularTotales() {
    final ahora = DateTime.now();
    final categorias = _catBox.values.toSet();
    _totales = {for (var c in categorias) c: 0.0};
    for (var mov in _movBox.values) {
      if (mov.fecha.year == ahora.year && mov.fecha.month == ahora.month) {
        final gasto = mov.esIngreso ? 0.0 : mov.cantidad;
        _totales[mov.categoria] = (_totales[mov.categoria] ?? 0) + gasto;
      }
    }
  }

 @override
Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  _calcularTotales();

  final cats = _presuBox.keys
      .where((k) => k != 'Global' && (_presuBox.get(k) ?? 0.0) > 0)
      .cast<String>()
      .toList();
  cats.sort((a, b) => (_totales[b] ?? 0.0).compareTo(_totales[a] ?? 0.0));

  return Scaffold(
    appBar: AppBar(title: const Text('Resumen por Categoría')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: cats.isEmpty
          ? Center(
              child: Text(
                'No hay presupuestos por categoría definidos.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              itemCount: cats.length,
              itemBuilder: (ctx, i) {
                final cat = cats[i];
                final spent = _totales[cat] ?? 0.0;
                final budg = (_presuBox.get(cat) ?? 0.0).toDouble();
                final pct = budg > 0 ? (spent / budg).clamp(0.0, 1.0) : 0.0;
                // Colores según porcentaje usado
                Color bgColor;
                Color textColor;
                if (pct >= 1.0) {
                  bgColor = cs.error;
                  textColor = Colors.white;
                } else if (pct >= 0.8) {
                  bgColor = cs.secondary;
                  textColor = Colors.white;
                } else {
                  bgColor = cs.surfaceContainerHighest;
                  textColor = cs.onSurfaceVariant;
                }
                // Color del anillo
                final ringColor = pct >= 0.8 ? Colors.white : cs.secondary;

                return Card(
                  color: bgColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: pct,
                                strokeWidth: 6,
                                backgroundColor: cs.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(ringColor),
                              ),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${spent.toStringAsFixed(2)} / ${budg.toStringAsFixed(2)}€',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ),
    // Banner en el bottomNavigationBar
    bottomNavigationBar: _isBannerLoaded
        ? SizedBox(
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : null,
  );
}

}
