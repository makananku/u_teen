import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/theme_notifier.dart';

class RatingDistributionCard extends StatelessWidget {
  final List<Order> ratedOrders;

  const RatingDistributionCard({
    super.key,
    required this.ratedOrders,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final ratingCounts = [0, 0, 0, 0, 0];
    for (var order in ratedOrders) {
      if (order.foodRating != null && order.foodRating! > 0) {
        ratingCounts[order.foodRating! - 1]++;
      }
    }

    final maxCount = ratingCounts.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(5, (index) {
            final count = ratingCounts[4 - index];
            final percentage = ratedOrders.isEmpty
                ? 0.0
                : (count / ratedOrders.length) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '${5 - index}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star,
                    color: isDarkMode ? Colors.amber[300] : Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: maxCount == 0 ? 0 : count / maxCount,
                      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.amber[300]!.withOpacity(0.6) : Colors.amber.withOpacity(0.6),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}