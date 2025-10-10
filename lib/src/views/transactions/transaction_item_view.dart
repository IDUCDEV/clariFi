import 'package:flutter/material.dart';
import 'package:clarifi_app/src/colors/colors.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String account;
  final String time;
  final double amount;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.title,
    required this.account,
    required this.time,
    required this.amount,
    this.onTap,
  });

   @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🧾 Info izquierda
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                Text(account,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),

            // 💵 Monto derecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (isNegative ? '-' : '+') + '\$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isNegative ? Colors.red : Colors.green,
                  ),
                ),
                Text(time,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}