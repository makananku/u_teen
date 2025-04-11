import 'dart:convert';
class FavoriteItem {
  final String name;
  final String price;
  final String image;
  final String? subtitle;

  FavoriteItem({
    required this.name,
    required this.price,
    required this.image,
    this.subtitle,
  });

  // Convert to JSON
  String toJson() {
    return '{"name":"$name","price":"$price","image":"$image","subtitle":"${subtitle ?? ''}"}';
  }

  // Create from JSON
  factory FavoriteItem.fromJson(String json) {
    final map = jsonDecode(json);
    return FavoriteItem(
      name: map['name'],
      price: map['price'],
      image: map['image'],
      subtitle: map['subtitle'] == '' ? null : map['subtitle'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          image == other.image;

  @override
  int get hashCode => name.hashCode ^ image.hashCode;
}