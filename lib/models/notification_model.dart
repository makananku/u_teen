import 'dart:math';
import 'package:flutter/material.dart';
import 'order_model.dart';

class NotificationModel {
  final String _id;
  final String _type; // 'order', 'system', 'promo', dll
  final String _title;
  final String _message;
  final DateTime _timestamp;
  final bool _isRead;
  final Map<String, dynamic>? _payload; // Data tambahan

  NotificationModel({
    required String id,
    required String type,
    required String title,
    required String message,
    required DateTime timestamp,
    bool isRead = false,
    Map<String, dynamic>? payload,
  })  : _id = id,
        _type = type,
        _title = title,
        _message = message,
        _timestamp = timestamp,
        _isRead = isRead,
        _payload = payload;

  // Getters
  String get id => _id;
  String get type => _type;
  String get title => _title;
  String get message => _message;
  DateTime get timestamp => _timestamp;
  bool get isRead => _isRead;
  Map<String, dynamic>? get payload => _payload;

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'type': _type,
      'title': _title,
      'message': _message,
      'timestamp': _timestamp.toIso8601String(),
      'isRead': _isRead,
      'payload': _payload,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload']) : null,
    );
  }

  factory NotificationModel.fromOrder(Order order) {
    String title;
    String message;

    switch (order.status) {
      case 'ready':
        title = 'Pesanan Siap Diambil';
        message = 'Pesanan #${order.id} sudah siap diambil di merchant';
        break;
      case 'completed':
        title = 'Pesanan Selesai';
        message = 'Pesanan #${order.id} telah selesai';
        break;
      case 'cancelled':
        title = 'Pesanan Dibatalkan';
        message = 'Pesanan #${order.id} telah dibatalkan';
        if (order.cancellationReason != null) {
          message += '\nAlasan: ${order.cancellationReason}';
        }
        break;
      default:
        title = 'Update Pesanan';
        message = 'Pesanan #${order.id} diperbarui ke status ${order.status}';
    }

    return NotificationModel(
      id: _generateNotificationId(order.id),
      type: 'order',
      title: title,
      message: message,
      timestamp: order.status == 'completed'
          ? order.completedTime ?? DateTime.now()
          : order.status == 'cancelled'
              ? order.cancelledTime ?? DateTime.now()
              : DateTime.now(),
      isRead: false,
      payload: {
        'orderId': order.id,
        'status': order.status,
        'customerName': order.customerName,
      },
    );
  }

  static String _generateNotificationId(String orderId) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomSuffix = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return '${orderId}_$randomSuffix';
  }
}