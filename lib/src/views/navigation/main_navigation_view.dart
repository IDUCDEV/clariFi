import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Vista principal con NavigationBar para navegar entre las secciones principales
/// Ahora usa navegación declarativa con go_router
class MainNavigationView extends StatelessWidget {
  final Widget child;
  
  const MainNavigationView({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/budgets');
              break;
            case 2:
              context.go('/transactions');
              break;
            case 3:
              context.go('/reports');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.pie_chart),
            icon: Icon(Icons.pie_chart_outline),
            label: 'Presupuestos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.receipt_long),
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transacciones',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bar_chart),
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reportes',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  /// Calcula el índice seleccionado basado en la ruta actual
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/budgets')) {
      return 1;
    }
    if (location.startsWith('/transactions')) {
      return 2;
    }
    if (location.startsWith('/reports')) {
      return 3;
    }
    if (location.startsWith('/settings') || location.startsWith('/accounts')) {
      return 4; // Settings o rutas relacionadas como accounts
    }
    
    return 0; // Default a Inicio
  }
}
