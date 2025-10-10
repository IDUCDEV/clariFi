import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';
import 'transaction_item_view.dart';
import 'transaction_add_view.dart';
import 'transfer_view.dart';
import 'edit_transaction_view.dart';

class TransactionsListView extends StatelessWidget {
  const TransactionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'title': 'Comestibles', 'account': 'Comprobando', 'time': '10:30 AM', 'amount': -52.75},
      {'title': 'Salario', 'account': 'Ahorros', 'time': '11:45 AM', 'amount': 2500.00},
      {'title': 'Compras en línea', 'account': 'Tarjeta de crédito', 'time': '14:15', 'amount': -120.50},
      {'title': 'Utilidades', 'account': 'Comprobando', 'time': '4:30 PM', 'amount': -85.20},
      {'title': 'Interés', 'account': 'Ahorros', 'time': '9:00 AM', 'amount': 15.50},
      {'title': 'Salir a cenar', 'account': 'Tarjeta de crédito', 'time': '13:00', 'amount': -45.80},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transacciones',
          style: TextStyle(color: AppColors.onSecondary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Buscador
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar transacciones',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.lightPurple,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🏷️ Filtros
            Wrap(
              spacing: 8,
              children: const [
                FilterChip(label: Text('Fecha'), selected: false, onSelected: null),
                FilterChip(label: Text('Categoría'), selected: false, onSelected: null),
                FilterChip(label: Text('Cuenta'), selected: false, onSelected: null),
                FilterChip(label: Text('Tipo'), selected: false, onSelected: null),
              ],
            ),
            const SizedBox(height: 16),

            // 💳 Lista de transacciones
            Expanded(
  child: ListView.builder(
    itemCount: transactions.length,
    itemBuilder: (context, index) {
      final item = transactions[index];
      return TransactionItem(
        title: item['title'] as String,
        account: item['account'] as String,
        time: item['time'] as String,
        amount: item['amount'] as double,
        onTap: () async {
          // Abrir pantalla de edición
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditTransactionView()),
          );

          // Mostrar alerta si se editaron los datos
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Transacción actualizada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    },
  ),
),
          ],
        ),
      ),

      // ➕ Botón flotante
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 🧭 Modal con opciones
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildOption(context, Icons.add, 'Agregar nuevo gasto'),
              _buildOption(context, Icons.add, 'Agregar nuevo ingreso'),
              _buildOption(context, Icons.swap_horiz, 'Transferencia entre mis cuentas'),
            ],
          ),
        );
      },
    );
  }

  // 🎨 Widget para cada opción del modal
  Widget _buildOption(BuildContext context, IconData icon, String text) {
    return InkWell(
      onTap: () {
        if (text == 'Transferencia entre mis cuentas') {
          // Lógica para transferencias
          Navigator.pop(context); // Cierra el modal
          Navigator.push( // Envio al Transferencia de Pantalla
          context,
          MaterialPageRoute(builder: (_) => const TransferScreen()),
        );
          return;
        }else {
          // Lógica para agregar gasto o ingreso
          Navigator.pop(context); // Cierra el modal
          Navigator.push( // Envio a Transaccion Ingreso o Egreso
          context,
          MaterialPageRoute(builder: (_) => const NewTransactionScreen()),
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
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
