import 'package:flutter/material.dart';
import 'package:clarifi_app/src/colors/colors.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController noteController = TextEditingController();
  double amount = 150.00;

  void _showConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Transferencia confirmada exitosamente.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('De', style: TextStyle(color: AppColors.primary)),
            const SizedBox(height: 8),
            _accountCard('Banco de America', 'Corriente', '\$1,234.56'),
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
            _accountCard('Fidelidad', 'Inversión', '\$5,890.12'),
            const SizedBox(height: 30),
            const Text('Cantidad', style: TextStyle(color: AppColors.primary)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondary,
                  ),
                ),
              ],
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
                onPressed: _showConfirmation,
                child: const Text('Confirmar transferencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountCard(String name, String type, String balance) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.lightPurple,
            child: Icon(Icons.account_balance, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(type, style: const TextStyle(color: AppColors.gray)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balance,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Saldo disponible',
                  style: TextStyle(color: AppColors.gray, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}
