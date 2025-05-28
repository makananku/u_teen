import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import './order_provider.dart';

class RatingProvider with ChangeNotifier {
  final OrderProvider _orderProvider;

  RatingProvider(this._orderProvider);

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
      throw Exception('Order with ID $orderId not found');
    }

    final now = DateTime.now();
    final updatedOrder = _orderProvider.orders[index].copyWith(
      status: 'completed',
      completedTime: now,
      completedAt: now,
      foodRating: foodRating,
      appRating: appRating,
      foodNotes: foodNotes,
      appNotes: appNotes,
    );

    await _orderProvider.updateOrderWithRatings(
      orderId: orderId,
      updatedOrder: updatedOrder,
    );
    notifyListeners();
  }
}