import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/rating/rating_summary_card.dart';
import '../../widgets/rating/rating_distribution_card.dart';
import '../../widgets/rating/feedback_card.dart';
import '../../widgets/rating/rating_history_card.dart';
import '../../providers/theme_notifier.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          final isDarkMode = themeNotifier.isDarkMode;
          return Theme(
            data: themeNotifier.currentTheme,
            child: Scaffold(
              backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
              appBar: AppBar(
                title: Text(
                  'Customer Ratings',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                elevation: isDarkMode ? 0 : 0.5,
                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
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
                          color: isDarkMode ? Colors.white : Colors.black,
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
                            color: isDarkMode ? Colors.white : Colors.black,
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
                          color: isDarkMode ? Colors.white : Colors.black,
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
                                color: isDarkMode ? Colors.grey[400] : Colors.grey,
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
        },
      ),
    );
  }
}