import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // para Clipboard
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/movimiento.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box<Movimiento> _movBox;
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
  }

  Future<void> _exportData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'movimientos_export_${DateTime.now().toIso8601String()}.json';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      final data = _movBox.values.map((m) => {
            'id': m.id,
            'nombre': m.nombre,
            'cantidad': m.cantidad,
            'fecha': m.fecha.toIso8601String(),
            'esIngreso': m.esIngreso,
            'categoria': m.categoria,
          }).toList();
      await file.writeAsString(jsonEncode(data));

      // Mostrar diálogo con la ruta y botón de copiar
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Exportación completada'),
          content: Text('Archivo guardado en:\n$filePath'),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: filePath));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ruta copiada al portapapeles')),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Copiar ruta'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exportando: $e')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      final typeGroup = XTypeGroup(
        label: 'json',
        extensions: ['json'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);
      int added = 0;
      for (var item in data) {
        if (!_movBox.values.any((m) => m.id == item['id'])) {
          final mov = Movimiento(
            id: item['id'],
            nombre: item['nombre'],
            cantidad: (item['cantidad'] as num).toDouble(),
            fecha: DateTime.parse(item['fecha']),
            esIngreso: item['esIngreso'] as bool,
            categoria: item['categoria'] as String,
          );
          await _movBox.add(mov);
          added++;
        }
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Importados \$added nuevos movimientos')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importando: \$e')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Ajustes / Respaldo')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Exportar movimientos'),
            onPressed: _exportData,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.download_rounded),
            label: const Text('Importar movimientos'),
            onPressed: _importData,
          ),
        ],
      ),
    ),

    // Banner en la parte inferior
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
