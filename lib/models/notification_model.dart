import 'dart:math';
import 'package:flutter/material.dart';
import 'package:u_teen/models/order_model.dart' as order;

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'payload': payload,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload']) : null,
    );
  }

  factory NotificationModel.fromOrder(order.Order order) {
    String title;
    String message;
    Color? statusColor;

    switch (order.status) {
      case 'ready':
        title = 'Order Ready';
        message = 'Order #${order.id} is ready for pickup';
        statusColor = Colors.green;
        break;
      case 'completed':
        title = 'Order Completed';
        message = 'Order #${order.id} has been completed';
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        title = 'Order Cancelled';
        message = 'Order #${order.id} has been cancelled';
        statusColor = Colors.red;
        if (order.cancellationReason != null) {
          message += '\nReason: ${order.cancellationReason}';
        }
        break;
      default:
        title = 'Order Update';
        message = 'Order #${order.id} status updated to ${order.status}';
        statusColor = Colors.orange;
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
        'statusColor': statusColor.value.toRadixString(16),
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