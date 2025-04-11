class Product {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String imgUrl;
  final String price;
  final String sellerEmail;

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.imgUrl,
    required this.price,
    required this.sellerEmail, required String ,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      time: map['time'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
      price: map['price'] ?? '',
      sellerEmail: map['sellerEmail'] ?? '', String: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'imgUrl': imgUrl,
      'price': price,
      'sellerEmail': sellerEmail,
    };
  }
}