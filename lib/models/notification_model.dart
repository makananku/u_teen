// import 'package:flutter/material.dart';

// class NotificationModel {
//   final String id;
//   final String orderId; // Referensi ke pesanan
//   final String message; // Pesan notifikasi
//   final String status; // Status pesanan terkait (cancelled, completed, ready)
//   final DateTime createdAt;
//   bool isRead;

//   NotificationModel({
//     required this.id,
//     required this.orderId,
//     required this.message,
//     required this.status,
//     required this.createdAt,
//     this.isRead = false,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'orderId': orderId,
//       'message': message,
//       'status': status,
//       'createdAt': createdAt.toIso8601String(),
//       'isRead': isRead,
//     };
//   }

//   factory NotificationModel.fromMap(Map<String, dynamic> map) {
//     return NotificationModel(
//       id: map['id'],
//       orderId: map['orderId'],
//       message: map['message'],
//       status: map['status'],
//       createdAt: DateTime.parse(map['createdAt']),
//       isRead: map['isRead'] ?? false,
//     );
//   }
// }