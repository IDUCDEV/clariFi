import "package:clarifi_app/src/colors/colors.dart";
import "package:clarifi_app/src/widgets/AlertThresholds.dart";
import "package:clarifi_app/src/widgets/primary_button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class EditBudget extends StatefulWidget {

    final String? budgetId;
    final String nameBudget;
    final double amount;
    final DateTime? startDate;
    final DateTime? endDate;
    final String threshold;
    final String category;
    final String periodo;

    const EditBudget({
        super.key, 
        required this.budgetId,
        required this.nameBudget,
        required this.amount,
        required this.startDate,
        required this.endDate,
        required this.threshold,
        required this.category,
        required this.periodo,
    });

    @override
    State<EditBudget> createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameBudgetController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _categoryBudgetController = TextEditingController();
  int? _selectedThreshold;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriodo = '';

  String formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }


  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) return; // No permitir antes de seleccionar inicio

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  

  @override
  void initState() {
    super.initState();
    _nameBudgetController.text = widget.nameBudget;
    _amountController.text = widget.amount.toString();
    _thresholdController.text = widget.threshold.toString();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _categoryBudgetController.text = widget.category;
    _selectedPeriodo = widget.periodo;
    _selectedThreshold = widget.threshold.isNotEmpty ? int.tryParse(widget.threshold) : null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            GoRouter.of(context).go('/budgets');
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Editar Presupuesto', textAlign: TextAlign.center,),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child:
                  Column(
                  children: [
                    TextFormField(
                      controller: _nameBudgetController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Presupuesto',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        filled: true,
                        fillColor: AppColors.blush,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el nombre del presupuesto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Card(
                      color: AppColors.blush,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.category, color: Colors.purple,),
                            const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Text(
                                      widget.category,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        filled: true,
                        fillColor: AppColors.blush,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la cantidad';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Ingresa una cantidad válida';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerLeft,
                child:const Text('Periodo', textAlign: TextAlign.left,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment(
                    value: 'Mensual',
                    label: Text('Mensual'),
                  ),
                  ButtonSegment(
                    value: 'Semanal',
                    label: Text('Semanal'),
                  ),
                  ButtonSegment(
                    value: 'Anual',
                    label: Text('Anual'),
                  ),
                ],
                selected: <String>{_selectedPeriodo},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPeriodo = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.purple
                        : Colors.grey.shade200,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Fecha de inicio
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectStartDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text("Inicio: ${formatDate(_startDate)}"),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Fecha de finalización
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _startDate == null
                              ? null
                              : () => _selectEndDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text("Fin: ${formatDate(_endDate)}"),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                alignment: Alignment.centerLeft,
                child:const Text('Alerta de Umbrales', textAlign: TextAlign.left,style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
              ),
              const SizedBox(height: 16.0),
              //aqui va el widget
              AlertThresholds(
                selectedThreshold: _selectedThreshold,
                onThresholdChanged: (value) {
                  setState(() {
                    _selectedThreshold = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              PrimaryButton(
                text: 'Guardar cambios',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Lógica para guardar el presupuesto
                    // Simular delay
                    await Future.delayed(const Duration(seconds: 2));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Presupuesto guardado')),
                    );
                  }
                },
              ),
          ],
        )),
      ),
    );
  }
}