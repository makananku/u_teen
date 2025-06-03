import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_teen/models/order_model.dart' as order;
import '../models/notification_model.dart';
import './notification_provider.dart';

class OrderProvider with ChangeNotifier {
  final List<order.Order> _orders = [];
  final NotificationProvider _notificationProvider;
  bool _isLoading = false;
  String? _lastError;
  final Map<String, Timer> _readyTimers = {};
  StreamSubscription? _subscription;
  String? _customerEmail;

  OrderProvider(this._notificationProvider);

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  void clearLastError() {
    _lastError = null;
    debugPrint('OrderProvider: Cleared lastError');
    notifyListeners();
  }

  Future<void> initialize(String customerEmail) async {
    if (_customerEmail == customerEmail) return;
    _customerEmail = customerEmail;
    debugPrint('OrderProvider: Initializing for customer $customerEmail');
    await _initialize();
  }

  Future<void> _initialize() async {
    await initializeOrders();
    _setupRealTimeListener();
  }

  Future<void> initializeOrders() async {
    if (_customerEmail == null) {
      debugPrint('OrderProvider: No customer email set, skipping initialization');
      return;
    }
    _isLoading = true;
    notifyListeners();
    const maxRetries = 2;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        debugPrint('OrderProvider: Fetching orders for $_customerEmail (attempt ${attempt + 1})');
        final snapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('customerName', isEqualTo: _customerEmail)
            .orderBy('createdAt', descending: true)
            .get()
            .timeout(const Duration(seconds: 5));
        _orders.clear();
        _orders.addAll(snapshot.docs.map((doc) => order.Order.fromMap(doc.data())).toList());
        _lastError = null;
        debugPrint('OrderProvider: Loaded ${_orders.length} orders for $_customerEmail');
        break; // Success, exit loop
      } catch (e) {
        attempt++;
        if (e.toString().contains('failed-precondition') && attempt < maxRetries) {
          debugPrint('OrderProvider: Index error, retrying after delay (attempt $attempt): $e');
          await Future.delayed(const Duration(seconds: 2)); // Wait before retry
          continue;
        }
        _lastError = 'Gagal memuat pesanan: $e';
        debugPrint('OrderProvider: Error loading orders: $e');
        throw Exception('Gagal memuat pesanan: $e');
      } finally {
        if (attempt >= maxRetries || _lastError == null) {
          _isLoading = false;
          notifyListeners();
        }
      }
    }
  }

  void _setupRealTimeListener() {
    if (_customerEmail == null) {
      debugPrint('OrderProvider: No customer email set, skipping real-time listener');
      return;
    }
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .where('customerName', isEqualTo: _customerEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _orders.clear();
          _orders.addAll(snapshot.docs.map((doc) => order.Order.fromMap(doc.data())).toList());
          _lastError = null;
          debugPrint('OrderProvider: Real-time update: Loaded ${_orders.length} orders for $_customerEmail');
          notifyListeners();
        }, onError: (error) {
          _lastError = 'Error listener real-time: $error';
          debugPrint('OrderProvider: Error in real-time listener: $error');
          notifyListeners();
        });
  }

  Future<void> _saveOrder(order.Order order) async {
    try {
      if (order.id.isEmpty || order.merchantEmail.isEmpty || order.customerName.isEmpty) {
        throw Exception('Data pesanan tidak valid: id, merchantEmail, atau customerName kosong');
      }
      debugPrint('OrderProvider: Saving order ${order.id} to Firestore');
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .set(order.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 5), onTimeout: () {
            debugPrint('OrderProvider: Firestore save timeout for order ${order.id}');
            throw Exception('Timeout menyimpan ke Firestore');
          });
      debugPrint('OrderProvider: Successfully saved order ${order.id}');
    } catch (e) {
      debugPrint('OrderProvider: Error saving order ${order.id}: $e');
      throw Exception('Gagal menyimpan pesanan: $e');
    }
  }

  List<order.Order> get orders => List.unmodifiable(_orders);

  List<order.Order> get pendingOrders => _orders.where((o) => o.status == 'pending').toList();
  List<order.Order> get processingOrders => _orders.where((o) => o.status == 'processing').toList();
  List<order.Order> get readyOrders => _orders.where((o) => o.status == 'ready').toList();
  List<order.Order> get completedOrders => _orders.where((o) => o.status == 'completed').toList();
  List<order.Order> get cancelledOrders => _orders.where((o) => o.status == 'cancelled').toList();

  List<order.Order> getOrdersForMerchant(String merchantEmail) {
    return _orders.where((o) => o.merchantEmail == merchantEmail).toList();
  }

  List<order.Order> getProcessingOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) =>
            o.merchantEmail == merchantEmail &&
            (o.status == 'pending' || o.status == 'processing'))
        .toList();
  }

  List<order.Order> getReadyOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'ready')
        .toList();
  }

  List<order.Order> getCompletedOrdersForMerchant(String merchantEmail) {
    return _orders
        .where((o) => o.merchantEmail == merchantEmail && o.status == 'completed')
        .toList();
  }

  List<order.Order> getCancelledOrdersForMerchant(String merchantEmail) {
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

  List<order.Order> getOngoingOrdersForCustomer(String customerEmail) {
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

  List<order.Order> getCompletedOrdersForCustomer(String customerEmail) {
    return _orders
        .where((o) => o.status == 'completed' && o.customerName == customerEmail)
        .toList();
  }

  Future<void> addOrder(order.Order order) async {
    try {
      _isLoading = true;
      notifyListeners();
      if (order.id.isEmpty || order.merchantEmail.isEmpty || order.customerName.isEmpty) {
        throw Exception('Data pesanan tidak valid: id, merchantEmail, atau customerName kosong');
      }
      debugPrint('OrderProvider: Adding order ${order.id}');
      _orders.insert(0, order);
      await _saveOrder(order);
      final notification = NotificationModel.fromOrder(order);
      // Send notification async without awaiting
      _notificationProvider.addNotification(notification).catchError((e) {
        debugPrint('OrderProvider: Gagal mengirim notifikasi untuk pesanan ${order.id}: $e');
      });
      debugPrint('OrderProvider: Added order ${order.id}');
    } catch (e) {
      debugPrint('OrderProvider: Error adding order ${order.id}: $e');
      _orders.removeWhere((o) => o.id == order.id);
      _lastError = 'Gagal menambah pesanan: $e';
      throw Exception('Gagal menambah pesanan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, {String? reason}) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      debugPrint('OrderProvider: Pesanan $orderId tidak ditemukan');
      _lastError = 'Pesanan tidak ditemukan';
      throw Exception('Pesanan tidak ditemukan');
    }
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('OrderProvider: Updating order $orderId to status $newStatus');
      final now = DateTime.now();
      if (_orders[index].status == 'ready' && newStatus != 'ready') {
        _readyTimers[orderId]?.cancel();
        _readyTimers.remove(orderId);
        debugPrint('OrderProvider: Cancelled timer for order $orderId');
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
        debugPrint('OrderProvider: Started timer for order $orderId');
      }
      await _saveOrder(_orders[index]);
      // Send notification async without awaiting
      if (['ready', 'completed', 'cancelled'].contains(newStatus)) {
        _notificationProvider
            .addNotification(NotificationModel.fromOrder(_orders[index]))
            .catchError((e) {
          debugPrint('OrderProvider: Gagal mengirim notifikasi untuk pesanan $orderId: $e');
        });
      }
      debugPrint('OrderProvider: Successfully updated order $orderId to $newStatus');
    } catch (e) {
      debugPrint('OrderProvider: Error updating order $orderId to $newStatus: $e');
      _lastError = 'Gagal memperbarui status pesanan: $e';
      throw Exception('Gagal memperbarui status pesanan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('OrderProvider: Finished updateOrderStatus for order $orderId');
    }
  }

  Future<void> updateOrderWithRatings({
    required String orderId,
    required order.Order updatedOrder,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      debugPrint('Order: Pesanan $orderId tidak ditemukan');
      _lastError = 'Pesanan tidak ditemukan';
      throw Exception('Pesanan dengan ID $orderId tidak ditemukan');
    }
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('Order: Updating order $orderId with ratings');
      if (_orders[index].status == 'ready') {
        _readyTimers[orderId]?.cancel();
        _readyTimers.remove(orderId);
        debugPrint('Order: Cancelled timer untuk order $orderId');
      }
      _orders[index] = updatedOrder;
      await _saveOrder(updatedOrder);
      // Send notification async tanpa menunggu
      _notificationProvider
          .addNotification(NotificationModel.fromOrder(updatedOrder))
          .catchError((e) {
        debugPrint('Order: Gagal mengirim notifikasi untuk pesanan $orderId: $e');
      });
      debugPrint('Order: Successfully updated order $orderId dengan ratings');
    } catch (e) {
      debugPrint('Order: Error updating order dengan ratings: $e');
      _lastError = 'Gagal memperbarui pesanan dengan rating: $e';
      throw Exception('Gagal memperbarui pesanan dengan rating: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
    if (index == -1) {
      debugPrint('Order: Pesanan $orderId tidak ditemukan');
      _lastError = 'Pesanan tidak ditemukan';
      throw Exception('Pesanan tidak ditemukan');
    }
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('Order: Submitting rating untuk order $orderId');
      final now = DateTime.now();
      _readyTimers[orderId]?.cancel();
      _readyTimers.remove(orderId);
      debugPrint('Order: Cancelled timer untuk order $orderId');
      _orders[index] = _orders[index].copyWith(
        status: 'completed',
        completedTime: now,
        completedAt: now,
        foodRating: foodRating,
        appRating: appRating,
        foodNotes: foodNotes,
        appNotes: appNotes,
      );
      await _saveOrder(_orders[index]);
      // Send notification async tanpa mengetahui
      _notificationProvider
          .addNotification(NotificationModel.fromOrder(_orders[index]))
          .catchError((e) {
        debugPrint('Order: Gagal menghasilkan notifikasi untuk pesanan $orderId: $e');
      });
      debugPrint('Order: Successfully submitted rating untuk order $orderId');
    } catch (e) {
      debugPrint('Order: Error submitting rating untuk order $orderId: $e');
      _lastError = 'Gagal mengirim rating: $e';
      throw Exception('Gagal mengirim rating: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _autoCompleteOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1 || _orders[index].status != 'ready') {
      debugPrint('Order: Tidak valid untuk auto-complete order $orderId');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('Order: Auto-completing order $orderId');
      final now = DateTime.now();
      _orders[index] = _orders[index].copyWith(
        status: 'completed',
        completedTime: now,
        completedAt: now,
        foodRating: null,
        appRating: null,
        foodNotes: null,
      );
      _readyTimers.remove(orderId);
      await _saveOrder(_orders[index]);
      // Send notification async tanpa mengetahui
      _notificationProvider
          .addNotification(NotificationModel.fromOrder(_orders[index]))
          .catchError((e) {
        debugPrint('Order: Gagal mengirim notifikasi untuk pesanan $orderId: $e');
      });
      debugPrint('Order: Successfully auto-completed order $orderId');
    } catch (e) {
      debugPrint('Order: Error auto-completing order $orderId: $e');
      _lastError = 'Error auto-completing order: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  order.Order createOrderFromCart({
    required List<order.OrderItem> items,
    required DateTime pickupTime,
    required String paymentMethod,
    required String merchantName,
    required String merchantEmail,
    required String customerName,
    String? notes,
  }) {
    if (items.isEmpty || merchantEmail.isEmpty || customerName.isEmpty) {
      throw Exception('Data pesanan tidak valid: items, merchantEmail, atau customerName kosong');
    }
    debugPrint('Order: Creating order dari cart untuk $customerName');
    return order.Order(
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
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Trying: Adding withdrawal untuk $merchantEmail');
      final withdrawal = order.Order(
        id: _generateOrderId(),
        orderTime: DateTime.now(),
        pickupTime: DateTime.now(),
        items: [
          order.OrderItem(
            name: 'Withdrawal',
            imgBase64: 'assets/withdrawal.png',
            subtitle: 'Withdrawal ke $method',
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
        notes: 'Withdrawal ke $method',
        readyAt: null,
        completedAt: null,
        cancelledAt: null,
        createdAt: DateTime.now(),
      );
      _orders.insert(0, withdrawal);
      await _saveOrder(withdrawal);
      debugPrint('Order: Successfully added withdrawal untuk $merchantEmail');
    } catch (e) {
      debugPrint('Order: Error adding withdrawal: $e');
      _lastError = 'Gagal menambah penarikan: $e';
      throw Exception('Gagal menambah penarikan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<order.Order> getTransactionListForMerchant(String merchantEmail) {
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
    final random = new Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join('');
  }

  int getTotalEarningsForMerchant(String merchantEmail) {
    return _orders
        .where((order) =>
            order.merchantEmail == merchantEmail && order.status == 'completed')
        .fold(0, (sum, order) => sum + order.totalPrice.round());
  }

  Future<void> clearOrders() async {
    try {
      _isLoading = true;
      notifyListeners();
      _readyTimers.forEach((orderId, timer) {
        timer.cancel();
        debugPrint('Order: Cancelled timer untuk order $orderId');
      });
      _readyTimers.clear();
      _orders.clear();
      debugPrint('Order: Cleared semua pesanan lokal');
    } catch (e) {
      debugPrint('Order: Error clearing orders: $e');
      _lastError = 'Gagal menghapus pesanan: $e';
      throw Exception('Gagal menghapus pesanan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _readyTimers.forEach((_, timer) => timer.cancel());
    _readyTimers.clear();
    _subscription?.cancel();
    debugPrint('Order: Disposed');
    super.dispose();
  }
}