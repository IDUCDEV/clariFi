import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';

class ListDropDownBudgets extends StatefulWidget {
  const ListDropDownBudgets({super.key});

  @override
  State<ListDropDownBudgets> createState() => _ListDropDownBudgetsState();
}

class _ListDropDownBudgetsState extends State<ListDropDownBudgets> {
  String? selectedPeriod = "Mes";
  String? selectedType = "Gastos";
  String? selectedCategory = "Todos";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 180,
            height: 60,
            child: DropdownButtonFormField<String>(
              isDense: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.blush,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              initialValue: selectedPeriod,
              items: const [
                DropdownMenuItem(value: "Mes", child: Text("Este mes")),
                DropdownMenuItem(value: "Semana", child: Text("Esta semana")),
                DropdownMenuItem(value: "Año", child: Text("Este año")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione una categoría' : null,
            ),
          ),
          const SizedBox(width: 16.0),
          SizedBox(
            width: 180,
            height: 60,
            child: DropdownButtonFormField<String>(
              isDense: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.blush,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              initialValue: selectedType,
              items: const [
                DropdownMenuItem(value: "Gastos", child: Text("Gastos")),
                DropdownMenuItem(value: "Ingresos", child: Text("Ingresos")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione una categoría' : null,
            ),
          ),
          const SizedBox(width: 16.0),
          SizedBox(
            width: 180,
            height: 60,
            child: DropdownButtonFormField<String>(
              isDense: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.blush,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              initialValue: selectedCategory,
              items: const [
                DropdownMenuItem(value: "Todos", child: Text("Todos")),
                DropdownMenuItem(value: "Comida", child: Text("Comida")),
                DropdownMenuItem(value: "Transporte", child: Text("Transporte")),
                DropdownMenuItem(value: "Entretenimiento", child: Text("Entretenimiento")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione una categoría' : null,
            ),
          )
        ],
      ),
    );
  }
}