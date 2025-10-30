import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';

class TransferScreen extends StatefulWidget {
  final String? transferId;
  const TransferScreen({super.key, this.transferId});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? fromAccountId;
  String? toAccountId;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountViewModel>().loadAccounts();
    if (widget.transferId != null) {
      _loadTransfer(widget.transferId!);
    }
  }

  Future<void> _loadTransfer(String transferId) async {
    final vm = context.read<TransactionViewModel>();
    final pair = await vm.getTransferPairById(transferId);

    setState(() {
      fromAccountId = pair['out'].accountId;
      toAccountId = pair['in'].accountId;
      amountController.text = pair['out'].amount.toString();
      noteController.text = pair['out'].note ?? "";
      selectedDate = pair['out'].date;
    });
  }

  Future<void> _confirmTransfer(BuildContext context) async {
    final vmAccounts = context.read<AccountViewModel>();
    final vmTransactions = context.read<TransactionViewModel>();

    final accounts = vmAccounts.accounts;
    final amount = double.tryParse(amountController.text) ?? 0;

    if (accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Necesitas al menos dos cuentas')),
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
    const SnackBar(content: Text('❌ No puedes transferir a la misma cuenta')),
  );
  return;
}

if (amount <= 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('❌ Monto inválido')),
  );
  return;
}

// ✅ VALIDACIÓN DE SALDO
final fromAccount = accounts.firstWhere((acc) => acc.id == fromAccountId);

if (fromAccount.balance < amount) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('❌ Saldo insuficiente en la cuenta origen')),
  );
  return;
}


    setState(() => loading = true);

    try {
      if (widget.transferId == null) {
        await vmTransactions.transferBetweenAccountsVm(
          fromAccountId!,
          toAccountId!,
          amount,
          noteController.text.isEmpty ? null : noteController.text,
        );
      } else {
        await vmTransactions.updateTransferPairVm(
          widget.transferId!,
          amount,
          noteController.text.isEmpty ? null : noteController.text,
          selectedDate,
        );
      }

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
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.transferId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transferencia'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed == true) {
      final vm = context.read<TransactionViewModel>();
      setState(() => loading = true);
      await vm.deleteTransferPairVm(widget.transferId!);
      setState(() => loading = false);
      Navigator.pop(context);
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
        title: Text(
          widget.transferId == null ? 'Transferir' : 'Editar transferencia',
          style: const TextStyle(color: AppColors.onSecondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.transferId != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
            )
        ],
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
                      _buildAccountDropdown(accounts, fromAccountId, (v) => setState(() => fromAccountId = v)),
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
                      _buildAccountDropdown(accounts, toAccountId, (v) => setState(() => toAccountId = v)),

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
                          onPressed: loading ? null : () => _confirmTransfer(context),
                          child: Text(loading ? "Procesando..." : "Confirmar transferencia"),
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
                    child: Text('${a.name} - ${a.balance.toStringAsFixed(2)} PEN'),
                  ))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }
}
