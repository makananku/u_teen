import 'package:flutter/material.dart';
import './rating_stars.dart';

class RatingSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalRatings;

  const RatingSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Your Overall Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '/5',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingStars(rating: averageRating, size: 24),
            const SizedBox(height: 16),
            Text(
              'Based on $totalRatings ${totalRatings == 1 ? 'rating' : 'ratings'}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}