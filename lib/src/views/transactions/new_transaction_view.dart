// import 'package:clarifi_app/src/colors/colors.dart';
// import 'package:clarifi_app/src/models/transaction.dart';
// import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
// import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// /// Si tienes un BudgetViewModel, este import se puede activar:
// /// import 'package:clarifi_app/src/viewmodels/budget_viewmodel.dart';

// class NewTransactionView extends StatefulWidget {
//   final String type; // 'expense' o 'income'

//   const NewTransactionView({super.key, required this.type});

//   @override
//   State<NewTransactionView> createState() => _NewTransactionScreenState();
// }

// class _NewTransactionScreenState extends State<NewTransactionView> {
//   String? selectedCategoryId;
//   String? selectedAccountId;
//   String? selectedBudgetId;
//   DateTime? selectedDate = DateTime.now();
//   final TextEditingController noteController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();

//   static const int maxNoteLength = 20;

//   // Fallback (si no tienes BudgetViewModel aún)
//   final List<Map<String, String>> fakeBudgets = [
//     {'id': '1', 'name': 'Hogar'},
//     {'id': '2', 'name': 'Transporte'},
//     {'id': '3', 'name': 'Alimentación'},
//     {'id': '4', 'name': 'Entretenimiento'},
//   ];

//   // Controla si asociar a presupuesto o no
//   bool linkToBudget = false;

//   // Lista de presupuestos cargada (viene de BudgetViewModel si existe)
//   List<Map<String, String>> budgets = [];

//   // Indica si la carga de presupuestos está en progreso
//   bool budgetsLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Cargar categorías y cuentas (como antes)
//       context.read<TransactionViewModel>().loadCategories(widget.type);
//       context.read<AccountViewModel>().loadAccounts();

//       // Intentar cargar presupuestos si existe BudgetViewModel
//       _tryLoadBudgets();
//     });

//     noteController.addListener(() {
//       if (noteController.text.length > maxNoteLength) {
//         noteController.text =
//             noteController.text.substring(0, maxNoteLength);
//         noteController.selection = TextSelection.fromPosition(
//           TextPosition(offset: noteController.text.length),
//         );
//       }
//       setState(() {});
//     });
//   }

//   Future<void> _tryLoadBudgets() async {
//     setState(() => budgetsLoading = true);

//     try {
//       // Intentamos usar un BudgetViewModel si existe en el árbol de providers.
//       // Si no existe, usamos fakeBudgets.
//       final budgetVm = Provider.of<dynamic>(context, listen: false);
//       // El intento anterior puede lanzar si no existe; por eso lo envolvemos en try/catch.
//       // Si tienes un BudgetViewModel con método loadBudgets(), reemplaza la lógica abajo.
//       // Para mayor compatibilidad, comprobamos si el provider tiene el método `getAvailableBudgets`.
//       if (budgetVm != null &&
//           budgetVm is dynamic &&
//           (budgetVm is Object &&
//               (budgetVm).runtimeType.toString().toLowerCase().contains('budget'))) {
//         // Si tienes un BudgetViewModel con `loadBudgets()` y `budgets` expuesto:
//         try {
//           // Llamada genérica (si existe)
//           //await budgetVm.loadBudgets();
//           //final loaded = budgetVm.budgets as List<dynamic>?;

//           // if (loaded != null) {
//           //   budgets = loaded
//           //       .map((b) => {
//           //             'id': b.id?.toString() ?? '',
//           //             'name': b.name?.toString() ?? '',
//           //           })
//           //       .toList()
//           //       .cast<Map<String, String>>();
//           // } else {
//           //   budgets = fakeBudgets;
//           // }
//         } catch (_) {
//           budgets = fakeBudgets;
//         }
//       } else {
//         budgets = fakeBudgets;
//       }
//     } catch (_) {
//       budgets = fakeBudgets;
//     } finally {
//       if (mounted) setState(() => budgetsLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     noteController.dispose();
//     amountController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<TransactionViewModel>();
//     final vmAccounts = context.watch<AccountViewModel>();
//     final isExpense = widget.type == 'expense';
//     final title = isExpense ? 'Nuevo Gasto' : 'Nuevo Ingreso';

