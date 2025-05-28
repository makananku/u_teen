import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_teen/models/order_model.dart' as my_orders;
import '../models/balance_model.dart';

class BalanceProvider with ChangeNotifier {
  Map<String, Balance> _balances = {};
  bool _isLoading = false;

  Balance getBalance(String merchantEmail) {
    return _balances[merchantEmail] ?? Balance(amount: 0.0, history: []);
  }

  bool get isLoading => _isLoading;

  Future<void> _loadBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('balances').get();
      _balances = {
        for (var doc in snapshot.docs)
          doc.id: Balance.fromMap(doc.data())
      };
    } catch (e) {
      debugPrint('Error loading balances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBalance(String merchantEmail) async {
    if (!_balances.containsKey(merchantEmail)) return;
    try {
      await FirebaseFirestore.instance
          .collection('balances')
          .doc(merchantEmail)
          .set(_balances[merchantEmail]!.toMap());
    } catch (e) {
      debugPrint('Error saving balance: $e');
    }
  }

  Future<void> addOrderIncome(my_orders.Order order) async {
    _isLoading = true;
    notifyListeners();

    try {
      final merchantEmail = order.merchantEmail;
      if (merchantEmail.isEmpty) return;

      if (!_balances.containsKey(merchantEmail)) {
        _balances[merchantEmail] = Balance(amount: 0.0, history: []);
      }

      final currentBalance = _balances[merchantEmail]!;
      final newAmount = currentBalance.amount + order.totalPrice;

      final history = BalanceHistory(
        id: 'income_${order.id}',
        date: DateTime.now(),
        type: 'income',
        amount: order.totalPrice,
        description: 'Income from order #${order.id}',
        orderId: order.id,
      );

      _balances[merchantEmail] = Balance(
        amount: newAmount,
        history: [...currentBalance.history, history],
      );

      await _saveBalance(merchantEmail);
    } catch (e) {
      debugPrint('Error adding order income: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> withdraw(String merchantEmail, double amount, String paymentMethod) async {
    if (!_balances.containsKey(merchantEmail) || amount > _balances[merchantEmail]!.amount) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final currentBalance = _balances[merchantEmail]!;
      final newAmount = currentBalance.amount - amount;

      final history = BalanceHistory(
        id: 'withdraw_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        type: 'withdraw',
        amount: amount,
        description: 'Withdraw to $paymentMethod',
        paymentMethod: paymentMethod,
      );

      _balances[merchantEmail] = Balance(
        amount: newAmount,
        history: [...currentBalance.history, history],
      );

      await _saveBalance(merchantEmail);
      return true;
    } catch (e) {
      debugPrint('Error during withdraw: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}