import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../budgets/budgets_view.dart';
import '../transactions/transactions_view.dart';
import '../reports/reports_view.dart';
import '../settings/settings_view.dart';

/// Vista principal con NavigationBar para navegar entre las secciones principales
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        /// Página de Inicio
        const HomeView(),
        
        /// Página de Presupuestos
        const BudgetsView(),
        
        /// Página de Transacciones
        const TransactionsView(),
        
        /// Página de Reportes
        const ReportsView(),
        
        /// Página de Ajustes
        const SettingsView(),
      ][_currentPageIndex],
      
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
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
}
