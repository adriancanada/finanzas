import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/movimiento.dart';

typedef OnSubmitMovimiento = Future<void> Function(Movimiento movimiento);

class NewMovementForm extends StatefulWidget {
  final OnSubmitMovimiento onSubmit;
  final Movimiento? editar;

  const NewMovementForm({super.key, required this.onSubmit, this.editar});

  @override
  State<NewMovementForm> createState() => _NewMovementFormState();
}

class _NewMovementFormState extends State<NewMovementForm> {
   // lista base siempre disponible
  static const List<String> _defaultCategories = [
    'General',
    'Comida',
    'Transporte',
    'Ocio',
    'Salud',
    'Otros',
  ];

  final _nombreCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  bool _esIngreso = true;
  String _categoria = _defaultCategories.first;
  late Box<String> _catBox;

  @override
  void initState() {
    super.initState();
    _catBox = Hive.box<String>('categorias');
    if (widget.editar != null) {
      _nombreCtrl.text = widget.editar!.nombre;
      _cantidadCtrl.text = widget.editar!.cantidad.toString();
      _esIngreso = widget.editar!.esIngreso;
      _categoria = widget.editar!.categoria;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nombre = _nombreCtrl.text.trim();
    final cantText = _cantidadCtrl.text.replaceAll(',', '.');
    final cantidad = double.tryParse(cantText) ?? 0;
    if (nombre.isEmpty || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y cantidad válidos')),
      );
      return;
    }
    final mov = Movimiento(
      id: widget.editar?.id ?? DateTime.now().toIso8601String(),
      nombre: nombre,
      cantidad: cantidad,
      fecha: widget.editar?.fecha ?? DateTime.now(),
      esIngreso: _esIngreso,
      categoria: _categoria,
    );
    await widget.onSubmit(mov);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
        // Unimos la lista base con las de la caja y quitamos duplicados
    final categoriasSet = <String>{..._defaultCategories, ..._catBox.values};
    final categorias = categoriasSet.toList();
    return Padding(
      padding: MediaQuery.of(context)
          .viewInsets
          .add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cantidadCtrl,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _categoria,
            items: categorias.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                )).toList(),
            onChanged: (v) => setState(() => _categoria = v!),
            decoration: const InputDecoration(labelText: 'Categoría'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Es Ingreso'),
              Switch(
                value: _esIngreso,
                onChanged: (v) => setState(() => _esIngreso = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.editar == null
                ? 'Añadir Movimiento'
                : 'Guardar Cambios'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
