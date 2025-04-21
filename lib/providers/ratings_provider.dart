import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import 'order_provider.dart';
import 'package:provider/provider.dart';

class RatingsProvider with ChangeNotifier {
  final OrderProvider orderProvider;

  RatingsProvider(this.orderProvider);

  // Get all completed orders with ratings for a seller
  List<Order> getRatedOrders(String merchantEmail) {
    return orderProvider.orders
        .where((order) =>
            order.status == 'completed' &&
            order.merchantEmail == merchantEmail &&
            order.foodRating != null)
        .toList();
  }

  // Get average food rating for a seller
  double getAverageFoodRating(String merchantEmail) {
    final ratedOrders = getRatedOrders(merchantEmail);
    if (ratedOrders.isEmpty) return 0.0;
    final totalRating = ratedOrders.fold<int>(
        0, (sum, order) => sum + (order.foodRating ?? 0));
    return totalRating / ratedOrders.length;
  }

  // Get all food notes for a seller
  List<String> getFoodNotes(String merchantEmail) {
    return getRatedOrders(merchantEmail)
        .where((order) => order.foodNotes != null && order.foodNotes!.isNotEmpty)
        .map((order) => order.foodNotes!)
        .toList();
  }
}