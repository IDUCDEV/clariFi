import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NewTransactionView extends StatefulWidget {
  final String type; // 'expense' o 'income'

  const NewTransactionView({super.key, required this.type});

  @override
  State<NewTransactionView> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionView> {
  String? selectedCategoryId;
  String? selectedAccountId;
  String? selectedBudgetId;
  DateTime? selectedDate = DateTime.now();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  static const int maxNoteLength = 20;

  final List<Map<String, String>> fakeBudgets = [
    {'id': '1', 'name': 'Hogar'},
    {'id': '2', 'name': 'Transporte'},
    {'id': '3', 'name': 'Alimentación'},
    {'id': '4', 'name': 'Entretenimiento'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadCategories(widget.type);
      context.read<AccountViewModel>().loadAccounts();
    });
    noteController.addListener(() {
      if (noteController.text.length > maxNoteLength) {
        noteController.text = noteController.text.substring(0, maxNoteLength);
        noteController.selection = TextSelection.fromPosition(
          TextPosition(offset: noteController.text.length),
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final vmAccounts = context.watch<AccountViewModel>();
    final isExpense = widget.type == 'expense';
    final title = isExpense ? 'Nuevo Gasto' : 'Nuevo Ingreso';

    final formattedDate = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Seleccionar fecha';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$title',
          style: const TextStyle(
            color: AppColors.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // 💰 Monto centrado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondary,
                    ),
                    decoration: const InputDecoration(
                      hintText: "0.00",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🏷️ Categoría
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildDropdown(
                'Categoría',
                selectedCategoryId,
                vm.categories
                    .map((c) => {'id': c.id, 'name': c.name})
                    .toList(),
                (value) => setState(() => selectedCategoryId = value),
              ),

            const SizedBox(height: 12),

            // 🏦 Cuenta
            if (vmAccounts.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildDropdown(
                'Cuenta',
                selectedAccountId,
                vmAccounts.accounts
                    .map((a) => {'id': a.id, 'name': a.name})
                    .toList(),
                (value) => setState(() => selectedAccountId = value),
              ),

            const SizedBox(height: 12),

            // 📅 Fecha
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate,
                        style: const TextStyle(color: AppColors.onSecondary)),
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📊 Asociar presupuesto
            _buildDropdown(
              'Asociar a un presupuesto',
              selectedBudgetId,
              fakeBudgets,
              (value) => setState(() => selectedBudgetId = value),
            ),

            const SizedBox(height: 12),

            // 📝 Nota
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  controller: noteController,
                  maxLength: maxNoteLength,
                  decoration: InputDecoration(
                    hintText: 'Añadir una nota (opcional)',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.lightPurple,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 8,
                  child: Text(
                    '${noteController.text.length}/$maxNoteLength',
                    style: TextStyle(
                      fontSize: 12,
                      color: noteController.text.length >= maxNoteLength
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔁 Transacción recurrente (comentado)
            /*
            SwitchListTile(
              title: const Text("Transacción recurrente"),
              value: false,
              onChanged: (val) {},
              activeColor: AppColors.primary,
            ),
            */

            const SizedBox(height: 20),

            // 💾 Botón Guardar
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
                onPressed: () async => await _saveTransaction(context),
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? selectedId,
    List<Map<String, String>> items,
    ValueChanged<String?>? onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          hint: Text(hint),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item['id'],
                    child: Text(item['name'] ?? ''),
                  ))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: 'Seleccionar fecha de la transacción',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _saveTransaction(BuildContext context) async {
    final vm = context.read<TransactionViewModel>();
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    if (selectedAccountId == null || selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione cuenta y categoría')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un monto válido')),
      );
      return;
    }

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      userId: user.id,
      accountId: selectedAccountId!,
      categoryId: selectedCategoryId!,
      type: widget.type,
      amount: amount,
      date: selectedDate ?? DateTime.now(),
      note: noteController.text,
      currency: "PEN",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await vm.addTransaction(transaction);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Transacción guardada correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}
