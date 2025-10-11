import 'package:flutter/material.dart';

/// Vista de Reportes - Placeholder para implementación futura
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Reportes',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visualiza tus estadísticas financieras',
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
    );
  }
}
