import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:u_teen/models/order_model.dart';
import '../models/balance_model.dart';
import 'dart:convert';

class BalanceProvider with ChangeNotifier {
  Map<String, Balance> _balances = {}; // Key: merchantEmail
  late final SharedPreferences _prefs;
  bool _isLoading = false;

  BalanceProvider(SharedPreferences prefs) : _prefs = prefs {
    _loadBalance();
  }

  Balance getBalance(String merchantEmail) {
    return _balances[merchantEmail] ?? Balance(amount: 0.0, history: []);
  }

  bool get isLoading => _isLoading;

  Future<void> _loadBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final balancesJson = _prefs.getString('seller_balances');
      if (balancesJson != null) {
        final Map<String, dynamic> balancesMap = json.decode(balancesJson);
        _balances = balancesMap.map((key, value) => 
          MapEntry(key, Balance.fromMap(value)));
      }
    } catch (e) {
      debugPrint('Error loading balances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBalance() async {
    final balancesMap = _balances.map((key, value) => 
      MapEntry(key, value.toMap()));
    await _prefs.setString('seller_balances', json.encode(balancesMap));
  }

  Future<void> addOrderIncome(Order order) async {
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

      await _saveBalance();
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

      await _saveBalance();
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