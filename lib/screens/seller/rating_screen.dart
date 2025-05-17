import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/rating/rating_summary_card.dart';
import '../../widgets/rating/rating_distribution_card.dart';
import '../../widgets/rating/feedback_card.dart';
import '../../widgets/rating/rating_history_card.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchantEmail = Provider.of<AuthProvider>(context).sellerEmail ?? '';
    final ratingsProvider = Provider.of<RatingProvider>(context);
    final ratedOrders = ratingsProvider.getRatedOrders(merchantEmail);
    final averageRating = ratingsProvider.getAverageFoodRating(merchantEmail);
    final foodNotes = ratingsProvider.getFoodNotes(merchantEmail);

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text(
          'Customer Ratings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          color: Colors.white, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingSummaryCard(
                averageRating: averageRating,
                totalRatings: ratedOrders.length,
              ),
              const SizedBox(height: 24),

              const Text(
                'Rating Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RatingDistributionCard(ratedOrders: ratedOrders),
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
                
                ...foodNotes.map((note) => FeedbackCard(feedback: note)).toList(),
              ],

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
              ...ratedOrders.map((order) => RatingHistoryCard(order: order)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
