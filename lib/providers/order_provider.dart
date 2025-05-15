import 'dart:async';
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
  final Map<String, Timer> _readyTimers = {};

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

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();
  List<Order> get processingOrders => _orders.where((o) => o.status == 'processing').toList();
  List<Order> get readyOrders => _orders.where((o) => o.status == 'ready').toList();
  List<Order> get completedOrders => _orders.where((o) => o.status == 'completed').toList();
  List<Order> get cancelledOrders => _orders.where((o) => o.status == 'cancelled').toList();

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

  Future<void> addOrder(Order order) async {
    _orders.insert(0, order);
    notifyListeners();
    await _saveOrders();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, {String? reason}) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final now = DateTime.now();
      if (_orders[index].status == 'ready' && newStatus != 'ready') {
        _readyTimers[orderId]?.cancel();
        _readyTimers.remove(orderId);
      }
      _orders[index] = _orders[index].copyWith(
        status: newStatus,
        cancellationReason: reason,
        completedTime: newStatus == 'completed' ? now : _orders[index].completedTime,
        cancelledTime: newStatus == 'cancelled' ? now : _orders[index].cancelledTime,
        readyAt: newStatus == 'ready' ? now : _orders[index].readyAt,
        completedAt: newStatus == 'completed' ? now : _orders[index].completedAt,
        cancelledAt: newStatus == 'cancelled' ? now : _orders[index].cancelledAt,
      );
      if (newStatus == 'ready') {
        _readyTimers[orderId] = Timer(const Duration(minutes: 2), () {
          _autoCompleteOrder(orderId);
        });
      }
      if (['ready', 'completed', 'cancelled'].contains(newStatus)) {
        await _notificationProvider.addNotification(
            NotificationModel.fromOrder(_orders[index]));
      }
      notifyListeners();
      await _saveOrders();
    }
  }

  Future<void> updateOrderWithRatings({
    required String orderId,
    required Order updatedOrder,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order with ID $orderId not found');
    }
    if (_orders[index].status == 'ready') {
      _readyTimers[orderId]?.cancel();
      _readyTimers.remove(orderId);
    }
    _orders[index] = updatedOrder;
    await _notificationProvider.addNotification(
      NotificationModel.fromOrder(updatedOrder),
    );
    notifyListeners();
    await _saveOrders();
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
      _readyTimers[orderId]?.cancel();
      _readyTimers.remove(orderId);
      _orders[index] = _orders[index].copyWith(
        status: 'completed',
        completedTime: now,
        completedAt: now,
        foodRating: foodRating,
        appRating: appRating,
        foodNotes: foodNotes,
        appNotes: appNotes,
      );
      await _notificationProvider.addNotification(
          NotificationModel.fromOrder(_orders[index]));
      notifyListeners();
      await _saveOrders();
    }
  }

  Future<void> _autoCompleteOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == 'ready') {
      final now = DateTime.now();
      _orders[index] = _orders[index].copyWith(
        status: 'completed',
        completedTime: now,
        completedAt: now,
        foodRating: null,
        appRating: null,
        foodNotes: null,
        appNotes: null,
      );
      _readyTimers.remove(orderId);
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

  List<Order> getTransactionsForMerchant(String merchantEmail) {
    return _orders
        .where((order) =>
            order.merchantEmail == merchantEmail &&
            (order.status == 'completed' || order.customerName == 'Withdrawal'))
        .toList();
  }

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

  @override
  void dispose() {
    _readyTimers.forEach((_, timer) => timer.cancel());
    _readyTimers.clear();
    super.dispose();
  }
}