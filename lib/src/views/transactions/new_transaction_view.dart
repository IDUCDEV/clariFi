import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewTransactionView extends StatefulWidget {
  final String type; // 👈 expense | income

  const NewTransactionView({super.key, required this.type});

  @override
  State<NewTransactionView> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionView> {
  bool isRecurring = false;
  String frequency = "Diario";
  String? selectedCategoryId;
  String? selectedAccountId;
  DateTime? selectedDate = DateTime.now();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadCategories(widget.type);
      context.read<AccountViewModel>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final vmAccounts = context.watch<AccountViewModel>();

    final isExpense = widget.type == 'expense';
    final title = isExpense ? 'Nuevo Gasto' : 'Nuevo Ingreso';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.onSecondary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 💰 Monto
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.onSecondary,
              ),
              decoration: const InputDecoration(
                hintText: "\$0.00",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),

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
                (value) {
                  
                  final selected =
                      vm.categories.firstWhere((a) => a.id == value);
                      setState(() => selectedCategoryId = selected.id);
                  print('✅ Cuenta seleccionada: ${selected.name} (${selectedCategoryId})');
                },
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
                (value) {
                  
                  final selected =
                      vmAccounts.accounts.firstWhere((a) => a.id == value);
                      setState(() => selectedAccountId = selected.id);
                  print('✅ Cuenta seleccionada: ${selected.name} (${selectedAccountId})');
                },
              ),

            const SizedBox(height: 12),

            // 📅 Fecha
            GestureDetector(
              onTap: _pickDate,
              child: _buildDropdown(
                'Fecha',
                selectedDate != null
                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                    : 'Seleccionar fecha',
                const [],
                null,
              ),
            ),
            const SizedBox(height: 12),

            // 📝 Nota
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Añadir una nota',
                filled: true,
                fillColor: AppColors.lightPurple,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildReceiptSection(),
            const SizedBox(height: 20),

            // 🔁 Recurrente
            SwitchListTile(
              title: const Text("Transacción recurrente"),
              value: isRecurring,
              onChanged: (val) => setState(() => isRecurring = val),
              activeColor: AppColors.primary,
            ),
            if (isRecurring) _buildFrequencySection(),
            const SizedBox(height: 24),

            // 💾 Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  await _saveTransaction(context);
                },
                child:
                    const Text('Guardar', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔽 Dropdown genérico que usa ID internamente
  Widget _buildDropdown(String hint, String? selectedId,
      List<Map<String, String>> items, ValueChanged<String?>? onChanged) {
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

  Widget _buildReceiptSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined,
              color: AppColors.primary, size: 40),
          const SizedBox(height: 8),
          const Text("Agregar un recibo",
              style: TextStyle(color: AppColors.onSecondary)),
          const Text("Tome una foto de su recibo",
              style: TextStyle(color: AppColors.gray, fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text("Tomar Foto"),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children: ["Diario", "Semanalmente", "Mensual", "Anualmente"]
              .map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: frequency == option,
              onSelected: (_) => setState(() => frequency = option),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: frequency == option
                      ? Colors.white
                      : AppColors.onSecondary),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _saveTransaction(BuildContext context) async {
    final vm = context.read<TransactionViewModel>();
    final vmAccounts = context.read<AccountViewModel>();
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      print('❌ No hay usuario autenticado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    // ✅ Validación de selección
    if (selectedAccountId == null || selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione cuenta y categoría')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      userId: user.id,
      accountId: selectedAccountId as String,
      categoryId: selectedCategoryId as String,
      type: widget.type,
      amount: amount,
      date: selectedDate ?? DateTime.now(),
      note: noteController.text,
      currency: "PEN",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('💾 Insertando en Supabase -> ${transaction.toJson()}');

    try {
      await vm.addTransaction(transaction);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Transacción guardada correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('🔴 Error al guardar transacción: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}
