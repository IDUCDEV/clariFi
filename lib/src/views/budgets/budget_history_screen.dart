import 'package:clarifi_app/src/widgets/budget_item_card.dart';
import 'package:clarifi_app/src/widgets/export_button.dart';
import 'package:clarifi_app/src/widgets/filter_chips.dart';
import 'package:clarifi_app/src/widgets/summary_card.dart';
import 'package:flutter/material.dart';


class BudgetHistoryScreen extends StatelessWidget {
  const BudgetHistoryScreen({super.key});

  // Datos de ejemplo
  List<Budget> _sampleBudgets() {
    return [
      Budget(
        month: 'Julio',
        year: '2023',
        title: 'Julio de 2023',
        compliancePercent: 90,
        budget: 2000,
        spent: 1800,
        status: BudgetStatus.good,
      ),
      Budget(
        month: 'Junio',
        year: '2023',
        title: 'Junio de 2023',
        compliancePercent: 112,
        budget: 2500,
        spent: 2800,
        status: BudgetStatus.over,
      ),
      Budget(
        month: 'Mayo',
        year: '2023',
        title: 'Mayo de 2023',
        compliancePercent: 83,
        budget: 1800,
        spent: 1500,
        status: BudgetStatus.good,
      ),
      Budget(
        month: 'Abril',
        year: '2023',
        title: 'Abril de 2023',
        compliancePercent: 91,
        budget: 2200,
        spent: 2000,
        status: BudgetStatus.good,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final budgets = _sampleBudgets();
    // calcular promedio simple
    final avg = (budgets.map((b) => b.compliancePercent).reduce((a, b) => a + b) / budgets.length).round();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Historia del presupuesto',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const FilterChips(), // Componente de filtros (visual)
            const SizedBox(height: 18),
            SummaryCard(averageCompliance: avg),
            const SizedBox(height: 18),
            // Header de la lista con export
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Presupuestos históricos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                ExportButton(onExport: () {
                  // TODO: acción de export, por ahora simple snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportando... (mock)')),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            // Lista
            Expanded(
              child: ListView.separated(
                itemCount: budgets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = budgets[index];
                  return BudgetItemCard(budget: b);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
