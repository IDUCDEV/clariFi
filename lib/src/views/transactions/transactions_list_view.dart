// import 'package:clarifi_app/src/colors/colors.dart';
// import 'package:provider/provider.dart';
// import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
// import 'package:flutter/material.dart';
// import 'transaction_item_view.dart';
// import 'new_transaction_view.dart';
// import 'transfer_view.dart';
// import 'edit_transaction_view.dart';

// class TransactionsListView extends StatelessWidget {
//   const TransactionsListView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<TransactionViewModel>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Transacciones',
//           style: TextStyle(color: AppColors.onSecondary),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: viewModel.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : viewModel.errorMessage != null
//           ? Center(child: Text(viewModel.errorMessage!))
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: viewModel.transactions.length,
//               itemBuilder: (context, index) {
//                 final item = viewModel.transactions[index];
//                 return TransactionItem(
//                   title: item.note ?? 'Sin descripción',
//                   account: item.accountId,
//                   time: '${item.date.hour}:${item.date.minute}',
//                   amount: item.amount,
//                   onTap: () {
//                     // Navegar a editar
//                   },
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//       backgroundColor: AppColors.primary,
//       onPressed: () => _showAddOptions(context), // 👈 Llama al modal
//       child: const Icon(Icons.add, color: Colors.white),
// ),
//     );
//   }
// void _showAddOptions(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Center(
//               child: SizedBox(
//                 width: 40,
//                 child: Divider(thickness: 4, color: Colors.black12),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Agregar nuevo',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildOption(context, Icons.arrow_downward, 'Agregar nuevo gasto', 'expense'),
//             _buildOption(context, Icons.arrow_upward, 'Agregar nuevo ingreso', 'income'),
//             _buildOption(context, Icons.swap_horiz, 'Transferencia entre mis cuentas', 'transfer'),
//           ],
//         ),
//       );
//     },
//   );
// }


//   // 🎨 Widget para cada opción del modal
//   Widget _buildOption(BuildContext context, IconData icon, String text, String type) {
//   return InkWell(
//     onTap: () {
//       Navigator.pop(context); // Cierra el modal

//       if (type == 'transfer') {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const TransferScreen()),
//         );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => NewTransactionView(type: type),
//           ),
//         );
//       }
//     },
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey.shade50,
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: AppColors.lightPurple,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: AppColors.primary),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             text,
//             style: const TextStyle(fontSize: 16, color: Colors.black87),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// }
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'transaction_item_view.dart';
import 'new_transaction_view.dart';
import 'transfer_view.dart';

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key});

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  @override
  void initState() {
    super.initState();
    // ✅ Cargar transacciones al abrir la vista
    Future.microtask(() {
      final vm = context.read<TransactionViewModel>();
      vm.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transacciones',
          style: TextStyle(color: AppColors.onSecondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!))
              : viewModel.transactions.isEmpty
                  ? const Center(child: Text('No hay transacciones aún'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.transactions.length,
                      itemBuilder: (context, index) {
                        final item = viewModel.transactions[index];
                        return TransactionItem(
                          title: item.note ?? 'Sin descripción',
                          account: item.accountId,
                          time:
                              '${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}',
                          amount: item.amount,
                          onTap: () {
                            // Aquí podrías navegar a editar
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(thickness: 4, color: Colors.black12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agregar nuevo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(context, Icons.arrow_downward, 'Agregar nuevo gasto', 'expense'),
              _buildOption(context, Icons.arrow_upward, 'Agregar nuevo ingreso', 'income'),
              _buildOption(context, Icons.swap_horiz, 'Transferencia entre mis cuentas', 'transfer'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String text, String type) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Cierra el modal

        if (type == 'transfer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewTransactionView(type: type),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
