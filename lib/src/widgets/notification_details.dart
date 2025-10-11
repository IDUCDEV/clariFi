// widgets/notification_details.dart
import 'package:flutter/material.dart';

class NotificationDetails extends StatelessWidget {
  const NotificationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de notificación',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            _DetailItem(text: '• Categoría'),
            _DetailItem(text: '• Cantidad gastada'),
            _DetailItem(text: '• Cantidad restante'),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String text;

  const _DetailItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}