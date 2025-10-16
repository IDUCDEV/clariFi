import 'package:flutter/material.dart';

enum BudgetStatus { good, over, neutral }

class Budget {
  final String month;
  final String year;
  final String title;
  final double compliancePercent; // 0..100
  final double budget;
  final double spent;
  final BudgetStatus status;

  Budget({
    required this.month,
    required this.year,
    required this.title,
    required this.compliancePercent,
    required this.budget,
    required this.spent,
    required this.status,
  });
}


class BudgetItemCard extends StatelessWidget {
  final Budget budget;
  const BudgetItemCard({super.key, required this.budget});

  Color _backgroundForStatus(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.good:
        return const Color(0xFFE6FBF0);
      case BudgetStatus.over:
        return const Color(0xFFFFECEC);
      case BudgetStatus.neutral:
      default:
        return const Color(0xFFF6F7FB);
    }
  }

  IconData _iconForStatus(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.good:
        return Icons.check;
      case BudgetStatus.over:
        return Icons.close;
      case BudgetStatus.neutral:
      default:
        return Icons.info_outline;
    }
  }

  Color _iconColorForStatus(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.good:
        return Colors.green;
      case BudgetStatus.over:
        return Colors.red;
      case BudgetStatus.neutral:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEAF6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Left column: title + values
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(budget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Cumplimiento: ', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    Text('${budget.compliancePercent.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Presupuesto: \$${budget.budget.toStringAsFixed(0)}  •  Gasto: \$${budget.spent.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.black45, fontSize: 13)),
              ],
            ),
          ),
          // Right: status badge
          Container(
            decoration: BoxDecoration(
              color: _backgroundForStatus(budget.status),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              _iconForStatus(budget.status),
              color: _iconColorForStatus(budget.status),
            ),
          ),
        ],
      ),
    );
  }
}
