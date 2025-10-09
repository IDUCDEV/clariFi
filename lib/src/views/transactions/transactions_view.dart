import 'package:flutter/material.dart';

/// Vista de Transacciones - Placeholder para implementación futura
class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Transacciones',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Registra y consulta tus movimientos',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navegar a formulario de nueva transacción
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidad en desarrollo')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Transacción'),
      ),
    );
  }
}
