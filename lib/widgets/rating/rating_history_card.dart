import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import 'rating_stars.dart';

class RatingHistoryCard extends StatelessWidget {
  final Order order;

  const RatingHistoryCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 6)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  order.completedAt != null
                      ? DateFormat('dd MMM yyyy').format(order.completedAt!)
                      : 'Unknown date',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                RatingStars(
                  rating: order.foodRating?.toDouble() ?? 0,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.foodRating ?? 0}/5',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (order.foodNotes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                order.foodNotes!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}