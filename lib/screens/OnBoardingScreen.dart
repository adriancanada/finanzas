import 'package:flutter/material.dart';
import 'package:finanzas_app/screens/HomeScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late Box _settingsBox;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Añade tus finanzas',
      description: 'Registra ingresos y gastos con un solo toque.',
      icon: Icons.add_circle_outline,
    ),
    _OnboardingPage(
      title: 'Filtra fácilmente',
      description: 'Visualiza movimientos por categoría al instante.',
      icon: Icons.filter_list,
    ),
    _OnboardingPage(
      title: 'Ve tus reportes',
      description: 'Consulta resúmenes diarios y por categoría.',
      icon: Icons.pie_chart_outline,
    ),
    _OnboardingPage(
      title: 'Gráficos interactivos',
      description: 'Descubre tus tendencias diarias y mensuales de un vistazo.',
      icon: Icons.show_chart,
    ),
    _OnboardingPage(
      title: 'Recibe notificaciones',
      description: 'Recibe alertas cuando te acerques a tu presupuesto definido.',
      icon: Icons.notifications_active,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
  }

  void _finishOnboarding() {
    _settingsBox.put('seenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (ctx, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 120, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(p.title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(p.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Theme.of(context).colorScheme.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _finishOnboarding
                      : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  child: Text(_currentPage == _pages.length - 1 ? 'Comenzar' : 'Siguiente'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardingPage({required this.title, required this.description, required this.icon});
}
