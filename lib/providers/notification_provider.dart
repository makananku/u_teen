import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import '../models/order_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  late final SharedPreferences _prefs;
  bool _isLoading = false;

  NotificationProvider(SharedPreferences prefs) : _prefs = prefs {
    _loadNotifications();
  }

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

    try {
      final notificationsJson = _prefs.getString('notifications');
      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications.addAll(decoded.map((item) => NotificationModel.fromMap(item)));
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final notificationsJson =
          json.encode(_notifications.map((n) => n.toMap()).toList());
      await _prefs.setString('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    notifyListeners();
    await _saveNotifications();
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
      notifyListeners();
      await _saveNotifications();
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
      }
    }
    notifyListeners();
    await _saveNotifications();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    await _saveNotifications();
  }
}