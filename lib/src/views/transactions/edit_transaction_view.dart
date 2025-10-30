import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/colors/colors.dart';

class EditTransactionView extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionView({super.key, required this.transaction});

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends State<EditTransactionView> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();

  String? selectedAccountId;
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();

    final t = widget.transaction;

    _amountController = TextEditingController(text: t.amount.toString());
    _notesController = TextEditingController(text: t.note ?? '');
    _selectedDate = t.date;

    selectedAccountId = t.accountId;
    selectedCategoryId = t.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadCategories(t.type);
      context.read<AccountViewModel>().loadAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {Color color = AppColors.primary}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _saveChanges() async {
    final vm = context.read<TransactionViewModel>();

    final updatedTransaction = widget.transaction.copyWith(
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: _selectedDate,
      note: _notesController.text,
      accountId: selectedAccountId,
      categoryId: selectedCategoryId,
    );

    await vm.updateTransaction(updatedTransaction);

    _showMessage('💾 Cambios guardados correctamente.');
    Navigator.pop(context);
  }

  void _navigateToDelete() {
    context.push('/transactions/delete/${widget.transaction.id}');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final vmAccounts = context.watch<AccountViewModel>();

    final hasBudget = widget.transaction.budgetId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Transacción', style: TextStyle(color: AppColors.onSecondary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _textField('Cantidad', _amountController, TextInputType.number),

            if (!hasBudget && !vm.isLoading)
              _dropdown(
                'Categoría',
                selectedCategoryId,
                vm.categories.map((c) => {'id': c.id, 'name': c.name}).toList(),
                (val) => setState(() => selectedCategoryId = val),
              ),

            if (!hasBudget && !vmAccounts.isLoading)
              _dropdown(
                'Cuenta',
                selectedAccountId,
                vmAccounts.accounts.map((c) => {'id': c.id, 'name': c.name}).toList(),
                (val) => setState(() => selectedAccountId = val),
              ),

            _dateField(),

            _textField('Notas', _notesController),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _saveChanges,
                child: const Text('Guardar cambios'),
              ),
            ),

            Center(
              child: TextButton(
                onPressed: _navigateToDelete,
                child: const Text('Eliminar transacción', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, [keyboardType = TextInputType.text]) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.lightPurple,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      );

  Widget _dropdown(String label, String? value, List<Map<String, String>> items, ValueChanged<String?> onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.lightPurple,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: items.map((i) => DropdownMenuItem(value: i['id'], child: Text(i['name']!))).toList(),
          onChanged: onChanged,
        ),
      );

  Widget _dateField() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: _pickDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Fecha',
              filled: true,
              fillColor: AppColors.lightPurple,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                const Icon(Icons.calendar_today_outlined),
              ],
            ),
          ),
        ),
      );
}
