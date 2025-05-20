import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/models/payment_method.dart';
import 'package:u_teen/data/payment_methods_data.dart';
import 'package:u_teen/screens/seller/transaction_history_screen.dart';
import 'package:u_teen/widgets/withdraw/withdrawal_dialog.dart';
import 'package:u_teen/widgets/payment_method_card.dart';
import 'package:u_teen/widgets/seller/custom_bottom_navigation.dart';
import 'package:flutter/services.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/utils/formatters.dart';

class SellerBalanceScreen extends StatefulWidget {
  const SellerBalanceScreen({super.key});

  @override
  State<SellerBalanceScreen> createState() => _SellerBalanceScreenState();
}

class _SellerBalanceScreenState extends State<SellerBalanceScreen> {
  PaymentMethod? _selectedMethod;
  final String _userGopayNumber = '0812-3456-7890'; // TODO: Move to AuthProvider
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _selectedMethod = paymentMethods.firstWhere(
      (method) => method.id == 'gopay',
      orElse: () => paymentMethods.first,
    );
    _calculateBalance();
  }

  void _calculateBalance() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sellerEmail = authProvider.user?.email ?? '';

    setState(() {
      _balance = orderProvider.getAvailableBalanceForMerchant(sellerEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'My Balance',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.black),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionHistoryScreen(),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[700]!, Colors.blue[400]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white70,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Balance Available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            Formatters.currencyFormat.format(_balance),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                _selectedMethod != null
                                    ? () => _withdrawFunds(context)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Withdraw',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Withdrawal Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: paymentMethods.map((method) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PaymentMethodCard(
                          method: method,
                          isSelected: _selectedMethod?.id == method.id,
                          onTap: () {
                            setState(() => _selectedMethod = method);
                            HapticFeedback.lightImpact();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedMethod?.id == 'gopay')
                    Padding(padding: const EdgeInsets.only(top: 8)),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      if (paymentMethods.isEmpty) ...[
                        Image.asset('assets/empty_payment.png', height: 150),
                        SizedBox(height: 16),
                        Text(
                          'No Payment Methods Available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                      ],
                      OutlinedButton.icon(
                        onPressed: _addNewPaymentMethod,
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label: const Text(
                          'Add Withdrawal Method',
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: SellerCustomBottomNavigation(
                selectedIndex: NavIndices.balance,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _withdrawFunds(BuildContext context) {
    if (_balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Balance is insufficient for withdrawal'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final sellerEmail = authProvider.user?.email ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawalDialog(
        balance: _balance,
        selectedMethod: _selectedMethod!,
        userGopayNumber: _userGopayNumber,
        onWithdraw: (amount) async {
          await orderProvider.addWithdrawal(
            merchantEmail: sellerEmail,
            amount: amount,
            method: _selectedMethod!.name,
          );
          _showWithdrawalSuccess(amount);
          _calculateBalance();
        },
      ),
    );
  }

  void _showWithdrawalSuccess(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Withdrawal Successful!'),
                  Text(
                    '${Formatters.currencyFormat.format(amount)} to ${_selectedMethod!.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWithdrawalError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Withdrawal failed. Please try again.'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addNewPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new payment method feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}