class Balance {
  final double amount;
  final List<BalanceHistory> history;

  Balance({required this.amount, this.history = const []});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'history': history.map((h) => h.toMap()).toList(),
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
      amount: map['amount']?.toDouble() ?? 0.0,
      history: map['history'] != null
          ? (map['history'] as List)
              .map((h) => BalanceHistory.fromMap(h))
              .toList()
          : [],
    );
  }
}

class BalanceHistory {
  final String id;
  final DateTime date;
  final String type; // 'income' or 'withdraw'
  final double amount;
  final String description;
  final String? orderId;
  final String? paymentMethod;

  BalanceHistory({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    this.orderId,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'description': description,
      'orderId': orderId,
      'paymentMethod': paymentMethod,
    };
  }

  factory BalanceHistory.fromMap(Map<String, dynamic> map) {
    return BalanceHistory(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      orderId: map['orderId'],
      paymentMethod: map['paymentMethod'],
    );
  }
}