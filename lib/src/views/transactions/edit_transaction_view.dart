import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/colors/colors.dart';

class EditTransactionView extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionView({super.key, required this.transaction});

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends State<EditTransactionView> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  bool isRecurring = false;

  @override
  void initState() {
    super.initState();

    final t = widget.transaction;
    _descriptionController = TextEditingController(text: t.note ?? '');
    _amountController = TextEditingController(text: t.amount.toString());
    _notesController = TextEditingController(text: t.note ?? '');
    _selectedDate = t.date;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
    final viewModel = context.read<TransactionViewModel>();

    final updatedTransaction = widget.transaction.copyWith(
      note: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: _selectedDate,
    );

    await viewModel.updateTransaction(updatedTransaction);
    _showMessage('💾 Cambios guardados correctamente.');
    Navigator.pop(context);
  }

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar transacción?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final viewModel = context.read<TransactionViewModel>();
      await viewModel.deleteTransaction(widget.transaction.id!);
      _showMessage('🗑️ Transacción eliminada', color: Colors.red);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Transacción',
          style: TextStyle(color: AppColors.onSecondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField('Descripción', _descriptionController),
            _textField('Cantidad', _amountController, keyboardType: TextInputType.number),
            _dropdownField('Cuenta', widget.transaction.accountName ?? 'Seleccionar cuenta'),
            _dropdownField('Categoría', widget.transaction.categoryName ?? 'Seleccionar categoría'),
            _dateField('Fecha', _selectedDate),
            const SizedBox(height: 24),
            _recurringSection(),
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
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _deleteTransaction,
                child: const Text(
                  'Eliminar transacción',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.lightPurple,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.lightPurple,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _pickDate,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.lightPurple,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${date.day}/${date.month}/${date.year}'),
              const Icon(Icons.calendar_today_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recurringSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transacción recurrente', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Esta es una transacción recurrente.'),
            value: isRecurring,
            onChanged: (value) => setState(() => isRecurring = value),
            activeColor: AppColors.primary,
          ),
          if (isRecurring)
            Column(
              children: [
                RadioListTile(
                  title: const Text('Aplicar cambios sólo a esta transacción'),
                  value: false,
                  groupValue: true,
                  onChanged: (_) {},
                ),
                RadioListTile(
                  title: const Text(
                      'Aplicar cambios a esta y a todas las transacciones futuras'),
                  value: true,
                  groupValue: true,
                  onChanged: (_) {},
                  activeColor: AppColors.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
