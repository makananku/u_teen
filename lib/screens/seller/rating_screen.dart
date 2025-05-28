import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/rating_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/widgets/rating/rating_summary_card.dart';
import 'package:u_teen/widgets/rating/rating_distribution_card.dart';
import 'package:u_teen/widgets/rating/feedback_card.dart';
import 'package:u_teen/widgets/rating/rating_history_card.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Theme(
      data: themeNotifier.currentTheme,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDarkMode),
        appBar: AppBar(
          title: Text(
            'Customer Ratings',
            style: TextStyle(
              color: AppTheme.getPrimaryText(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: isDarkMode ? 0 : 0.5,
          backgroundColor: AppTheme.getCard(isDarkMode),
          foregroundColor: AppTheme.getPrimaryText(isDarkMode),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            color: AppTheme.getBackground(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingSummaryCard(
                  averageRating: Provider.of<RatingProvider>(context).getAverageFoodRating(
                    Provider.of<AuthProvider>(context).sellerEmail ?? '',
                  ),
                  totalRatings: Provider.of<RatingProvider>(context)
                      .getRatedOrders(Provider.of<AuthProvider>(context).sellerEmail ?? '')
                      .length,
                ),
                const SizedBox(height: 24),

                Text(
                  'Rating Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                RatingDistributionCard(
                  ratedOrders: Provider.of<RatingProvider>(context)
                      .getRatedOrders(Provider.of<AuthProvider>(context).sellerEmail ?? ''),
                ),
                const SizedBox(height: 24),

                // Customer Feedback
                if (Provider.of<RatingProvider>(context)
                    .getFoodNotes(Provider.of<AuthProvider>(context).sellerEmail ?? '')
                    .isNotEmpty) ...[
                  Text(
                    'Customer Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...Provider.of<RatingProvider>(context)
                      .getFoodNotes(Provider.of<AuthProvider>(context).sellerEmail ?? '')
                      .map((note) => FeedbackCard(feedback: note))
                      .toList(),
                ],

                const SizedBox(height: 24),
                Text(
                  'Rating History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                if (Provider.of<RatingProvider>(context)
                    .getRatedOrders(Provider.of<AuthProvider>(context).sellerEmail ?? '')
                    .isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No ratings yet',
                        style: TextStyle(
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                      ),
                    ),
                  ),
                ...Provider.of<RatingProvider>(context)
                    .getRatedOrders(Provider.of<AuthProvider>(context).sellerEmail ?? '')
                    .map((order) => RatingHistoryCard(order: order))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}