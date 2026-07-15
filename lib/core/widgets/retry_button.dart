import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final bool isLoading;

  const RetryButton({
    super.key,
    required this.onPressed,
    this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: Text(label ?? 'Retry'),
    );
  }
}
