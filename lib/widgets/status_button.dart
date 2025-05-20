import 'package:flutter/material.dart';

class StatusButton extends StatelessWidget {
  final String text;
  final int count;
  final VoidCallback onPressed;

  const StatusButton({
    super.key,
    required this.text,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}