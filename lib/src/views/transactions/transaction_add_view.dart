import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';


class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  bool isRecurring = false;
  String frequency = "Diario";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nuevo Gasto/Ingreso', style: TextStyle(color: AppColors.onSecondary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "\$0.00",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.onSecondary),
            ),
            const SizedBox(height: 16),

            _buildDropdown('Categoría'),
            const SizedBox(height: 12),
            _buildDropdown('Cuenta'),
            const SizedBox(height: 12),
            _buildDropdown('Fecha'),
            const SizedBox(height: 12),

            TextField(
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

            // 📸 Recibo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 40),
                  const SizedBox(height: 8),
                  const Text("Agregar un recibo", style: TextStyle(color: AppColors.onSecondary)),
                  const Text("Tome una foto de su recibo", style: TextStyle(color: AppColors.gray, fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("Tomar Foto"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔁 Transacción recurrente
            SwitchListTile(
              title: const Text("Transacción recurrente"),
              value: isRecurring,
              onChanged: (val) => setState(() => isRecurring = val),
              activeColor: AppColors.primary,
            ),
            if (isRecurring)
              Column(
                children: [
                  Wrap(
                    spacing: 8,
                    children: ["Diario", "Semanalmente", "Mensual", "Anualmente"].map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: frequency == option,
                        onSelected: (_) => setState(() => frequency = option),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: frequency == option ? Colors.white : AppColors.onSecondary),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/aaaa',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      filled: true,
                      fillColor: AppColors.lightPurple,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // 💾 Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {},
                child: const Text('Guardar', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: null,
          hint: Text(text),
          items: const [],
          onChanged: (_) {},
          isExpanded: true,
        ),
      ),
    );
  }
}
