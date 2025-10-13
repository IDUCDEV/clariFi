import 'package:clarifi_app/src/viewmodels/budget_viewmodel.dart';
import 'package:clarifi_app/src/widgets/BudgetItemToListBudgetDarshboard.dart';
import 'package:clarifi_app/src/widgets/budgetsVisualizer.dart';
import 'package:clarifi_app/src/widgets/listDropDownBudgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DashboardBudgets extends StatefulWidget {
  const DashboardBudgets({super.key});

  @override
  State<DashboardBudgets> createState() => _DashboardBudgetsState();
}

class _DashboardBudgetsState extends State<DashboardBudgets> {



  @override
  void initState() {
    super.initState();
    final budgetViewModel = Provider.of<BudgetViewModel>(context, listen: false);
    budgetViewModel.loadBudgets();
  }


  @override
  Widget build(BuildContext context) {
    final budgetViewModel = Provider.of<BudgetViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Presupuestos', textAlign: TextAlign.center),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/addBudget');
              },
              child: const Icon(
                Icons.add,
                size: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Budgetsvisualizer(
                    totalBudget: 12000,
                    title: "Total Presupuesto",
                  ),

                  Budgetsvisualizer(totalBudget: 8500, title: "Total Gastado"),
                ],
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Presupuestos activos",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 16.0),
              ListDropDownBudgets(),
              const SizedBox(height: 16.0),
              budgetViewModel.budgets.isEmpty
                  ? const Text(
                      "No tienes presupuestos activos",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : const Text(""),
              const SizedBox(height: 16.0),
              //listar presupuestos del viewmodel
              budgetViewModel.isLoading
                  ? const CircularProgressIndicator()
                  : budgetViewModel.error != null
                      ? Text('Error: ${budgetViewModel.error}')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: budgetViewModel.budgets.length,
                          itemBuilder: (context, index) {
                            final budget = budgetViewModel.budgets[index];
                            return Budgetitemtolistbudgetdarshboard(
                              title: budget.name ?? "",
                              budget: budget.amount.toString(),
                              spent: "0",
                            );
                          },
                        ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