//     final formattedDate = selectedDate != null
//         ? DateFormat('dd/MM/yyyy').format(selectedDate!)
//         : 'Seleccionar fecha';

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: AppColors.onSecondary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: AppColors.onSecondary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 8),

//             // 💰 Monto
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   '\$',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.onSecondary,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 SizedBox(
//                   width: 160,
//                   child: TextField(
//                     controller: amountController,
//                     keyboardType:
//                         const TextInputType.numberWithOptions(decimal: true),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.onSecondary,
//                     ),
//                     decoration: const InputDecoration(
//                       hintText: "0.00",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // SWITCH: asociar con presupuesto
//             SwitchListTile(
//               title: const Text("Asociar con presupuesto"),
//               value: linkToBudget,
//               onChanged: (val) {
//                 setState(() {
//                   linkToBudget = val;
//                   // Limpiar selecciones al cambiar modo
//                   if (linkToBudget) {
//                     selectedAccountId = null;
//                     selectedCategoryId = null;
//                     // recargar budgets si fuera necesario
//                     _tryLoadBudgets();
//                   } else {
//                     selectedBudgetId = null;
//                   }
//                 });
//               },
//               activeColor: AppColors.primary,
//             ),

//             const SizedBox(height: 12),

//             // Si está linkToBudget -> mostrar dropdown presupuestos (y solo monto/fecha/nota)
//             if (linkToBudget) ...[
//               if (budgetsLoading)
//                 const Center(child: CircularProgressIndicator())
//               else if (budgets.isEmpty)
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: const Text(
//                         'No hay presupuestos disponibles.',
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () {
//                           // Navegar a crear presupuesto - reemplaza por tu vista real
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const CreateBudgetPlaceholder()),
//                           );
//                         },
//                         child: const Text('Crear presupuesto'),
//                       ),
//                     ),
//                   ],
//                 )
//               else
//                 _buildDropdown(
//                   'Seleccionar presupuesto',
//                   selectedBudgetId,
//                   budgets,
//                   (value) => setState(() => selectedBudgetId = value),
//                 ),

//               const SizedBox(height: 12),
//             ] else ...[
//               // Si NO está linkToBudget -> mostrar Categoría y Cuenta (como antes)
//               if (vm.isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else
//                 _buildDropdown(
//                   'Categoría',
//                   selectedCategoryId,
//                   vm.categories
//                       .map((c) => {'id': c.id, 'name': c.name})
//                       .toList(),
//                   (value) => setState(() => selectedCategoryId = value),
//                 ),

//               const SizedBox(height: 12),

//               if (vmAccounts.isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else
//                 _buildDropdown(
//                   'Cuenta',
//                   selectedAccountId,
//                   vmAccounts.accounts
//                       .map((a) => {'id': a.id, 'name': a.name})
//                       .toList(),
//                   (value) => setState(() => selectedAccountId = value),
//                 ),

//               const SizedBox(height: 12),
//             ],

//             // 📅 Fecha
//             GestureDetector(
//               onTap: _pickDate,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightPurple,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(formattedDate,
//                         style: const TextStyle(color: AppColors.onSecondary)),
//                     const Icon(Icons.calendar_today_outlined,
//                         color: AppColors.primary),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // 📝 Nota
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 TextField(
//                   controller: noteController,
//                   maxLength: maxNoteLength,
//                   decoration: InputDecoration(
//                     hintText: 'Añadir una nota (opcional)',
//                     counterText: '',
//                     filled: true,
//                     fillColor: AppColors.lightPurple,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: 12,
//                   bottom: 8,
//                   child: Text(
//                     '${noteController.text.length}/$maxNoteLength',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: noteController.text.length >= maxNoteLength
//                           ? Colors.red
//                           : Colors.grey,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // 💾 Guardar
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: AppColors.background,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 onPressed: () async => await _saveTransaction(context),
//                 child: const Text(
//                   'Guardar',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   // COMPONENTE DROPDOWN
//   Widget _buildDropdown(
//     String hint,
//     String? selectedId,
//     List<Map<String, String>> items,
//     ValueChanged<String?>? onChanged,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppColors.lightPurple,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: selectedId,
//           hint: Text(hint),
//           items: items
//               .map((item) => DropdownMenuItem(
//                     value: item['id'],
//                     child: Text(item['name'] ?? ''),
//                   ))
//               .toList(),
//           onChanged: onChanged,
//           isExpanded: true,
//         ),
//       ),
//     );
//   }

//   Future<void> _pickDate() async {
//     final today = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? today,
//       firstDate: DateTime(2000),
//       lastDate: today,
//       helpText: 'Seleccionar fecha de la transacción',
//       cancelText: 'Cancelar',
//       confirmText: 'Aceptar',
//     );

//     if (picked != null) {
//       setState(() => selectedDate = picked);
//     }
//   }

//   Future<void> _saveTransaction(BuildContext context) async {
//   final vm = context.read<TransactionViewModel>();
//   final user = Supabase.instance.client.auth.currentUser;

//   if (user == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error: Usuario no autenticado')),
//     );
//     return;
//   }

//   final amount = double.tryParse(amountController.text) ?? 0;
//   if (amount <= 0) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Ingrese un monto válido')),
//     );
//     return;
//   }

//   // Validaciones condicionales
//   if (linkToBudget) {
//     if (selectedBudgetId == null || selectedBudgetId!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Seleccione un presupuesto')),
//       );
//       return;
//     }
//   } else {
//     if (selectedAccountId == null || selectedCategoryId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Seleccione cuenta y categoría')),
//       );
//       return;
//     }
//   }

//   final tx = TransactionModel(
//     id: const Uuid().v4(),
//     accountId: linkToBudget ? null : selectedAccountId,
//     categoryId: linkToBudget ? null : selectedCategoryId,
//     budgetId: linkToBudget ? selectedBudgetId : null,
//     type: widget.type,
//     amount: amount,
//     date: selectedDate ?? DateTime.now(),
//     note: noteController.text,
//     currency: "PEN",
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//   );

//   try {
//     await vm.addTransaction(tx);

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('✅ Transacción guardada correctamente')),
//     );

//     Navigator.pop(context);
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al guardar: $e')),
//       );
//     }
//   }
// }
// }

// /// Placeholder para crear presupuesto si no tienes aún la pantalla.
// /// Reemplaza con tu vista real de crear presupuesto.
// class CreateBudgetPlaceholder extends StatelessWidget {
//   const CreateBudgetPlaceholder({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Crear presupuesto')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Aquí iría la lógica real para crear presupuesto
//             Navigator.pop(context);
//           },
//           child: const Text('Simular creación de presupuesto'),
//         ),
//       ),
//     );
//   }
// }
// 📌 new_transaction_view.dart

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

  bool linkToBudget = false;

  /// Fake budgets (hasta que tu compañero conecte servicio real)
  final List<Map<String, String>> fakeBudgets = [
    {'id': 'djhhdgy12', 'name': 'Comidas'},
    {'id': '2', 'name': 'Transporte'},
    {'id': '3', 'name': 'Casa'},
  ];

  List<Map<String, String>> budgets = [];
  bool budgetsLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadCategories(widget.type);
      context.read<AccountViewModel>().loadAccounts();
      _loadBudgetsFake();
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

  Future<void> _loadBudgetsFake() async {
    budgets = fakeBudgets;
    if (mounted) setState(() {});
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
              if (budgets.isEmpty)
                Column(
                  children: [
                    const Text("No hay presupuestos. Crea uno."),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Crear presupuesto"),
                    )
                  ],
                )
              else
                _buildDropdown(
                  "Seleccionar presupuesto",
                  selectedBudgetId,
                  budgets,
                  (v) => setState(() => selectedBudgetId = v),
                ),

              const SizedBox(height: 12),
            ] else ...[
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
  accountId: linkToBudget ? null : selectedAccountId,
  categoryId: linkToBudget ? null : selectedCategoryId,
  budgetId: linkToBudget ? selectedBudgetId : null,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
