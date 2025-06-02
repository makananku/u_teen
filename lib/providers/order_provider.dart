
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:u_teen/models/order_model.dart' as models;
import '../models/notification_model.dart';
import './notification_provider.dart';

class OrderProvider with ChangeNotifier {
  final List<models.Order> _orders = [];
  final NotificationProvider _notificationProvider;
  bool _isLoading = false;
  final Map<String, Timer> _readyTimers = {};

  OrderProvider(this._notificationProvider) {
    initialize();
  }

  Future<void> initialize() async {
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      _orders.clear();
      _orders.addAll(snapshot.docs.map((doc) => models.Order.fromMap(doc.data())).toList());
      debugPrint('OrderProvider: Loaded ${_orders.length} orders');
    } catch (e) {
      debugPrint('OrderProvider: Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveOrder(models.Order order) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .set(order.toMap());
      debugPrint('OrderProvider: Saved order ${order.id} for customer ${order.customerName}');
    } catch (e) {
      debugPrint('OrderProvider: Error saving order ${order.id}: $e');
      rethrow; // Propagate error for debugging
    }
  }

  List<models.Order> get orders => List.unmodifiable(_orders);

  List<models.Order> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();
  List<models.Order> get processingOrders => _orders.where((o) => o.status == 'processing').toList();
  List<models.Order> get readyOrders => _orders.where((o) => o.status == 'ready').toList();
  List<models.Order> get completedOrders => _orders.where((o) => o.status == 'completed').toList();
  List<models.Order> get cancelledOrders => _orders.where((o) => o.status == 'cancelled').toList();

  List<models.Order> getOrdersForMerchant(String merchantEmail) {
    return _orders.where((o) => o.merchantEmail == merchantEmail).toList();
  }

  List<models.Order> getProcessingOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) =>
            o.merchantEmail == merchantEmail &&
            (o.status == 'pending' || o.status == 'processing'))
        .toList();
  }

  List<models.Order> getReadyOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'ready')
        .toList();
  }

  List<models.Order> getCompletedOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'completed')
        .toList();
  }

  List<models.Order> getCancelledOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'cancelled')
        .toList();
  }

  List<Map<String, String>> getOrderAgainItemsForCustomer(String customerEmail) {
    final completedOrders = getCompletedOrdersForCustomer(customerEmail);
    final Map<String, Map<String, String>> uniqueItems = {};

    for (var order in completedOrders) {
      for (var item in order.items) {
        final itemKey = item.name;
        final itemData = {
          'title': item.name,
          'subtitle': item.subtitle,
          'imgBase64': item.imgBase64,
          'price': item.price.toString(),
          'sellerEmail': item.sellerEmail,
          'orderTime': order.completedAt?.toIso8601String() ?? order.orderTime.toIso8601String(),
        };

        if (!uniqueItems.containsKey(itemKey) ||
            DateTime.parse(itemData['orderTime']!).isAfter(
                DateTime.parse(uniqueItems[itemKey]!['orderTime']!))) {
          uniqueItems[itemKey] = itemData;
        }
      }
    }

    final itemList = uniqueItems.values.toList()
      ..sort((a, b) => DateTime.parse(b['orderTime']!).compareTo(DateTime.parse(a['orderTime']!)));

    return itemList.map((item) {
      final newItem = Map<String, String>.from(item);
      newItem.remove('orderTime');
      newItem['time'] = newItem['time'] ?? '10 mins';
      return newItem;
    }).toList();
  }

  List<models.Order> getOngoingOrdersForCustomer(String customerEmail) {
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

  List<models.Order> getCompletedOrdersForCustomer(String customerEmail) {
    return _orders
        .where((o) => o.status == 'completed' && o.customerName == customerEmail)
        .toList();
  }

  Future<void> addOrder(models.Order order) async {
    _orders.insert(0, order);
    await _saveOrder(order);
    notifyListeners();
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
      await _saveOrder(_orders[index]);
      notifyListeners();
    }
  }

  Future<void> updateOrderWithRatings({
    required String orderId,
    required models.Order updatedOrder,
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
    await _saveOrder(updatedOrder);
    notifyListeners();
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
      await _saveOrder(_orders[index]);
      notifyListeners();
    }
  }

  Future<models.Order> createOrderFromCart({
    required String customerUid,
    required List<models.OrderItem> items,
    required DateTime pickupTime,
    required String paymentMethod,
    required String merchantName,
    required String merchantEmail,
    String? notes,
  }) async {
    try {
      // Fetch customer email from users/{customerUid}
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(customerUid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User with UID $customerUid not found');
      }
      final customerEmail = userDoc.data()?['email'] as String?;
      if (customerEmail == null) {
        throw Exception('Email not found for user $customerUid');
      }

      debugPrint('OrderProvider: Creating order for customer UID: $customerUid, email: $customerEmail');

      final order = models.Order(
        id: _generateOrderId(),
        orderTime: DateTime.now(),
        pickupTime: pickupTime,
        items: items,
        paymentMethod: paymentMethod,
        merchantName: merchantName,
        merchantEmail: merchantEmail,
        customerName: customerEmail,
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

      debugPrint('OrderProvider: Order created with ID: ${order.id}, customer: $customerEmail, merchant: $merchantEmail');

      return order;
    } catch (e) {
      debugPrint('OrderProvider: Error creating order: $e');
      rethrow;
    }
  }

  Future<void> addWithdrawal({
    required String merchantEmail,
    required double amount,
    required String method,
  }) async {
    final withdrawal = models.Order(
      id: _generateOrderId(),
      orderTime: DateTime.now(),
      pickupTime: DateTime.now(),
      items: [
        models.OrderItem(
          name: 'Withdrawal',
          imgBase64: 'assets/withdrawal.png',
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
    await _saveOrder(withdrawal);
    notifyListeners();
  }

  List<models.Order> getTransactionsForMerchant(String merchantEmail) {
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

  Future<void> _autoCompleteOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == 'ready') {
      final now = DateTime.now();
      _orders[index] = _orders[index].copyWith(
        status: 'completed',
        completedTime: now,
        completedAt: now,
      );
      await _notificationProvider.addNotification(
        NotificationModel.fromOrder(_orders[index]),
      );
      await _saveOrder(_orders[index]);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _readyTimers.forEach((_, timer) => timer.cancel());
    _readyTimers.clear();
    super.dispose();
  }
}