import 'dart:math';
import '../models/cart_item.dart';
import '../models/order_model.dart';

class OrderRepository {
  final List<Order> _orders = [];

  Future<String> createOrder({
    required DateTime pickupTime,
    required List<CartItem> items,
    required String paymentMethod,
  }) async {
    final merchantName = items.isNotEmpty ? items.first.subtitle : 'Unknown Merchant';
    
    final order = Order(
      id: _generateOrderId(),
      orderTime: DateTime.now(),
      pickupTime: pickupTime,
      createdAt: DateTime.now(),
      readyAt: null,
      completedAt: null,
      cancelledAt: null,
      items: items.map((item) => OrderItem(
        name: item.name,
        imgBase64: item.image,
        subtitle: item.subtitle,
        price: item.price,
        quantity: item.quantity, sellerEmail: '',
      )).toList(),
      paymentMethod: paymentMethod,
      merchantName: merchantName, customerName: '', merchantEmail: '', // Using first item's subtitle as merchant name
    );

    _orders.insert(0, order);
    return order.id;
  }

  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<List<Order>> getOngoingOrders() async {
    return _orders.where((order) => order.status == 'ongoing').toList();
  }

  Future<List<Order>> getOrderHistory() async {
    return _orders.where((order) => order.status != 'ongoing').toList();
  }
}