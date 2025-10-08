import "package:clarifi_app/src/colors/colors.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class Budgetitemtolistbudgetdarshboard extends StatelessWidget {
  final String title;
  final String budget;
  final String spent;
  const Budgetitemtolistbudgetdarshboard({super.key, required this.title, required this.budget, required this.spent});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.blush,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add your widgets here, for example:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4.0),
                  Text('Presupuesto: \$$budget', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4.0),
                  Text('Gastado: \$$spent', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${(spent != "0" && budget != "0") ? ((double.parse(spent) / double.parse(budget)) * 100).toStringAsFixed(1) : "0"}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    // Handle edit action
                    GoRouter.of(context).go('/editBudget');
                  },
                ),
              ],
            ),
              ],
            ),
            
            const SizedBox(height: 8.0),
            // Add more widgets as needed
            LinearProgressIndicator(
              value: spent != "0" && budget != "0" ? double.parse(spent) / double.parse(budget) : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(8.0),
            ),
            const SizedBox(height: 8.0),
            Text("Dentro del presupuesto", style: const TextStyle(fontSize: 14, color: Colors.green),),
          ],
        ),
      ),
    );
  }
}

