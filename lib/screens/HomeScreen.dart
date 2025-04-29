import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/movimiento.dart';
import '../widgets/new_movement_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box<Movimiento> _movBox;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<Movimiento> _movimientos = [];
  String _filtro = 'Todas';

  @override
  void initState() {
    super.initState();
    _movBox = Hive.box<Movimiento>('movimientos');
    _movimientos = _movBox.values.toList();
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
      _movimientos.add(mov);
      _listKey.currentState?.insertItem(_movimientos.length - 1);
    } else {
      final key = _movBox.keyAt(index);
      await _movBox.put(key, mov);
      setState(() => _movimientos[index] = mov);
    }
  }

  void _removeItem(int index) async {
    final removed = _movimientos.removeAt(index);
    await _movBox.deleteAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildTile(removed, index),
      ),
    );
  }

  void _openForm([Movimiento? mov]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NewMovementForm(onSubmit: _addOrUpdate, editar: mov),
    );
  }

  Widget _buildTile(Movimiento m, int index) {
    final cs = Theme.of(context).colorScheme;
    final amountText = (m.esIngreso ? '+' : '-') + _formatNumber(m.cantidad) + '€';

    // Icono para ingresos/egresos: arriba verde para ingresos, abajo rojo para gastos
    final avatarColor = m.esIngreso ? Colors.green : Colors.red;
    final iconData = m.esIngreso ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Icon(
            iconData,
            color: Colors.white,
          ),
        ),
        title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${m.fecha.day}/${m.fecha.month}/${m.fecha.year} • ${m.categoria}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountText,
              style: TextStyle(
                color: m.esIngreso ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mode_edit),
              color: cs.primary,
              onPressed: () => _openForm(m),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: cs.error,
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
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
          IconButton(icon: const Icon(Icons.category), onPressed: () => Navigator.of(context).pushNamed('/categories')),
          IconButton(icon: const Icon(Icons.pie_chart), onPressed: () => Navigator.of(context).pushNamed('/category_summary')),
          IconButton(icon: const Icon(Icons.wallet), onPressed: () => Navigator.of(context).pushNamed('/presupuestos')),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.of(context).pushNamed('/settings')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ValueListenableBuilder<Box<String>>(
              valueListenable: Hive.box<String>('categorias').listenable(),
              builder: (context, box, _) {
                final categorias = ['Todas', ...box.values.toSet()];
                if (!categorias.contains(_filtro)) _filtro = 'Todas';
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _filtro,
                      items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: cs.onSurfaceVariant)))).toList(),
                      onChanged: (v) => setState(() => _filtro = v!),
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: listaFiltrada.length,
              itemBuilder: (ctx, i, animation) => SizeTransition(
                sizeFactor: animation,
                child: _buildTile(listaFiltrada[i], _movimientos.indexOf(listaFiltrada[i])),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: cs.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}