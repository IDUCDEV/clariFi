import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/budget_viewmodel.dart';
import 'package:clarifi_app/src/widgets/AlertThresholds.dart';
import 'package:clarifi_app/src/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateBudget extends StatefulWidget {
  const CreateBudget({super.key});

  @override
  State<CreateBudget> createState() => _CreateBudgetState();
}

class _CreateBudgetState extends State<CreateBudget> {
  final _formKey = GlobalKey<FormState>();
  final _nameBudgetController = TextEditingController();
  final _categoryBudgetController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedPeriod = 'monthly';
  DateTime? startDate;
  DateTime? endDate;
  double? _selectedThreshold = 50;

  

    // Formateador rápido
  String formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
        }
      });
    }
  }


  Future<void> _selectEndDate(BuildContext context) async {
    if (startDate == null) return; // No permitir antes de seleccionar inicio

    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate!,
      firstDate: startDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameBudgetController.dispose();
    _categoryBudgetController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    final budgetViewModel = Provider.of<BudgetViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/budgets');
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nuevo Presupuesto', textAlign: TextAlign.center,),
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
                    DropdownButtonFormField<String>(
                      initialValue: _categoryBudgetController.text.isEmpty ? null : _categoryBudgetController.text,
                      hint: const Text('Tipo de Categoría'),
                      isExpanded: true,
                      dropdownColor: AppColors.blush,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        filled: true,
                        fillColor: AppColors.blush,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _categoryBudgetController.text = newValue!;
                        });
                      },
                      items: <String>['Presupuesto global', 'Gasto', 'Ingreso'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona un tipo de categoría';
                        }
                        return null;
                      },
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
                          return 'Ingresa una cantidad válida, y mayor que 0';
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
                    value: 'monthly',
                    label: Text('Mensual'),
                  ),
                  ButtonSegment(
                    value: 'weekly',
                    label: Text('Semanal'),
                  ),
                  ButtonSegment(
                    value: 'yearly',
                    label: Text('Anual'),
                  ),
                ],
                selected: <String>{_selectedPeriod},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
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
                          label: Text("Inicio: ${formatDate(startDate)}"),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Fecha de finalización
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: startDate == null
                              ? null
                              : () => _selectEndDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text("Fin: ${formatDate(endDate)}"),
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
                text: 'Guardar Presupuesto',
                onPressed: () async {
                  if (_formKey.currentState!.validate() && startDate != null && endDate != null) {
                    try {
                      await budgetViewModel.createBudget(
                        name: _nameBudgetController.text,
                        amount: double.parse(_amountController.text),
                        period: _selectedPeriod,
                        categoryId: _categoryBudgetController.text,
                        startDate: startDate!.toUtc(),
                        endDate: endDate!.toUtc(),
                        alertThreshold: _selectedThreshold,
                      );

                      if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text('Presupuesto guardado exitosamente',
                                style: TextStyle(color: Colors.black)),
                          ),
                        );
                        GoRouter.of(context).go('/budgets');
                      }
                    } catch (e) {
                      if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar presupuesto: $e')),
                        );
                      }
                    }
                  } else if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor selecciona las fechas de inicio y fin')),
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