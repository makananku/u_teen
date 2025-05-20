import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_notifier.dart';
import 'rating_stars.dart';

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
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Card(
      elevation: isDarkMode ? 0 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your Overall Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.amber[300] : Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/5',
                  style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingStars(rating: averageRating, size: 24),
            const SizedBox(height: 16),
            Text(
              'Based on $totalRatings ${totalRatings == 1 ? 'rating' : 'ratings'}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}