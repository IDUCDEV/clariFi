import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:clarifi_app/src/models/budget.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/viewmodels/budget_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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

  bool linkToBudget = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadCategories(widget.type);
      context.read<AccountViewModel>().loadAccounts();
      context.read<BudgetViewModel>().loadBudgets();
    });

    noteController.addListener(() {
      if (noteController.text.length > maxNoteLength) {
        noteController.text =
            noteController.text.substring(0, maxNoteLength);
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
    final vmBudgets = context.watch<BudgetViewModel>();
    final isExpense = widget.type == 'expense';
    final title = isExpense ? 'Nuevo Gasto' : 'Nuevo Ingreso';
    final budgets = vmBudgets.budgets;
    final budgetsLoading = vmBudgets.isLoading;

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
          title,
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

            // 💰 Monto
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
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
    ],
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
),   ],
            ),

            const SizedBox(height: 20),

            // SWITCH Presupuesto
            SwitchListTile(
              title: const Text("Asociar con presupuesto"),
              value: linkToBudget,
              onChanged: (val) {
                setState(() {
                  linkToBudget = val;
                  selectedBudgetId = null;
                  selectedAccountId = null;
                  selectedCategoryId = null;
                });
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 12),

         if (linkToBudget) ...[
  if (budgetsLoading)
    const CircularProgressIndicator()
  else if (budgets.isEmpty)
    Column(
      children: [
        const Text("No hay presupuestos. Crea uno."),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: () {
            // TODO: Navegar a creación de presupuesto
          },
          child: const Text("Crear presupuesto"),
        ),
      ],
    )
  else
    _buildBudgetDropdown(
      "Seleccionar presupuesto",
      selectedBudgetId,
      budgets,
      (v) => setState(() => selectedBudgetId = v),
    ),

  const SizedBox(height: 12),
]else ...[
              // Categoría
              if (vm.isLoading)
                const CircularProgressIndicator()
              else
                _buildDropdown(
                  "Categoría",
                  selectedCategoryId,
                  vm.categories
                      .map((c) => {'id': c.id, 'name': c.name})
                      .toList(),
                  (v) => setState(() => selectedCategoryId = v),
                ),

              const SizedBox(height: 12),

              // Cuenta
              if (vmAccounts.isLoading)
                const CircularProgressIndicator()
              else
                _buildDropdown(
                  "Cuenta",
                  selectedAccountId,
                  vmAccounts.accounts
                      .map((a) => {'id': a.id, 'name': a.name})
                      .toList(),
                  (v) => setState(() => selectedAccountId = v),
                ),

              const SizedBox(height: 12),
            ],

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

            // 📝 Nota
            TextField(
              controller: noteController,
              maxLength: maxNoteLength,
              decoration: InputDecoration(
                hintText: 'Añadir nota (opcional)',
                counterText: '',
                filled: true,
                fillColor: AppColors.lightPurple,
                //borderRadius: BorderRadius.circular(12),
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 20),

            // 💾 Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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

            const SizedBox(height: 12),
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

  Widget _buildBudgetDropdown(
  String hint,
  String? selectedId,
  List<BudgetModel> budgets,
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
        items: budgets
            .map<DropdownMenuItem<String>>(
              (b) => DropdownMenuItem<String>(
                value: b.id ?? '',
                child: Text(b.name ?? 'Sin nombre'),
              ),
            )
            .toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    ),
  );
}



  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
  String? _cleanId(String? id) =>
    (id == null || id.trim().isEmpty) ? null : id;
  
  Future<void> _saveTransaction(BuildContext context) async {
    final vm = context.read<TransactionViewModel>();
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido')),
      );
      return;
    }

    if (linkToBudget) {
      if (selectedBudgetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione presupuesto')),
        );
        return;
      }
    } else {
      if (selectedAccountId == null || selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione categoría y cuenta')),
        );
        return;
      }
    }

    final tx = TransactionModel(
  id: const Uuid().v4(),
  accountId: linkToBudget ? null : _cleanId(selectedAccountId),
categoryId: linkToBudget ? null : _cleanId(selectedCategoryId),
budgetId: linkToBudget ? _cleanId(selectedBudgetId) : null,
  type: widget.type,
  amount: amount,
  date: selectedDate ?? DateTime.now(),
  note: noteController.text,
  currency: "PEN",
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

    try {
      await vm.addTransaction(tx);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✔️ Transacción guardada')),
      );

      Navigator.pop(context);
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
    );
    }
  }
}
