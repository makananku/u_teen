import 'package:flutter/foundation.dart';

class FavoriteItem {
  final String name;
  final String price;
  final String imgBase64;
  final String? subtitle;

  FavoriteItem({
    required this.name,
    required this.price,
    required String imgBase64, // Renamed from image
    this.subtitle,
  }) : imgBase64 = imgBase64.isNotEmpty ? imgBase64 : '' {
    if (imgBase64.isEmpty) {
      debugPrint('FavoriteItem: imgBase64 is empty for $name');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imgBase64': imgBase64,
      'subtitle': subtitle,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    final imgBase64 = map['imgBase64'] ?? map['image'] ?? '';
    if (imgBase64.isEmpty) {
      debugPrint('FavoriteItem.fromMap: imgBase64 is empty for ${map['name']}');
    }
    return FavoriteItem(
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      imgBase64: imgBase64,
      subtitle: map['subtitle'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imgBase64 == other.imgBase64;

  @override
  int get hashCode => name.hashCode ^ imgBase64.hashCode;
}