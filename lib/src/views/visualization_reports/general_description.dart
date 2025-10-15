import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Descripción General',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SF Pro Display',
      ),
      home: const GeneralDescriptionScreen(),
    );
  }
}

class GeneralDescriptionScreen extends StatelessWidget {
  const GeneralDescriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Descripción general',
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
            // Título del periodo
            const Text(
              'Este mes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),

            // Total gastado
            _buildMetricCard(
              label: 'Total gastado',
              amount: '\$800',
              icon: Icons.arrow_downward,
              iconColor: Colors.red,
              iconBgColor: const Color(0xFFFFEBEE),
            ),
            const SizedBox(height: 20),

            // Ingresos totales
            _buildMetricCard(
              label: 'Ingresos totales',
              amount: '\$2,000',
              icon: Icons.arrow_upward,
              iconColor: Colors.green,
              iconBgColor: const Color(0xFFE8F5E9),
            ),
            const SizedBox(height: 20),

            // Saldo del mes
            _buildMetricCard(
              label: 'Saldo del mes',
              amount: '\$1,200',
              icon: Icons.insert_drive_file_outlined,
              iconColor: Colors.grey,
              iconBgColor: const Color(0xFFF5F5F5),
            ),
            const SizedBox(height: 30),

            // Presupuesto principal
            _buildBudgetSection(),
            const SizedBox(height: 30),

            // Ingresos vs Gastos
            const Text(
              'Ingresos vs. Gastos (Últimos 6 meses)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Gráfica de líneas
            _buildLineChart(),
            const SizedBox(height: 40),

            // Gastos por categoría
            const Text(
              'Gastos por categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Gráfica circular (donut)
            _buildDonutChart(),
            const SizedBox(height: 30),

            // Leyenda de categorías
            _buildCategoryLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    const budget = 2000.0;
    const spent = 1200.0;
    const percentage = (spent / budget) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Presupuesto principal',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              '\$1,200',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'of \$2,000',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Text(
              '${percentage.toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: spent / budget,
            backgroundColor: const Color(0xFFE8D7FF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '70% del presupuesto del mes gastado',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        months[value.toInt()],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 5,
          minY: 0,
          maxY: 5,
          lineBarsData: [
            // Línea de ingresos (verde)
            LineChartBarData(
              spots: const [
                FlSpot(0, 3.5),
                FlSpot(1, 3.2),
                FlSpot(2, 4),
                FlSpot(3, 3.8),
                FlSpot(4, 4.2),
                FlSpot(5, 4.5),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            // Línea de gastos (morado)
            LineChartBarData(
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 2.5),
                FlSpot(2, 2.2),
                FlSpot(3, 3),
                FlSpot(4, 2.8),
                FlSpot(5, 3.5),
              ],
              isCurved: true,
              color: const Color(0xFF7C3AED),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gráfica circular
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 65,
              startDegreeOffset: -90,
              sections: [
                // Alimento - Morado
                PieChartSectionData(
                  color: const Color(0xFF7C3AED),
                  value: 25,
                  title: '',
                  radius: 20,
                ),
                // Utilidades - Amarillo
                PieChartSectionData(
                  color: const Color(0xFFFFC107),
                  value: 20,
                  title: '',
                  radius: 20,
                ),
                // Transporte - Rosa
                PieChartSectionData(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  value: 30,
                  title: '',
                  radius: 20,
                ),
                // Entretenimiento - Gris
                PieChartSectionData(
                  color: const Color(0xFF9E9E9E),
                  value: 25,
                  title: '',
                  radius: 20,
                ),
              ],
            ),
          ),
          // Centro con total
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '\$800',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend() {
    return Column(
      children: [
        Row(
          children: [
            _buildLegendItem('Alimento', const Color(0xFF7C3AED)),
            const SizedBox(width: 40),
            _buildLegendItem('Transporte', const Color(0xFFE91E63)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLegendItem('Utilidades', const Color(0xFFFFC107)),
            const SizedBox(width: 40),
            _buildLegendItem('Entretenimiento', const Color(0xFF9E9E9E)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: const Color.fromARGB(255, 155, 27, 27),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}