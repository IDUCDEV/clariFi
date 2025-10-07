
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/widgets/BudgetItemToListBudgetDarshboard.dart';
import 'package:clarifi_app/src/widgets/budgetsVisualizer.dart';
import 'package:clarifi_app/src/widgets/listDropDownBudgets.dart';
import 'package:flutter/material.dart';

class DashboardBudgets extends StatelessWidget{

  const DashboardBudgets({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Presupuestos', textAlign: TextAlign.center,),
            ElevatedButton(onPressed: (){}, child: const Icon(Icons.add, size: 20, fontWeight: FontWeight.bold,)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Budgetsvisualizer(totalBudget: 12000, title: "Total Presupuesto"),
                  
                  Budgetsvisualizer(totalBudget: 8500, title: "Total Gastado"),
                ],
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Presupuestos activos", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.left,),
              ),
              const SizedBox(height: 16.0),
              ListDropDownBudgets(),
              const SizedBox(height: 16.0),
              Budgetitemtolistbudgetdarshboard(
                title: "Comestibles",
                budget: "1000",
                spent: "500",
              ),
          ],
        )),
      ),
    );
  }
}