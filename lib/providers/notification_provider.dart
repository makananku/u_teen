import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;

  List<NotificationModel> getNotificationsForCustomer(String customerName) {
    return _notifications
        .where((n) =>
            n.type == 'order' &&
            n.payload != null &&
            n.payload!['customerName'] == customerName)
        .toList();
  }

  int getUnreadCountForCustomer(String customerName) {
    return getNotificationsForCustomer(customerName)
        .where((n) => !n.isRead)
        .length;
  }

  Future<void> _loadNotifications() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();
      _notifications.clear();
      _notifications.addAll(snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())));
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveNotification(NotificationModel notification) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  Future<void> initialize() async {
    await _loadNotifications();
  }

  Future<void> addNotification(NotificationModel notification) async {
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

  Future<void> markAllAsRead({String? customerName}) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead &&
          (customerName == null ||
              (_notifications[i].payload?['customerName'] == customerName))) {
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
    final batch = FirebaseFirestore.instance.batch();
    for (var notification in _notifications) {
      batch.delete(FirebaseFirestore.instance.collection('notifications').doc(notification.id));
    }
    await batch.commit();
    _notifications.clear();
    notifyListeners();
  }
}