import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  Widget _buildChip(String text) {
    return Chip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: const Color(0xFFF3E8FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      avatar: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip('Categoría'),
        const SizedBox(width: 8),
        _buildChip('Período'),
        const SizedBox(width: 8),
        _buildChip('Año'),
      ],
    );
  }
}
