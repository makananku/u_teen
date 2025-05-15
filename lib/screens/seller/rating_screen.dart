import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/ratings_provider.dart';
import '../../models/order_model.dart'; // Make sure this path matches where your Order class is defined
import '../../auth/auth_provider.dart'; // Import AuthProvider

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchantEmail = Provider.of<AuthProvider>(context).sellerEmail ?? '';
    final ratingsProvider = Provider.of<RatingsProvider>(context);
    final ratedOrders = ratingsProvider.getRatedOrders(merchantEmail);
    final averageRating = ratingsProvider.getAverageFoodRating(merchantEmail);
    final foodNotes = ratingsProvider.getFoodNotes(merchantEmail);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Ratings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                    _buildRatingStars(averageRating, 24),
                    const SizedBox(height: 16),
                    Text(
                      'Based on ${ratedOrders.length} ${ratedOrders.length == 1 ? 'rating' : 'ratings'}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rating Distribution
            const Text(
              'Rating Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildRatingDistribution(ratedOrders),
            const SizedBox(height: 24),

            // Customer Feedback
            if (foodNotes.isNotEmpty) ...[
              const Text(
                'Customer Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...foodNotes.map((note) => _buildFeedbackCard(note)).toList(),
            ],

            // Rating History
            const SizedBox(height: 24),
            const Text(
              'Rating History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (ratedOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No ratings yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ...ratedOrders.map((order) => _buildRatingCard(order)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating, double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  Widget _buildRatingDistribution(List<Order> ratedOrders) {
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

  Widget _buildFeedbackCard(String feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.format_quote, color: Colors.grey, size: 24),
                SizedBox(width: 8),
                Text(
                  'Customer Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              feedback,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(Order order) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
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
              _buildRatingStars(order.foodRating?.toDouble() ?? 0, 20),
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