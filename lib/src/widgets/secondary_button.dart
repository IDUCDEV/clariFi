import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  final String text;
  final Future<void> Function()? onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          if (widget.onPressed != null) {
            setState(() => _isLoading = true);
            try {
              await widget.onPressed!();
            } finally {
              
              setState(() => _isLoading = false);
              
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blush,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const Text(
                'Cargando...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}