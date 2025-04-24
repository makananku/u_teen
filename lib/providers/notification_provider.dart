// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/notification_model.dart';
// import '../models/order_model.dart';

// class NotificationProvider with ChangeNotifier {
//   final List<NotificationModel> _notifications = [];
//   late final SharedPreferences _prefs;
//   bool _isSaving = false;

//   NotificationProvider(SharedPreferences prefs) : _prefs = prefs {
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     final notificationsJson = _prefs.getString('notifications');
//     if (notificationsJson != null) {
//       try {
//         final List<dynamic> notificationsMap = json.decode(notificationsJson);
//         _notifications
//             .addAll(notificationsMap.map((map) => NotificationModel.fromMap(map)));
//         notifyListeners();
//       } catch (e) {
//         debugPrint('Error loading notifications: $e');
//       }
//     }
//   }

//   Future<void> _saveNotifications() async {
//     if (_isSaving) return;
//     _isSaving = true;

//     try {
//       final notificationsJson =
//           json.encode(_notifications.map((n) => n.toMap()).toList());
//       await _prefs.setString('notifications', notificationsJson);
//     } catch (e) {
//       debugPrint('Error saving notifications: $e');
//     } finally {
//       _isSaving = false;
//     }
//   }

//   List<NotificationModel> get notifications => List.unmodifiable(_notifications);

//   List<NotificationModel> getNotificationsForCustomer(
//       String customerName, List<Order> orders) {
//     // Filter notifikasi berdasarkan pesanan milik pelanggan
//     final customerOrderIds =
//         orders.where((o) => o.customerName == customerName).map((o) => o.id).toSet();
//     return _notifications
//         .where((n) => customerOrderIds.contains(n.orderId))
//         .toList()
//       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
//   }

//   int getUnreadNotificationCount(String customerName, List<Order> orders) {
//     final customerOrderIds =
//         orders.where((o) => o.customerName == customerName).map((o) => o.id).toSet();
//     return _notifications
//         .where((n) =>
//             customerOrderIds.contains(n.orderId) &&
//             !n.isRead &&
//             ['cancelled', 'completed', 'ready'].contains(n.status))
//         .length;
//   }

//   void addNotification(NotificationModel notification) {
//     _notifications.insert(0, notification);
//     notifyListeners();
//     _saveNotifications();
//   }

//   void markNotificationAsRead(String notificationId) {
//     final index = _notifications.indexWhere((n) => n.id == notificationId);
//     if (index != -1) {
//       _notifications[index] = NotificationModel(
//         id: _notifications[index].id,
//         orderId: _notifications[index].orderId,
//         message: _notifications[index].message,
//         status: _notifications[index].status,
//         createdAt: _notifications[index].createdAt,
//         isRead: true,
//       );
//       notifyListeners();
//       _saveNotifications();
//     }
//   }

//   void markAllNotificationsAsRead(String customerName, List<Order> orders) {
//     final customerOrderIds =
//         orders.where((o) => o.customerName == customerName).map((o) => o.id).toSet();
//     for (var i = 0; i < _notifications.length; i++) {
//       if (customerOrderIds.contains(_notifications[i].orderId) &&
//           ['cancelled', 'completed', 'ready'].contains(_notifications[i].status)) {
//         _notifications[i] = NotificationModel(
//           id: _notifications[i].id,
//           orderId: _notifications[i].orderId,
//           message: _notifications[i].message,
//           status: _notifications[i].status,
//           createdAt: _notifications[i].createdAt,
//           isRead: true,
//         );
//       }
//     }
//     notifyListeners();
//     _saveNotifications();
//   }

//   String _generateNotificationId() {
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     final random = Random();
//     return List.generate(8, (i) => chars[random.nextInt(chars.length)]).join();
//   }

//   // Membuat notifikasi dari pesanan
//   void createNotificationFromOrder(Order order) {
//     String message;
//     switch (order.status) {
//       case 'ready':
//         message = 'Your order from ${order.merchantName} is ready for pickup!';
//         break;
//       case 'completed':
//         message = 'Your order from ${order.merchantName} has been completed!';
//         break;
//       case 'cancelled':
//         message =
//             'Your order from ${order.merchantName} has been cancelled${order.cancellationReason != null ? ': ${order.cancellationReason}' : '.'}';
//         break;
//       default:
//         return; // Jangan buat notifikasi untuk status lain
//     }

//     final notification = NotificationModel(
//       id: _generateNotificationId(),
//       orderId: order.id,
//       message: message,
//       status: order.status,
//       createdAt: DateTime.now(),
//       isRead: false,
//     );
//     addNotification(notification);
//   }
// }