import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';

class Budgetsvisualizer extends StatelessWidget {
  final num totalBudget;
  final String title;
  const Budgetsvisualizer({
    super.key,
    required this.totalBudget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        color: AppColors.blush,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 4.0),
              Text(
                '\$ $totalBudget',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
