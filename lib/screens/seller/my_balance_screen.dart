import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class SellerBalanceScreen extends StatefulWidget {
  const SellerBalanceScreen({super.key});

  @override
  State<SellerBalanceScreen> createState() => _SellerBalanceScreenState();
}

class _SellerBalanceScreenState extends State<SellerBalanceScreen> {
  PaymentMethod? _selectedMethod;
  final String _userGopayNumber = '0812-3456-7890';
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _selectedMethod = paymentMethods.firstWhere(
      (method) => method.id == 'gopay',
      orElse: () => paymentMethods.first,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateBalance();
    });
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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Theme(
      data: themeNotifier.currentTheme,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: AppTheme.getBackground(isDarkMode),
          appBar: AppBar(
            title: Text(
              'My Balance',
              style: TextStyle(
                color: AppTheme.getPrimaryText(isDarkMode),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.getCard(isDarkMode),
            elevation: 0.5,
            actions: [
              IconButton(
                icon: Icon(Icons.history, color: AppTheme.getPrimaryText(isDarkMode)),
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
                      elevation: isDarkMode ? 0 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: AppTheme.getCard(isDarkMode),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
                                : [Colors.blue[700]!, Colors.blue[400]!],
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
                                  color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Balance Available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              Formatters.currencyFormat.format(_balance),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _selectedMethod != null ? () => _withdrawFunds(context) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.getCard(isDarkMode),
                                foregroundColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: isDarkMode ? 0 : 2,
                              ),
                              child: Text(
                                'Withdraw',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Withdrawal Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPrimaryText(isDarkMode),
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
                    if (_selectedMethod?.id == 'gopay') const Padding(padding: EdgeInsets.only(top: 8)),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        if (paymentMethods.isEmpty) ...[
                          Image.asset('assets/empty_payment.png', height: 150),
                          const SizedBox(height: 16),
                          Text(
                            'No Payment Methods Available',
                            style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
                          ),
                          const SizedBox(height: 20),
                        ],
                        OutlinedButton.icon(
                          onPressed: _addNewPaymentMethod,
                          icon: Icon(Icons.add, color: AppTheme.getAccentPrimaryBlue(isDarkMode)),
                          label: Text(
                            'Add Withdrawal Method',
                            style: TextStyle(color: AppTheme.getAccentPrimaryBlue(isDarkMode)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.getAccentPrimaryBlue(isDarkMode)),
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
      ),
    );
  }

  void _withdrawFunds(BuildContext context) {
    if (_balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Balance is insufficient for withdrawal'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.getSnackBarError(false),
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
        backgroundColor: AppTheme.getSnackBarSuccess(false),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addNewPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add new payment method feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.getButton(false),
      ),
    );
  }
}