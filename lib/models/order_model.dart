class Order {
  final String id;
  final DateTime orderTime;
  final DateTime pickupTime;
  final List<OrderItem> items;
  final String status;
  final String paymentMethod;
  final String merchantName;
  final String merchantEmail;
  final String customerName;
  final String? cancellationReason;
  final String? notes;
  final DateTime? completedTime;
  final DateTime? cancelledTime;

  Order({
    required this.id,
    required this.orderTime,
    required this.pickupTime,
    required this.items,
    required this.paymentMethod,
    required this.merchantName,
    required this.merchantEmail,
    required this.customerName,
    this.status = 'pending',
    this.cancellationReason,
    this.notes,
    this.completedTime,
    this.cancelledTime,
  });

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderTime': orderTime.toIso8601String(),
      'pickupTime': pickupTime.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
      'paymentMethod': paymentMethod,
      'merchantName': merchantName,
      'merchantEmail': merchantEmail,
      'customerName': customerName,
      'cancellationReason': cancellationReason,
      'notes': notes,
      'completedTime': completedTime?.toIso8601String(),
      'cancelledTime': cancelledTime?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderTime: DateTime.parse(map['orderTime']),
      pickupTime: DateTime.parse(map['pickupTime']),
      items: (map['items'] as List).map((i) => OrderItem.fromMap(i)).toList(),
      paymentMethod: map['paymentMethod'],
      merchantName: map['merchantName'],
      merchantEmail: map['merchantEmail'] ?? '',
      customerName: map['customerName'],
      status: map['status'] ?? 'pending',
      cancellationReason: map['cancellationReason'],
      notes: map['notes'],
      completedTime: map['completedTime'] != null ? DateTime.parse(map['completedTime']) : null,
      cancelledTime: map['cancelledTime'] != null ? DateTime.parse(map['cancelledTime']) : null,
    );
  }
}

class OrderItem {
  final String name;
  final String image;
  final String subtitle;
  final int price;
  final int quantity;
  final String sellerEmail;

  OrderItem({
    required this.name,
    required this.image,
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.sellerEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'subtitle': subtitle,
      'price': price,
      'quantity': quantity,
      'sellerEmail': sellerEmail,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'],
      image: map['image'],
      subtitle: map['subtitle'],
      price: map['price'],
      quantity: map['quantity'],
      sellerEmail: map['sellerEmail'] ?? '',
    );
  }
}