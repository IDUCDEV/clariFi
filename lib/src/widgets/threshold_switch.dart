// widgets/threshold_switch.dart
import 'package:flutter/material.dart';

class ThresholdSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double threshold;
  final ValueChanged<double> onThresholdChanged;
  final String thresholdSuffix;

  const ThresholdSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.threshold,
    required this.onThresholdChanged,
    this.thresholdSuffix = '% del presupuesto',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (value) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: threshold,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${threshold.round()}$thresholdSuffix',
                    onChanged: onThresholdChanged,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${threshold.round()}$thresholdSuffix',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}