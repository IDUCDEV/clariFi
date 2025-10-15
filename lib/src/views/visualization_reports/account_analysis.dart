import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class AccountAnalysisScreen extends StatelessWidget {
  const AccountAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/reports');
          },
        ),
        title: const Text(
          'Análisis de cuenta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal
            const Text(
              'Distribución por cuenta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Header con total y periodo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastos Totales',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '\$12,500',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Este mes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Gráfica de barras vertical
            _buildVerticalBarChart(),
            const SizedBox(height: 50),

            // Título de comparación
            const Text(
              'Comparación de cuentas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),

            // Barras horizontales de comparación
            _buildHorizontalBar('Corriente', 0.85, const Color(0xFF7C3AED)),
            const SizedBox(height: 20),
            _buildHorizontalBar('Ahorros', 0.45, const Color(0xFF9D6FFF)),
            const SizedBox(height: 20),
            _buildHorizontalBar('Tarjeta de crédito', 0.65, const Color(0xFFB89FFF)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildVerticalBar('Corriente', 1.0, 200),
        _buildVerticalBar('Ahorros', 0.6, 120),
        _buildVerticalBar('Tarjeta de crédito', 0.45, 90),
      ],
    );
  }

  Widget _buildVerticalBar(String label, double heightFactor, double maxHeight) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra
          Container(
            height: maxHeight * heightFactor,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8D7FF),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // Etiqueta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        // Barra de progreso
        Stack(
          children: [
            // Fondo
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // Progreso
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}