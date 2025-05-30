class FavoriteItem {
  final String name;
  final String price;
  final String imgBase64; // Renamed from image
  final String? subtitle;

  FavoriteItem({
    required this.name,
    required this.price,
    required this.imgBase64, // Renamed from image
    this.subtitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imgBase64': imgBase64, // Renamed from image
      'subtitle': subtitle,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      imgBase64: map['imgBase64'] ?? map['image'] ?? '', // Support legacy image field
      subtitle: map['subtitle'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imgBase64 == other.imgBase64; // Renamed from image

  @override
  int get hashCode => name.hashCode ^ imgBase64.hashCode; // Renamed from image
}