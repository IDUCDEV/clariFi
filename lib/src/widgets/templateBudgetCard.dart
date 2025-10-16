

// ---------------------------
// File: lib/widgets/template_card.dart
// ---------------------------
import 'package:clarifi_app/src/views/budgets/budget_template_screen.dart';
import 'package:flutter/material.dart';


class TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback? onApply;

  const TemplateCard({super.key, required this.template, this.onApply});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Left column: title + description + button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RecommendedBadge(visible: template.recommended),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          template.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    template.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: onApply ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        elevation: 0,
                      ),
                      child: const Text('Aplicar'),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right column: illustration placeholder
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 44,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
