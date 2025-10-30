// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class TransactionItem extends StatelessWidget {
//   final String title;
//   final String account;
//   final DateTime date;
//   final double amount;
//   final String type; // 'income' o 'expense'
//   final VoidCallback? onTap;

//   const TransactionItem({
//     super.key,
//     required this.title,
//     required this.account,
//     required this.date,
//     required this.amount,
//     required this.type,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isExpense = type == 'expense';
//     final color = isExpense ? Colors.red : Colors.green;
//     final icon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;
//     final sign = isExpense ? '-' : '+';
//     final formattedDate = DateFormat('d MMM').format(date);

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             )
//           ],
//         ),
//         child: Row(
//           children: [
//             // Icono
//             Container(
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(8),
//               child: Icon(icon, color: color, size: 20),
//             ),
//             const SizedBox(width: 12),

//             // Info principal
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     account,
//                     style: const TextStyle(color: Colors.grey, fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),

//             // Monto y fecha
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '$sign\$${amount.abs().toStringAsFixed(2)}',
//                   style: TextStyle(fontWeight: FontWeight.bold, color: color),
//                 ),
//                 Text(
//                   formattedDate,
//                   style: const TextStyle(color: Colors.grey, fontSize: 13),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String account;
  final DateTime date;
  final double amount;
  final String type; // 'income', 'expense', 'transfer_in', 'transfer_out'
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.title,
    required this.account,
    required this.date,
    required this.amount,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ---- NUEVA LÓGICA ----
    Color color;
    IconData icon;
    Color iconBackground;

    if (type == 'expense') {
      // GASTO
      color = Colors.red;
      icon = Icons.arrow_downward;
      iconBackground = color.withOpacity(0.1);

    } else if (type == 'income') {
      // INGRESO
      color = Colors.green;
      icon = Icons.arrow_upward;
      iconBackground = color.withOpacity(0.1);

    } else if (type == 'transfer_out') {
      // TRANSFERENCIA SALIDA
      color = Colors.red;
      icon = Icons.arrow_back; // izquierda
      iconBackground = Colors.blue.withOpacity(0.15); // logo azul

    } else if (type == 'transfer_in') {
      // TRANSFERENCIA ENTRADA
      color = Colors.green;
      icon = Icons.arrow_forward; // derecha
      iconBackground = Colors.blue.withOpacity(0.15); // logo azul

    } else {
      // fallback
      color = Colors.blue;
      icon = Icons.swap_horiz;
      iconBackground = Colors.blue.withOpacity(0.15);
    }

    final sign = amount.isNegative ? '-' : '+';
    final formattedDate = DateFormat('d MMM').format(date);

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
          children: [
            // Icono
            Container(
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: Colors.blue, size: 20),
            ),

            const SizedBox(width: 12),

            // Info principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? '(sin nota)' : title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Monto y fecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign\$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
