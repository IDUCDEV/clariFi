import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resumen Financiero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'SF Pro Display',
      ),
      home: const FinancialSummaryScreen(),
    );
  }
}

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  int _selectedTab = 0;
  int _selectedBottomNav = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen financiero',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  // Tabs
                  Row(
                    children: [
                      _buildTab('Mes', 0),
                      const SizedBox(width: 12),
                      _buildTab('Cuarto', 1),
                      const SizedBox(width: 12),
                      _buildTab('Año', 2),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly expenses card
                    _buildMonthlyExpensesCard(),
                    const SizedBox(height: 20),

                    // Expense breakdown
                    _buildExpenseBreakdown(),
                    const SizedBox(height: 20),

                    // Trends card
                    _buildTrendsCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8D7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? const Color(0xFF7C3AED) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyExpensesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gastos mensuales por categoría',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\$1,250.00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Este mes +12%',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Bar chart scrollable
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 600, // Ajusta el ancho según la cantidad de barras/meses
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: 100,

                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback:
                          (FlTouchEvent event, BarTouchResponse? response) {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.spot == null) {
                              return;
                            }
                            final index = response.spot!.touchedBarGroupIndex;
                            _onBarTapped(context, index);
                          },

                    ),

                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = [
                              'Ene',
                              'Feb',
                              'Mar',
                              'Abr',
                              'May',
                              'Jun',
                              'Jul',
                              'Agost',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dic',
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < months.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  months[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _buildBarGroup(0, 30, const Color(0xFFE8D7FF)),
                      _buildBarGroup(1, 50, const Color(0xFFE8D7FF)),
                      _buildBarGroup(2, 70, const Color(0xFF7C3AED)),
                      _buildBarGroup(3, 40, const Color(0xFFE8D7FF)),
                      _buildBarGroup(
                        4,
                        55,
                        const Color.fromARGB(255, 151, 113, 201),
                      ),
                      _buildBarGroup(5, 35, const Color(0xFFE8D7FF)),
                      _buildBarGroup(6, 40, const Color(0xFFE8D7FF)),
                      _buildBarGroup(
                        7,
                        55,
                        const Color.fromARGB(255, 151, 113, 201),
                      ),
                      _buildBarGroup(8, 35, const Color(0xFFE8D7FF)),
                      _buildBarGroup(9, 60, const Color(0xFFE8D7FF)),
                      _buildBarGroup(10, 45, const Color(0xFF7C3AED)),
                      _buildBarGroup(11, 50, const Color(0xFFE8D7FF)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Metodo para navegar a  detalles de gastos  del mes 
  void _onBarTapped(BuildContext context, int index) {

    context.go('/month_detail/$index');

}


  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdown() {
    return GestureDetector(
     onTap: () {
      context.go('/accountAnalysisView');
},

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desglose de gastos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _buildExpenseItem('Alimento', '\$300', 'Transporte', '\$200'),
            const SizedBox(height: 16),
            _buildExpenseItem('Entretenimiento', '\$150', 'Utilidades', '\$250'),
            const SizedBox(height: 16),
            _buildExpenseItem('Alquiler', '\$200', 'Otro', '\$150'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(
    String label1,
    String amount1,
    String label2,
    String amount2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label1,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                amount1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label2,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                amount2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tendencias de gastos',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\$7,500.00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Últimos 6 meses +16%',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Line chart
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Ene',
                          'Feb',
                          'Mar',
                          'Abr',
                          'May',
                          'Jun',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 30),
                      const FlSpot(1, 60),
                      const FlSpot(2, 40),
                      const FlSpot(3, 80),
                      const FlSpot(4, 50),
                      const FlSpot(5, 90),
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
          ),
        ],
      ),
    );
  }
}
