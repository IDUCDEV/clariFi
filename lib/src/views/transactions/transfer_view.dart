import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import '../../models/account.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  AccountModel? fromAccount;
  AccountModel? toAccount;

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.primary : Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmTransfer(AccountViewModel viewModel) async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      _showMessage('Por favor ingresa un monto.');
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showMessage('Monto inválido.');
      return;
    }

    if (fromAccount == null || toAccount == null) {
      _showMessage('Debes seleccionar las cuentas de origen y destino.');
      return;
    }

    if (fromAccount!.id == toAccount!.id) {
      _showMessage('No puedes transferir a la misma cuenta.');
      return;
    }

    if (amount > fromAccount!.balance) {
      _showMessage('Fondos insuficientes en la cuenta origen.');
      return;
    }

    try {
      await viewModel.transferAmount(
        fromAccountId: fromAccount!.id,
        toAccountId: toAccount!.id,
        amount: amount,
      );
      _showMessage('✅ Transferencia realizada con éxito.', success: true);
      Navigator.pop(context);
    } catch (e) {
      _showMessage('❌ Error al realizar la transferencia: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountViewModel>(context, listen: false).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountViewModel>(context);
    final accounts = viewModel.accounts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transferir',
          style: TextStyle(color: AppColors.onSecondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : accounts.length < 2
          ? const Center(
              child: Text(
                '⚠️ Necesitas al menos dos cuentas para realizar una transferencia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('De', style: TextStyle(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  _accountDropdown(
                    accounts,
                    fromAccount,
                    (value) => setState(() => fromAccount = value),
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
                  _accountDropdown(
                    accounts,
                    toAccount,
                    (value) => setState(() => toAccount = value),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Cantidad',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ingresa el monto a transferir',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: AppColors.lightPurple,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nota',
                    style: TextStyle(color: AppColors.primary),
                  ),
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
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _confirmTransfer(viewModel),
                      child: const Text('Confirmar transferencia'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _accountDropdown(
    List<AccountModel> accounts,
    AccountModel? selected,
    Function(AccountModel?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selected?.id, // ✅ usamos el id como valor
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Selecciona una cuenta'),
        icon: const Icon(Icons.arrow_drop_down),
        items: accounts.map((account) {
          return DropdownMenuItem<String>(
            value: account.id, // ✅ clave única
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${account.name} (${account.type})',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '\$${account.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          final selectedAccount = accounts.firstWhere(
            (account) => account.id == value,
            orElse: () => accounts.first,
          );
          onChanged(selectedAccount);
        },
      ),
    );
  }
}
