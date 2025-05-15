import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import './order_provider.dart';

class RatingsProvider with ChangeNotifier {
  final OrderProvider orderProvider;

  RatingsProvider(this.orderProvider);

  // Get all completed orders with ratings for a seller
  List<Order> getRatedOrders(String merchantEmail) {
    return orderProvider.orders
        .where((order) =>
            order.status == 'completed' &&
            order.merchantEmail == merchantEmail &&
            order.foodRating != null &&
          order.completedAt != null)
            
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

  // Submit ratings for an order
  Future<void> submitRating({
    required String orderId,
    required int foodRating,
    required int appRating,
    String? foodNotes,
    String? appNotes,
  }) async {
    final index = orderProvider.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final now = DateTime.now();
      final updatedOrder = Order(
        id: orderProvider.orders[index].id,
        orderTime: orderProvider.orders[index].orderTime,
        pickupTime: orderProvider.orders[index].pickupTime,
        items: orderProvider.orders[index].items,
        paymentMethod: orderProvider.orders[index].paymentMethod,
        merchantName: orderProvider.orders[index].merchantName,
        merchantEmail: orderProvider.orders[index].merchantEmail,
        customerName: orderProvider.orders[index].customerName,
        status: 'completed',
        cancellationReason: orderProvider.orders[index].cancellationReason,
        notes: orderProvider.orders[index].notes,
        completedTime: now,
        cancelledTime: orderProvider.orders[index].cancelledTime,
        readyAt: orderProvider.orders[index].readyAt,
        completedAt: now,
        cancelledAt: orderProvider.orders[index].cancelledAt,
        foodRating: foodRating,
        appRating: appRating,
        foodNotes: foodNotes,
        appNotes: appNotes,
        createdAt: orderProvider.orders[index].createdAt,
      );
      orderProvider.orders[index] = updatedOrder;
      await orderProvider.updateOrderStatus(orderId, 'completed');
      notifyListeners();
    }
  }
}