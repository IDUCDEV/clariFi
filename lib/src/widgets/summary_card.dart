import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int averageCompliance;
  const SummaryCard({super.key, required this.averageCompliance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEAF4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen', style: TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Cumplimiento promedio', style: TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$averageCompliance%',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: averageCompliance / 100,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEEEAF8),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
