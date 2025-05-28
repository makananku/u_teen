class CartItem {
  final String name;
  final int price;
  final String image;
  final String subtitle;
  final String sellerEmail;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    required this.subtitle,
    required this.sellerEmail,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'subtitle': subtitle,
      'sellerEmail': sellerEmail,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      image: map['image'] ?? '',
      subtitle: map['subtitle'] ?? '',
      sellerEmail: map['sellerEmail'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          subtitle == other.subtitle;

  @override
  int get hashCode => name.hashCode ^ subtitle.hashCode;
}