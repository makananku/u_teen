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
  final int? _foodRating;
  final int? _appRating;
  final String? _foodNotes;
  final String? _appNotes;
  final DateTime createdAt;
  final DateTime? readyAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  Order({
    required this.id,
    required this.orderTime,
    required this.pickupTime,
    required this.items,
    required this.paymentMethod,
    required this.merchantName,
    required this.merchantEmail,
    required this.customerName,
    required this.createdAt,
    required this.readyAt,
    required this.completedAt,
    required this.cancelledAt,
    this.status = 'pending',
    this.cancellationReason,
    this.notes,
    this.completedTime,
    this.cancelledTime,
    int? foodRating,
    int? appRating,
    String? foodNotes,
    String? appNotes,
  })  : _foodRating = foodRating,
        _appRating = appRating,
        _foodNotes = foodNotes,
        _appNotes = appNotes;

  int? get foodRating => _foodRating;
  int? get appRating => _appRating;
  String? get foodNotes => _foodNotes;
  String? get appNotes => _appNotes;

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
      'foodRating': _foodRating,
      'appRating': _appRating,
      'foodNotes': _foodNotes,
      'appNotes': _appNotes,
      'createdAt': createdAt.toIso8601String(),
      'readyAt': readyAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      orderTime: DateTime.parse(map['orderTime'] ?? DateTime.now().toIso8601String()),
      pickupTime: DateTime.parse(map['pickupTime'] ?? DateTime.now().toIso8601String()),
      items: map['items'] != null
          ? (map['items'] as List).map((i) => OrderItem.fromMap(i)).toList()
          : [],
      paymentMethod: map['paymentMethod'] ?? '',
      merchantName: map['merchantName'] ?? '',
      merchantEmail: map['merchantEmail'] ?? '',
      customerName: map['customerName'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      readyAt: map['readyAt'] != null ? DateTime.parse(map['readyAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      cancelledAt: map['cancelledAt'] != null ? DateTime.parse(map['cancelledAt']) : null,
      status: map['status'] ?? 'pending',
      cancellationReason: map['cancellationReason'],
      notes: map['notes'],
      completedTime:
          map['completedTime'] != null ? DateTime.parse(map['completedTime']) : null,
      cancelledTime:
          map['cancelledTime'] != null ? DateTime.parse(map['cancelledTime']) : null,
      foodRating: map['foodRating'],
      appRating: map['appRating'],
      foodNotes: map['foodNotes'],
      appNotes: map['appNotes'],
    );
  }

  Order copyWith({
    String? id,
    DateTime? orderTime,
    DateTime? pickupTime,
    List<OrderItem>? items,
    String? status,
    String? paymentMethod,
    String? merchantName,
    String? merchantEmail,
    String? customerName,
    String? cancellationReason,
    String? notes,
    DateTime? completedTime,
    DateTime? cancelledTime,
    int? foodRating,
    int? appRating,
    String? foodNotes,
    String? appNotes,
    DateTime? createdAt,
    DateTime? readyAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderTime: orderTime ?? this.orderTime,
      pickupTime: pickupTime ?? this.pickupTime,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchantName: merchantName ?? this.merchantName,
      merchantEmail: merchantEmail ?? this.merchantEmail,
      customerName: customerName ?? this.customerName,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
      completedTime: completedTime ?? this.completedTime,
      cancelledTime: cancelledTime ?? this.cancelledTime,
      foodRating: foodRating ?? this.foodRating,
      appRating: appRating ?? this.appRating,
      foodNotes: foodNotes ?? this.foodNotes,
      appNotes: appNotes ?? this.appNotes,
      createdAt: createdAt ?? this.createdAt,
      readyAt: readyAt ?? this.readyAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}

class OrderItem {
  final String name;
  final String imgBase64; // Renamed from image
  final String subtitle;
  final int price;
  final int quantity;
  final String sellerEmail;

  OrderItem({
    required this.name,
    required this.imgBase64, // Renamed from image
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.sellerEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imgBase64': imgBase64, // Renamed from image
      'subtitle': subtitle,
      'price': price,
      'quantity': quantity,
      'sellerEmail': sellerEmail,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      imgBase64: map['imgBase64'] ?? map['image'] ?? '', // Support legacy image field
      subtitle: map['subtitle'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
      sellerEmail: map['sellerEmail'] ?? '',
    );
  }

  OrderItem copyWith({
    String? name,
    String? imgBase64, // Renamed from image
    String? subtitle,
    int? price,
    int? quantity,
    String? sellerEmail,
  }) {
    return OrderItem(
      name: name ?? this.name,
      imgBase64: imgBase64 ?? this.imgBase64, // Renamed from image
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sellerEmail: sellerEmail ?? this.sellerEmail,
    );
  }
}