import 'dart:ui';

class PaymentMethod {
  final String id;
  final String name;
  final String iconPath;
  final String description;
  final Color? primaryColor;
  final bool requiresPhoneNumber;
  final bool supportsTopUp;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
    this.primaryColor,
    this.requiresPhoneNumber = false,
    this.supportsTopUp = false,
  });
}
