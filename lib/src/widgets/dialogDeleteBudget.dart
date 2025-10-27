import 'package:flutter/material.dart';
import 'package:clarifi_app/src/models/budget.dart';
import 'package:clarifi_app/src/services/currency_conversion_service.dart';

/// Diálogo para eliminar presupuesto con opción de devolver monto a la cuenta
class DeleteBudgetDialog extends StatefulWidget {
  final String budgetName;
  final double budgetAmount;
  final String accountCurrency;
  final List<BudgetModel> otherBudgets;

  const DeleteBudgetDialog({
    super.key,
    required this.budgetName,
    required this.budgetAmount,
    required this.accountCurrency,
    required this.otherBudgets,
  });

  @override
  State<DeleteBudgetDialog> createState() => _DeleteBudgetDialogState();
}

class _DeleteBudgetDialogState extends State<DeleteBudgetDialog> {
  bool _transferEnabled = false;
  String? _selectedBudgetId;

  @override
  void initState() {
    super.initState();
    // Si hay otros presupuestos, habilitar la opción de transferir
    if (widget.otherBudgets.isNotEmpty) {
      _transferEnabled = false; // Por defecto deshabilitado
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = CurrencyConversionService();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Eliminar presupuesto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje de advertencia
                  Text(
                    'Al eliminar este presupuesto, se eliminarán permanentemente todas las transacciones y datos asociados. Esta acción no se puede deshacer.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Alerta de monto si tiene presupuesto asignado
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este presupuesto tiene un monto de ${currencyService.formatAmount(amount: widget.budgetAmount, currency: widget.accountCurrency)}. El monto será devuelto a la cuenta.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),

            const Divider(height: 1),

            // Botón eliminar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validar que si está habilitada la transferencia, se haya seleccionado un presupuesto
                    if (_transferEnabled && _selectedBudgetId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona un presupuesto para transferir'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context, {
                      'confirmed': true,
                      'transferEnabled': _transferEnabled,
                      'targetBudgetId': _selectedBudgetId,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Eliminar presupuesto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}