import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _lastError;
  StreamSubscription? _subscription;
  String? _customerEmail;

  NotificationProvider();

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;

  List<NotificationModel> getNotificationsForCustomer(String customerEmail) {
    return _notifications
        .where((n) =>
            n.type == 'order' &&
            n.payload != null &&
            n.payload!['customerName'] == customerEmail)
        .toList();
  }

  int getUnreadCountForCustomer(String customerEmail) {
    return getNotificationsForCustomer(customerEmail)
        .where((n) => !n.isRead)
        .length;
  }

  Future<void> initialize(String customerEmail) async {
    if (_customerEmail == customerEmail) return;
    _customerEmail = customerEmail;
    await _loadNotifications();
    _setupRealTimeListener();
  }

  Future<void> _loadNotifications() async {
    if (_isLoading || _customerEmail == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('payload.customerName', isEqualTo: _customerEmail)
          .orderBy('timestamp', descending: true)
          .get();
      _notifications.clear();
      _notifications.addAll(snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())));
      _lastError = null;
      debugPrint('NotificationProvider: Loaded ${snapshot.docs.length} notifications for $_customerEmail');
    } catch (e) {
      _lastError = e.toString();
      debugPrint('NotificationProvider: Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealTimeListener() {
    if (_customerEmail == null) {
      debugPrint('NotificationProvider: No customer email set, skipping real-time listener');
      return;
    }
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('payload.customerName', isEqualTo: _customerEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          _notifications.clear();
          _notifications.addAll(snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())));
          _lastError = null;
          debugPrint('NotificationProvider: Real-time update: Loaded ${snapshot.docs.length} notifications for $_customerEmail');
          notifyListeners();
        }, onError: (error) {
          _lastError = error.toString();
          debugPrint('NotificationProvider: Error in real-time listener: $error');
          notifyListeners();
        });
  }

  Future<void> _saveNotification(NotificationModel notification) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap(), SetOptions(merge: true));
      debugPrint('NotificationProvider: Notification saved with ID: ${notification.id}');
    } catch (e) {
      debugPrint('NotificationProvider: Error saving notification: $e');
      throw Exception('Failed to save notification: $e');
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    if (_customerEmail == null || notification.payload?['customerName'] != _customerEmail) {
      debugPrint('NotificationProvider: Skipping notification for different customer');
      return;
    }
    _notifications.insert(0, notification);
    await _saveNotification(notification);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        type: _notifications[index].type,
        title: _notifications[index].title,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        payload: _notifications[index].payload,
      );
      await _saveNotification(_notifications[index]);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead({String? customerEmail}) async {
    if (customerEmail == null || customerEmail != _customerEmail) return;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          type: _notifications[i].type,
          title: _notifications[i].title,
          message: _notifications[i].message,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          payload: _notifications[i].payload,
        );
        await _saveNotification(_notifications[i]);
      }
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    if (_customerEmail == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (var notification in _notifications) {
      batch.delete(FirebaseFirestore.instance.collection('notifications').doc(notification.id));
    }
    await batch.commit();
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    debugPrint('NotificationProvider: Disposed');
    super.dispose();
  }
}