class CartItem {
  final String name;
  final int price;
  final String imgbase64;
  final String subtitle;
  final String sellerEmail;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imgbase64,
    required this.subtitle,
    required this.sellerEmail,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imgbase64': imgbase64,
      'subtitle': subtitle,
      'sellerEmail': sellerEmail,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      imgbase64: map['imgbase64'] ?? '',
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