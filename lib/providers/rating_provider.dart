import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import './order_provider.dart';

class RatingProvider with ChangeNotifier {
  final OrderProvider _orderProvider;
  bool _isLoading = false;

  RatingProvider(this._orderProvider);

  bool get isLoading => _isLoading;

  List<Order> _getCompletedOrdersWithRatings(String merchantEmail) {
    return _orderProvider.orders
        .where((order) =>
            order.status == 'completed' &&
            order.merchantEmail == merchantEmail &&
            order.foodRating != null &&
            order.completedAt != null)
        .toList();
  }

  List<Order> getRatedOrders(String merchantEmail) =>
      _getCompletedOrdersWithRatings(merchantEmail);

  double getAverageFoodRating(String merchantEmail) {
    final ratedOrders = _getCompletedOrdersWithRatings(merchantEmail);
    if (ratedOrders.isEmpty) return 0.0;

    final totalRating =
        ratedOrders.fold<int>(0, (sum, order) => sum + (order.foodRating ?? 0));
    return totalRating / ratedOrders.length;
  }

  List<String> getFoodNotes(String merchantEmail) {
    return _getCompletedOrdersWithRatings(merchantEmail)
        .where((order) => order.foodNotes?.isNotEmpty ?? false)
        .map((order) => order.foodNotes!)
        .toList();
  }

  Future<void> submitRating({
    required String orderId,
    required int foodRating,
    required int appRating,
    String? foodNotes,
    String? appNotes,
  }) async {
    final index = _orderProvider.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      debugPrint('RatingProvider: Order with ID $orderId not found');
      throw Exception('Order with ID $orderId not found');
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _orderProvider.submitRatingAndCompleteOrder(
        orderId: orderId,
        foodRating: foodRating,
        appRating: appRating,
        foodNotes: foodNotes,
        appNotes: appNotes,
      );
      debugPrint('RatingProvider: Successfully submitted rating for order $orderId');
    } catch (e) {
      debugPrint('RatingProvider: Error submitting rating: $e');
      throw Exception('Failed to submit rating: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}