import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Box<String> _catBox;
  final TextEditingController _ctrl = TextEditingController();
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
    _catBox = Hive.box<String>('categorias');

    // Sembrar categorías por defecto si no existen
    const defaultCategories = <String>[
      'General',
      'Comida',
      'Transporte',
      'Ocio',
      'Salud',
      'Otros',
    ];
    bool seeded = false;
    for (var cat in defaultCategories) {
      if (!_catBox.values.contains(cat)) {
        _catBox.add(cat);
        seeded = true;
      }
    }
    if (seeded) setState(() {});
  }

  Future<void> _addEditCategory({int? index}) async {
    if (_ctrl.text.trim().isEmpty) return;
    final value = _ctrl.text.trim();
    if (index == null) {
      await _catBox.add(value);
    } else {
      await _catBox.putAt(index, value);
    }
    _ctrl.clear();
    setState(() {});
    Navigator.of(context).pop();
  }

  void _showCategoryDialog({int? index}) {
    if (index != null) {
      _ctrl.text = _catBox.getAt(index)!;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Nueva categoría' : 'Editar categoría'),
        content: TextField(
          controller: _ctrl,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _addEditCategory(index: index),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ).then((_) => _ctrl.clear());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final cats = _catBox.values.toList();
  return Scaffold(
    appBar: AppBar(
      title: const Text('Categorías'),
    ),
    body: ListView.builder(
      itemCount: cats.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(cats[i]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showCategoryDialog(index: i),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _catBox.deleteAt(i);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showCategoryDialog(),
      child: const Icon(Icons.add),
    ),
    // Banner en el bottomNavigationBar:
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
