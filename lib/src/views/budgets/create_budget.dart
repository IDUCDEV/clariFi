import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _nameBudgetController.dispose();
    _categoryBudgetController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                        border: Border.all(color: Colors.black12, width: 1.0),
                        
                      ),
                      child: DropdownButton<String>(
                        value: _categoryBudgetController.text.isEmpty ? null : _categoryBudgetController.text,
                        hint: const Text('Categoría'),
                        isExpanded: true,
                        dropdownColor: AppColors.blush,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoryBudgetController.text = newValue!;
                          });
                        },
                        items: <String>['Opción 1', 'Opción 2', 'Opción 3'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Lógica para guardar el presupuesto
                          // Por ejemplo: guardar en base de datos o viewmodel
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Presupuesto guardado')),
                          );
                        }
                      },
                      child: const Text('Guardar Presupuesto'),
                    ),
                  ],
                ),
              ),
              
          ],
        )),
      ),
    );
  }
}