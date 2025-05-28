import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/theme_notifier.dart';
import 'rating_stars.dart';

class RatingHistoryCard extends StatelessWidget {
  final Order order;

  const RatingHistoryCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  order.completedAt != null
                      ? DateFormat('dd MMM yyyy').format(order.completedAt!)
                      : 'Unknown date',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            if (order.foodNotes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                order.foodNotes!,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}