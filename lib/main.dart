import 'package:finanzas_app/services/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/CategoriesScreen.dart';
import 'screens/CategorySummaryScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/OnBoardingScreen.dart';
import 'screens/PresupuestosScreen';
import 'screens/ResumenScreen.dart';
import 'screens/SettingsScreen.dart';
import 'models/movimiento.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MovimientoAdapter());
  await Hive.openBox<Movimiento>('movimientos');
  await Hive.openBox<String>('categorias');
  await Hive.openBox<double>('presupuestos');
   final settingsBox = await Hive.openBox('settings');           // ← aquí
  final seenOnboarding = settingsBox.get('seenOnboarding',       // ← y aquí
      defaultValue: false) as bool;
  await NotificationService.init();
    runApp(FinanzasApp(seenOnboarding: seenOnboarding));
}

class FinanzasApp extends StatelessWidget {
  final bool seenOnboarding;
  const FinanzasApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(seedColor: Colors.teal);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finanzas Simples',
      theme: ThemeData(
        colorScheme: base.copyWith(
          primary: base.primary,
          onPrimary: Colors.white,
          secondary: base.secondary,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: base.primaryContainer,
          foregroundColor: base.onPrimaryContainer,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: base.onPrimaryContainer,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      // aquí decides la pantalla inicial:
      home: seenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
      routes: {
      //  '/': (_) => const HomeScreen(),
        '/categories': (_) => const CategoriesScreen(),
        '/resumen': (_) => const ResumenScreen(),
         '/presupuestos': (_) => const PresupuestosScreen(),
        '/category_summary': (_) => const CategorySummaryScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
