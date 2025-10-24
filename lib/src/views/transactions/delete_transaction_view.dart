import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:go_router/go_router.dart'; 

class DeleteTransactionView extends StatefulWidget {
  final TransactionModel transaction;

  const DeleteTransactionView({super.key, required this.transaction});

  @override
  State<DeleteTransactionView> createState() => _DeleteTransactionViewState();
}

class _DeleteTransactionViewState extends State<DeleteTransactionView> {
  bool transferBalance = false;
  String? selectedAccount;

  @override
  void initState() {
    super.initState();
    // ✅ Carga las cuentas reales apenas se abre la pantalla
    Future.microtask(() {
      final accountViewModel = context.read<AccountViewModel>();
      accountViewModel.loadAccounts(); // asegúrate de tener este método en tu VM
    });
  }

  void _showMessage(String msg, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  /// ✅ Método que elimina la transacción y redirige al listado
  Future<void> _deleteTransaction() async {
    final viewModel = context.read<TransactionViewModel>();

    try {
      await viewModel.deleteTransaction(widget.transaction.id!);

      _showMessage('🗑️ Transacción eliminada correctamente', color: Colors.red);

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // ✅ Usa GoRouter para volver al listado de transacciones
      context.go('/transactions');
    } catch (e) {
      _showMessage('Error al eliminar la transacción', color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBalance = widget.transaction.amount > 0;
    final accountViewModel = context.watch<AccountViewModel>();
    final accounts = accountViewModel.accounts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Eliminar transacción',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Al eliminar esta transacción, se eliminarán permanentemente todos los datos asociados. '
              'Esta acción no se puede deshacer.',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            if (hasBalance)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta transacción tiene un monto de \$${widget.transaction.amount.toStringAsFixed(2)}. '
                        'Asegúrate de revisarla antes de eliminarla.',
                        style: const TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Transferir saldo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Checkbox(
                  value: transferBalance,
                  onChanged: (v) =>
                      setState(() => transferBalance = v ?? false),
                  activeColor: AppColors.primary,
                ),
              ],
            ),

            if (transferBalance)
              DropdownButtonFormField<String>(
                value: selectedAccount,
                decoration: InputDecoration(
                  labelText: 'Transferir a',
                  filled: true,
                  fillColor: AppColors.lightPurple.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: accounts.isNotEmpty
                    ? accounts
                        .map(
                          (acc) => DropdownMenuItem<String>(
                            value: acc.id,
                            child: Text(acc.name),
                          ),
                        )
                        .toList()
                    : const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('No hay cuentas disponibles'),
                        ),
                      ],
                onChanged: (value) => setState(() => selectedAccount = value),
              ),

            const Spacer(),

            // ✅ BOTÓN ELIMINAR FUNCIONAL
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _deleteTransaction, // 🔥 ahora elimina y redirige
                child: const Text(
                  'Eliminar transacción',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
