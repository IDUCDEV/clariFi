import "package:flutter/material.dart";

class EditBudget extends StatefulWidget {

    final String? budgetId;
    final String title;
    final double amount;
    final DateTime? startDate;
    final DateTime? endDate;
    final int threshold;
    final String category;

    const EditBudget({
        super.key, 
        required this.budgetId,
        required this.title,
        required this.amount,
        required this.startDate,
        required this.endDate,
        required this.threshold,
        required this.category
    });

    @override
    State<EditBudget> createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}