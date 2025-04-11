import '../models/payment_method.dart';
import 'package:flutter/material.dart';

final List<PaymentMethod> paymentMethods = [
  PaymentMethod(
    id: 'gopay',
    name: 'GoPay',
    iconPath: 'assets/payment/gopay.png',
    description: 'Instant transfer to your GoPay account',
    primaryColor: const Color(0xFF00AA13),
    requiresPhoneNumber: true,
    supportsTopUp: true,
  ),
  PaymentMethod(
    id: 'ovo',
    name: 'OVO',
    iconPath: 'assets/payment/ovo.png',
    description: 'Fast transfer to your OVO wallet',
    primaryColor: const Color(0xFF4C2A86),
    requiresPhoneNumber: true,
    supportsTopUp: true,
  ),
];
