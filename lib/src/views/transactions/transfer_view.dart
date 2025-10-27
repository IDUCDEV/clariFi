// import 'package:flutter/material.dart';
// import 'package:clarifi_app/src/colors/colors.dart';

// class TransferScreen extends StatefulWidget {
//   const TransferScreen({super.key});

//   @override
//   State<TransferScreen> createState() => _TransferScreenState();
// }

// class _TransferScreenState extends State<TransferScreen> {
//   final TextEditingController noteController = TextEditingController();
//   double amount = 150.00;

//   void _showConfirmation() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('✅ Transferencia confirmada exitosamente.'),
//         backgroundColor: AppColors.primary,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: AppColors.onSecondary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Transferir',
//           style: TextStyle(color: AppColors.onSecondary),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('De', style: TextStyle(color: AppColors.primary)),
//             const SizedBox(height: 8),
//             _accountCard('Banco de America', 'Corriente', '\$1,234.56'),
//             const SizedBox(height: 20),
//             const Center(
//               child: CircleAvatar(
//                 backgroundColor: AppColors.primary,
//                 child: Icon(Icons.swap_horiz, color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('A', style: TextStyle(color: AppColors.primary)),
//             const SizedBox(height: 8),
//             _accountCard('Fidelidad', 'Inversión', '\$5,890.12'),
//             const SizedBox(height: 30),
//             const Text('Cantidad', style: TextStyle(color: AppColors.primary)),
//             const SizedBox(height: 8),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 const Text(
//                   '\$',
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   amount.toStringAsFixed(2),
//                   style: const TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.onSecondary,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Text('Nota', style: TextStyle(color: AppColors.primary)),
//             const SizedBox(height: 8),
//             TextField(
//               controller: noteController,
//               decoration: InputDecoration(
//                 hintText: 'Añadir una nota (opcional)',
//                 filled: true,
//                 fillColor: AppColors.lightPurple,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onPressed: _showConfirmation,
//                 child: const Text('Confirmar transferencia'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _accountCard(String name, String type, String balance) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 3,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             backgroundColor: AppColors.lightPurple,
//             child: Icon(Icons.account_balance, color: AppColors.primary),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                 Text(type, style: const TextStyle(color: AppColors.gray)),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(balance,
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//               const Text('Saldo disponible',
//                   style: TextStyle(color: AppColors.gray, fontSize: 12)),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? fromAccountId;
  String? toAccountId;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AccountViewModel>().loadAccounts();
  }

  Future<void> _confirmTransfer(BuildContext context) async {
    final vmAccounts = context.read<AccountViewModel>();
    final vmTransactions = context.read<TransactionViewModel>();

    final accounts = vmAccounts.accounts;
    final amount = double.tryParse(amountController.text) ?? 0;

    // 1️⃣ Validaciones básicas
    if (accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Necesitas al menos dos cuentas para transferir')),
      );
      return;
    }

    if (fromAccountId == null || toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione ambas cuentas')),
      );
      return;
    }

    if (fromAccountId == toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes transferir a la misma cuenta')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }

    final fromAccount = accounts.firstWhere((a) => a.id == fromAccountId);
    if (fromAccount.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💸 Saldo insuficiente')),
      );
      return;
    }

    try {
      await vmTransactions.transferBetweenAccountsVm(
        fromAccountId!,
        toAccountId!,
        amount,
        noteController.text.isEmpty ? null : noteController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Transferencia completada'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmAccounts = context.watch<AccountViewModel>();
    final accounts = vmAccounts.accounts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transferir', style: TextStyle(color: AppColors.onSecondary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: vmAccounts.isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? const Center(child: Text("No tienes cuentas registradas"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('De', style: TextStyle(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      _buildAccountDropdown(
                        accounts,
                        fromAccountId,
                        (v) => setState(() => fromAccountId = v),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.swap_horiz, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('A', style: TextStyle(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      _buildAccountDropdown(
                        accounts,
                        toAccountId,
                        (v) => setState(() => toAccountId = v),
                      ),
                      const SizedBox(height: 30),
                      const Text('Cantidad', style: TextStyle(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                        ],
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Nota', style: TextStyle(color: AppColors.primary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        decoration: InputDecoration(
                          hintText: 'Añadir una nota (opcional)',
                          filled: true,
                          fillColor: AppColors.lightPurple,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => _confirmTransfer(context),
                          child: const Text('Confirmar transferencia'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAccountDropdown(
      List<dynamic> accounts, String? selectedId, ValueChanged<String?> onChanged) {
   return Container(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(
    color: AppColors.lightPurple,
    borderRadius: BorderRadius.circular(12),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: selectedId,
      hint: const Text('Seleccionar cuenta'),
      items: accounts
          .map((a) => DropdownMenuItem<String>(
                value: a.id ?? '',
                child: Text(
                  '${a.name} - ${a.balance.toStringAsFixed(2)} PEN',
                ),
              ))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    ),
  ),
);
  }
}
