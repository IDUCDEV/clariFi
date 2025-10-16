
import 'package:clarifi_app/src/widgets/templateBudgetCard.dart';
import 'package:flutter/material.dart';

class TemplateModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final bool recommended;

  TemplateModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.recommended = false,
  });
}


// ---------------------------
// File: lib/widgets/recommended_badge.dart
// ---------------------------


class RecommendedBadge extends StatelessWidget {
  final bool visible;
  const RecommendedBadge({super.key, this.visible = false});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'RECOMENDADO',
        style: TextStyle(
          color: Colors.purple.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}



class BudgetTemplateScreen extends StatelessWidget {
  const BudgetTemplateScreen({super.key});

  List<TemplateModel> _mockTemplates() {
    return [
      TemplateModel(
        id: 'familia',
        title: 'Familia',
        subtitle: 'Ideal para hogares con gastos compartidos y múltiples fuentes de ingresos.',
        description:
            'Ideal para hogares con gastos compartidos y múltiples fuentes de ingresos. Gestiona presupuestos familiares, asigna categorías y controla gastos recurrentes.',
        recommended: true,
      ),
      TemplateModel(
        id: 'soltero',
        title: 'Soltero',
        subtitle: 'Diseñado para personas que gestionan sus finanzas de forma independiente.',
        description:
            'Diseñado para personas que gestionan sus finanzas de forma independiente. Ideal si llevas tus cuentas personales y ahorros por separado.',
      ),
      TemplateModel(
        id: 'alumno',
        title: 'Alumno',
        subtitle: 'Diseñado para estudiantes con ingresos limitados y gastos específicos.',
        description:
            'Diseñado para estudiantes con ingresos limitados y gastos específicos. Permite priorizar pagos y controlar gastos por categoría.',
      ),
      TemplateModel(
        id: 'jubilado',
        title: 'Jubilado',
        subtitle: 'Adecuado para jubilados que se centran en ingresos fijos y costos de atención médica.',
        description:
            'Adecuado para jubilados que se centran en ingresos fijos y costos de atención médica. Ayuda a planificar gastos mensuales y actividades de ahorro.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final templates = _mockTemplates();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.3,
        title: const Text('Plantillas de presupuesto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 18, bottom: 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Elige una plantilla',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ...templates.map((t) => TemplateCard(
                  template: t,
                  onApply: () {
                    // Acción al aplicar: puedes reemplazar por navegación o lógica de estado
                    final snackBar = SnackBar(content: Text('Aplicada: \${t.title}'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                )),
          ],
        ),
      ),
    );
  }
}


// ---------------------------
// Notes:
// 1) Coloca cada section en su archivo correspondiente dentro de lib/ (ej: lib/screens/templates_screen.dart)
// 2) Reemplaza los placeholders de ilustración por imágenes reales usando Image.asset o Image.network.
// 3) Si quieres que las tarjetas se vean exactamente como la maqueta (sombra suave, bordes y colores específicos), puedo ajustar estilos y tamaños.
// 4) ¿Quieres que las tarjetas sean separadas por componentes con tests y providers (Riverpod/Provider)? Puedo extenderlo.
