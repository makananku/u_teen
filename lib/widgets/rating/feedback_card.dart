import 'package:flutter/material.dart';

class FeedbackCard extends StatelessWidget {
  final String feedback;

  const FeedbackCard({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white, // Set background color to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200, // Add subtle border
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.format_quote, 
                  color: Colors.blueGrey, // Slightly darker icon color
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Customer Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey, // Matching text color
                    fontSize: 14, // Slightly smaller font
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4, // Better line spacing
              ),
            ),
          ],
        ),
      ),
    );
  }
}