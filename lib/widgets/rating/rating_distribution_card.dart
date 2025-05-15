import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class RatingDistributionCard extends StatelessWidget {
  final List<Order> ratedOrders;

  const RatingDistributionCard({
    super.key,
    required this.ratedOrders,
  });

  @override
  Widget build(BuildContext context) {
    final ratingCounts = [0, 0, 0, 0, 0];
    for (var order in ratedOrders) {
      if (order.foodRating != null && order.foodRating! > 0) {
        ratingCounts[order.foodRating! - 1]++;
      }
    }

    final maxCount = ratingCounts.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: maxCount == 0 ? 0 : count / maxCount,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.amber.withOpacity(0.6),
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
                      style: const TextStyle(fontSize: 12),
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