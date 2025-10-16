import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  final VoidCallback onExport;
  const ExportButton({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onExport,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: const [
          Icon(Icons.download, size: 18, color: Colors.deepPurple),
          SizedBox(width: 6),
          Text('Exportar', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}
