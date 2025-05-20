import 'package:flutter/material.dart';

class QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickAmountButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}