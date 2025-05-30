import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String imgBase64;
  final String time;
  final String tenantName;
  final String sellerEmail;
  final String category;
  final bool isActive;

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imgBase64,
    required this.time,
    required this.tenantName,
    required this.sellerEmail,
    required this.category,
    required this.isActive,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      price: data['price'] ?? '',
      imgBase64: data['imgBase64'] ?? '',
      time: data['time'] ?? '',
      tenantName: data['tenantName'] ?? '',
      sellerEmail: data['sellerEmail'] ?? '',
      category: data['category'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      price: data['price'] ?? '',
      imgBase64: data['imgBase64'] ?? '',
      time: data['time'] ?? '',
      tenantName: data['tenantName'] ?? '',
      sellerEmail: data['sellerEmail'] ?? '',
      category: data['category'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'imgBase64': imgBase64,
      'time': time,
      'tenantName': tenantName,
      'sellerEmail': sellerEmail,
      'isActive': isActive,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? price,
    String? imgBase64,
    String? time,
    String? tenantName,
    String? sellerEmail,
    String? category, // Added missing category parameter
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      imgBase64: imgBase64 ?? this.imgBase64,
      time: time ?? this.time,
      tenantName: tenantName ?? this.tenantName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      category: category ?? this.category, // Fixed to use category instead of sellerEmail
      isActive: isActive ?? this.isActive,
    );
  }
}