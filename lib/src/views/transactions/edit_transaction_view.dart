import 'package:flutter/material.dart';
import 'package:clarifi_app/src/colors/colors.dart';

class EditTransactionView extends StatefulWidget {
  const EditTransactionView({super.key});

  @override
  State<EditTransactionView> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionView> {
  bool isRecurring = true;

  void _showSavedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Cambios guardados correctamente.'),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Transacción',
            style: TextStyle(color: AppColors.onSecondary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField('Descripción', 'Suscripción Spotify'),
            _textField('Cantidad', '\$ 10.99'),
            _dropdownField('Cuenta', 'Cuenta bancaria principal'),
            _dropdownField('Categoría', 'Entretenimiento'),
            _dateField('Fecha', '07/28/2024'),
            _textField('Notas (opcional)', 'Suscripción mensual de música'),
            const SizedBox(height: 24),
            _recurringSection(),
            const SizedBox(height: 24),
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
                onPressed: _showSavedMessage,
                child: const Text('Guardar cambios'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ Transacción eliminada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
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

  Widget _textField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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

  Widget _dropdownField(String label, String hint) {
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
            Text(hint),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, String date) {
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
            Text(date),
            const Icon(Icons.calendar_today_outlined),
          ],
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
          const Text('Transacción recurrente',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
