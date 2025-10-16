import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';

class AlertThresholds extends StatefulWidget {
  final double? selectedThreshold;
  final ValueChanged<double?>? onThresholdChanged;
  final bool disabled;
  final double spacing;
  final TextStyle? textStyle;
  final Color? selectedColor;
  final Color? normalColor;

  const AlertThresholds({
    super.key,
    this.selectedThreshold,
    this.onThresholdChanged,
    this.disabled = false,
    this.spacing = 12.0,
    this.textStyle,
    this.selectedColor,
    this.normalColor,
  });

  @override
  State<AlertThresholds> createState() => _AlertThresholdsState();
}

class _AlertThresholdsState extends State<AlertThresholds> {
  final List<Map<String, dynamic>> _thresholds = [
    {'value': 50.0, 'text': 'Avisame al 50%'},
    {'value': 80.0, 'text': 'Avisame al 80%'},
    {'value': 90.0, 'text': 'Avisme al 90%'},
    {'value': 100.0, 'text': 'Avisame al 100%'},
  ];

  void _handleSelection(double value) {
    if (widget.disabled) return;
    widget.onThresholdChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        ..._thresholds.map((threshold) {
          final bool isSelected = widget.selectedThreshold == threshold['value'];
          
          return Padding(
            padding: EdgeInsets.only(bottom: widget.spacing),
            child: _ThresholdItem(
              text: threshold['text'] as String,
              isSelected: isSelected,
              disabled: widget.disabled,
              onTap: () => _handleSelection(threshold['value'] as double),
              textStyle: widget.textStyle,
              selectedColor: widget.selectedColor,
              normalColor: widget.normalColor,
            ),
          );
        }),
      ],
    );
  }
}

class _ThresholdItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool disabled;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final Color? selectedColor;
  final Color? normalColor;

  const _ThresholdItem({
    required this.text,
    required this.isSelected,
    required this.disabled,
    required this.onTap,
    this.textStyle,
    this.selectedColor,
    this.normalColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color finalColor = isSelected
        ? (selectedColor ?? theme.colorScheme.primary)
        : (normalColor ?? theme.colorScheme.onSurface.withOpacity(0.7));

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.blush, // gris claro similar al diseño
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: finalColor,
                  width: 2,
                ),
                color: isSelected ? finalColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                text,
                style: (textStyle ?? TextStyle(
                  fontSize: 16,
                  color: disabled
                      ? theme.colorScheme.onSurface.withOpacity(0.4)
                      : finalColor,
                )).copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}