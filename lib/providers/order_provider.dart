import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import './notification_provider.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  late final SharedPreferences _prefs;
  final NotificationProvider _notificationProvider;
  bool _isSaving = false;

  OrderProvider(SharedPreferences prefs, this._notificationProvider) : _prefs = prefs {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final ordersJson = _prefs.getString('orders');
    if (ordersJson != null) {
      try {
        final List<dynamic> ordersMap = json.decode(ordersJson);
        _orders.addAll(ordersMap.map((map) => Order.fromMap(map)).toList());
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading orders: $e');
      }
    }
  }

  Future<void> _saveOrders() async {
    if (_isSaving) return;
    _isSaving = true;

    try {
      final ordersJson = json.encode(_orders.map((o) => o.toMap()).toList());
      await _prefs.setString('orders', ordersJson);
    } catch (e) {
      debugPrint('Error saving orders: $e');
    } finally {
      _isSaving = false;
    }
  }

  // Get all orders
  List<Order> get orders => List.unmodifiable(_orders);

  // Get orders by status
  List<Order> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();
  List<Order> get processingOrders => _orders.where((o) => o.status == 'processing').toList();
  List<Order> get readyOrders => _orders.where((o) => o.status == 'ready').toList();
  List<Order> get completedOrders => _orders.where((o) => o.status == 'completed').toList();
  List<Order> get cancelledOrders => _orders.where((o) => o.status == 'cancelled').toList();

  // Merchant-specific orders
  List<Order> getOrdersForMerchant(String merchantEmail) {
    return _orders.where((o) => o.merchantEmail == merchantEmail).toList();
  }

  List<Order> getProcessingOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) =>
            o.merchantEmail == merchantEmail &&
            (o.status == 'pending' || o.status == 'processing'))
        .toList();
  }

  List<Order> getReadyOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'ready')
        .toList();
  }

  List<Order> getCompletedOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'completed')
        .toList();
  }

  List<Order> getCancelledOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'cancelled')
        .toList();
  }

  // Customer-specific orders
  List<Order> getOrdersForCustomer(String customerEmail) {
    return _orders.where((o) => o.customerName == customerEmail).toList();
  }

  List<Order> getOngoingOrdersForCustomer(String customerEmail) {
    final orders = _orders
        .where(
          (o) => o.status != 'completed' && o.customerName == customerEmail,
        )
        .toList();
    orders.sort((a, b) {
      const statusPriority = {
        'ready': 1,
        'pending': 2,
        'processing': 3,
      };
      return statusPriority[a.status]!.compareTo(statusPriority[b.status]!);
    });
    return orders;
  }

  List<Order> getCompletedOrdersForCustomer(String customerEmail) {
    return _orders
        .where((o) => o.status == 'completed' && o.customerName == customerEmail)
        .toList();
  }

  // Order operations
  Future<void> addOrder(Order order) async {
    _orders.insert(0, order);
    notifyListeners();
    await _saveOrders();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, {String? reason}) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final now = DateTime.now();
      _orders[index] = Order(
        id: _orders[index].id,
        orderTime: _orders[index].orderTime,
        pickupTime: _orders[index].pickupTime,
        items: _orders[index].items,
        paymentMethod: _orders[index].paymentMethod,
        merchantName: _orders[index].merchantName,
        merchantEmail: _orders[index].merchantEmail,
        customerName: _orders[index].customerName,
        status: newStatus,
        cancellationReason: reason,
        notes: _orders[index].notes,
        completedTime: newStatus == 'completed' ? now : _orders[index].completedTime,
        cancelledTime: newStatus == 'cancelled' ? now : _orders[index].cancelledTime,
        readyAt: newStatus == 'ready' ? now : _orders[index].readyAt,
        completedAt: newStatus == 'completed' ? now : _orders[index].completedAt,
        cancelledAt: newStatus == 'cancelled' ? now : _orders[index].cancelledAt,
        foodRating: _orders[index].foodRating,
        appRating: _orders[index].appRating,
        foodNotes: _orders[index].foodNotes,
        appNotes: _orders[index].appNotes,
        createdAt: _orders[index].createdAt,
      );
      if (['ready', 'completed', 'cancelled'].contains(newStatus)) {
        await _notificationProvider.addNotification(
            NotificationModel.fromOrder(_orders[index]));
      }
      notifyListeners();
      await _saveOrders();
    }
  }

  Future<void> submitRatingAndCompleteOrder({
    required String orderId,
    required int foodRating,
    required int appRating,
    String? foodNotes,
    String? appNotes,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final now = DateTime.now();
      _orders[index] = Order(
        id: _orders[index].id,
        orderTime: _orders[index].orderTime,
        pickupTime: _orders[index].pickupTime,
        items: _orders[index].items,
        paymentMethod: _orders[index].paymentMethod,
        merchantName: _orders[index].merchantName,
        merchantEmail: _orders[index].merchantEmail,
        customerName: _orders[index].customerName,
        status: 'completed',
        cancellationReason: _orders[index].cancellationReason,
        notes: _orders[index].notes,
        completedTime: now,
        cancelledTime: _orders[index].cancelledTime,
        readyAt: _orders[index].readyAt,
        completedAt: now,
        cancelledAt: _orders[index].cancelledAt,
        foodRating: foodRating,
        appRating: appRating,
        foodNotes: foodNotes,
        appNotes: appNotes,
        createdAt: _orders[index].createdAt,
      );
      await _notificationProvider.addNotification(
          NotificationModel.fromOrder(_orders[index]));
      notifyListeners();
      await _saveOrders();
    }
  }

  Order createOrderFromCart({
    required List<OrderItem> items,
    required DateTime pickupTime,
    required String paymentMethod,
    required String merchantName,
    required String merchantEmail,
    required String customerName,
    String? notes,
  }) {
    return Order(
      id: _generateOrderId(),
      orderTime: DateTime.now(),
      pickupTime: pickupTime,
      items: items,
      paymentMethod: paymentMethod,
      merchantName: merchantName,
      merchantEmail: merchantEmail,
      customerName: customerName,
      status: 'pending',
      notes: notes,
      foodRating: null,
      appRating: null,
      foodNotes: null,
      appNotes: null,
      readyAt: null,
      completedAt: null,
      cancelledAt: null,
      createdAt: DateTime.now(),
    );
  }

  // Withdrawal operations
  Future<void> addWithdrawal({
    required String merchantEmail,
    required double amount,
    required String method,
  }) async {
    final withdrawal = Order(
      id: _generateOrderId(),
      orderTime: DateTime.now(),
      pickupTime: DateTime.now(),
      items: [
        OrderItem(
          name: 'Withdrawal',
          image: 'assets/withdrawal.png',
          subtitle: 'Withdrawal to $method',
          price: amount.round(),
          quantity: 1,
          sellerEmail: merchantEmail,
        )
      ],
      paymentMethod: method,
      merchantName: 'System',
      merchantEmail: merchantEmail,
      customerName: 'Withdrawal',
      status: 'processed',
      notes: 'Withdrawal to $method',
      readyAt: null,
      completedAt: null,
      cancelledAt: null,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, withdrawal);
    notifyListeners();
    await _saveOrders();
  }

  // Transaction history
  List<Order> getTransactionsForMerchant(String merchantEmail) {
    return _orders
        .where((order) =>
            order.merchantEmail == merchantEmail &&
            (order.status == 'completed' || order.customerName == 'Withdrawal'))
        .toList();
  }

  // Balance calculation
  int getAvailableBalanceForMerchant(String merchantEmail) {
    double earnings = 0;
    double withdrawals = 0;

    for (var order in _orders) {
      if (order.merchantEmail == merchantEmail) {
        if (order.status == 'completed' && order.customerName != 'Withdrawal') {
          earnings += order.totalPrice;
        } else if (order.customerName == 'Withdrawal') {
          withdrawals += order.totalPrice;
        }
      }
    }

    return (earnings - withdrawals).round();
  }

  // Helper methods
  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  int getTotalEarningsForMerchant(String merchantEmail) {
    return _orders
        .where((order) =>
            order.merchantEmail == merchantEmail && order.status == 'completed')
        .fold(0, (int sum, order) => sum + order.totalPrice.round());
  }
}