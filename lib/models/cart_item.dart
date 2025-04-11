class CartItem {
  final String name;
  final int price;
  final String image;
  final String subtitle;
  final String sellerEmail; // Add this
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    required this.subtitle,
    required this.sellerEmail,
    this.quantity = 1,
  });

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
