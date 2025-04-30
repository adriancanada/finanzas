import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/movimiento.dart';
import '../widgets/new_movement_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bannerAdUnitId = 'ca-app-pub-1945530944392812~2471263396';

  late BannerAd _bannerAd;
  bool _isBannerLoaded = false;
  late final Box<Movimiento> _movBox;
  List<Movimiento> _movimientos = [];
  String _filtro = 'Todas';
    late final Box<String> _catBox;
  List<String> _cats = ['Todas'];
  

  @override
  void initState() {
    super.initState();
// Inicializamos la caja y el listado:
    _catBox = Hive.box<String>('categorias');
    _cats = ['Todas', ..._catBox.values.toSet()];

    // Listener para recargar al cambiar categorías:
    _catBox.listenable().addListener(() {
      setState(() {
        _cats = ['Todas', ..._catBox.values.toSet()];
        if (!_cats.contains(_filtro)) _filtro = 'Todas';
      });
    });

      // Carga del banner
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
    _movimientos = _movBox.values.toList();
    // Listener para que el filtro se refresque al arrancar y al cambiar categorías
  
}
  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  /// Formatea la cantidad quitando ceros innecesarios: 10.00→10, 10.50→10.5
  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Future<void> _addOrUpdate(Movimiento mov) async {
    final index = _movimientos.indexWhere((m) => m.id == mov.id);
    if (index < 0) {
      await _movBox.add(mov);
      setState(() => _movimientos.add(mov));
    } else {
      final key = _movBox.keyAt(index);
      await _movBox.put(key, mov);
      setState(() => _movimientos[index] = mov);
    }
  }

  void _removeItem(int index) async {
    final mov = _movimientos.removeAt(index);
    await _movBox.deleteAt(index);
    setState(() {});
  }

  void _openForm([Movimiento? mov]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewMovementForm(onSubmit: _addOrUpdate, editar: mov),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final listaFiltrada = _filtro == 'Todas'
        ? _movimientos
        : _movimientos.where((m) => m.categoria == _filtro).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Finanzas'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.of(context).pushNamed('/resumen')),
          IconButton(icon: const Icon(Icons.category), onPressed: () => Navigator.of(context).pushNamed('/categories').then((_) => setState(() {}))),
          IconButton(icon: const Icon(Icons.pie_chart), onPressed: () => Navigator.of(context).pushNamed('/category_summary')),
          IconButton(icon: const Icon(Icons.wallet), onPressed: () => Navigator.of(context).pushNamed('/presupuestos')),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.of(context).pushNamed('/settings')),
        ],
      ),
      body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.all(8.0),
  child: DropdownButton<String>(
    value: _filtro,
    items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
    onChanged: (v) => setState(() {
      _filtro = v!;
    }),
    isExpanded: true,
  ),
),
          Expanded(
            child: ListView.builder(
              itemCount: listaFiltrada.length,
              itemBuilder: (ctx, i) {
                final m = listaFiltrada[i];
                // índice real en storage
                final storageIndex = _movimientos.indexOf(m);
                final avatarColor = m.esIngreso ? Colors.green : Colors.red;
                final iconData = m.esIngreso ? Icons.arrow_upward : Icons.arrow_downward;
                final amountText = '${m.esIngreso ? '+' : '-'}${_formatNumber(m.cantidad)}€';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: avatarColor, child: Icon(iconData, color: Colors.white)),
                    title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${m.fecha.day}/${m.fecha.month}/${m.fecha.year} • ${m.categoria}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(amountText,
                          style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(icon: const Icon(Icons.mode_edit), color: cs.primary, onPressed: () => _openForm(m)),
                        IconButton(icon: const Icon(Icons.delete), color: cs.error, onPressed: () => _removeItem(storageIndex)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
           // Si el banner está cargado, lo mostramos
        
        ],
      ),
        // En lugar de meterlo en el body, lo ponemos aquí:
      bottomNavigationBar: _isBannerLoaded
        ? SizedBox(
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : null,

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: cs.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
