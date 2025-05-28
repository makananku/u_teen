import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/models/payment_method.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'package:u_teen/utils/thousand_separator_formatter.dart';
import 'package:u_teen/utils/formatters.dart';
import 'package:u_teen/widgets/withdraw/quick_amount_button.dart';

class WithdrawalDialog extends StatefulWidget {
  final int balance;
  final PaymentMethod selectedMethod;
  final String userGopayNumber;
  final Function(double) onWithdraw;

  const WithdrawalDialog({
    super.key,
    required this.balance,
    required this.selectedMethod,
    required this.userGopayNumber,
    required this.onWithdraw,
  });

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  late double _withdrawalAmount;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _withdrawalAmount = widget.balance.toDouble();
    _amountController = TextEditingController(
      text: Formatters.decimalFormat.format(_withdrawalAmount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppTheme.getCard(isDarkMode),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.getAccentPrimaryBlue(isDarkMode).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 32,
                      color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Withdraw Funds',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available Balance: ${Formatters.currencyFormat.format(widget.balance)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getSecondaryText(isDarkMode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Withdrawal Amount',
                  prefixText: 'Rp ',
                  labelStyle: TextStyle(
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.getSecondaryText(isDarkMode),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.getCard(isDarkMode),
                ),
                inputFormatters: [
                  ThousandSeparatorInputFormatter(),
                ],
                controller: _amountController,
                style: TextStyle(
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value.replaceAll('.', '')) ?? 0;
                  setState(() {
                    _withdrawalAmount =
                        parsed > widget.balance ? widget.balance.toDouble() : parsed;
                    _amountController.text = Formatters.decimalFormat.format(_withdrawalAmount);
                    _amountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _amountController.text.length),
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickAmountButton(
                    label: '25%',
                    onTap: () {
                      setState(() {
                        _withdrawalAmount = widget.balance * 0.25;
                        _amountController.text = Formatters.decimalFormat.format(_withdrawalAmount);
                        _amountController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  QuickAmountButton(
                    label: '50%',
                    onTap: () {
                      setState(() {
                        _withdrawalAmount = widget.balance * 0.5;
                        _amountController.text = Formatters.decimalFormat.format(_withdrawalAmount);
                        _amountController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  QuickAmountButton(
                    label: '75%',
                    onTap: () {
                      setState(() {
                        _withdrawalAmount = widget.balance * 0.75;
                        _amountController.text = Formatters.decimalFormat.format(_withdrawalAmount);
                        _amountController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  QuickAmountButton(
                    label: '100%',
                    onTap: () {
                      setState(() {
                        _withdrawalAmount = widget.balance.toDouble();
                        _amountController.text = Formatters.decimalFormat.format(_withdrawalAmount);
                        _amountController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCard(isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdraw to',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.getCard(isDarkMode),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.3),
                            ),
                          ),
                          child: Image.asset(
                            widget.selectedMethod.iconPath,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.selectedMethod.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getPrimaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.userGopayNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                        foregroundColor: AppTheme.getPrimaryText(isDarkMode),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.getPrimaryText(isDarkMode),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _withdrawalAmount <= 0
                          ? null
                          : () {
                              Navigator.pop(context);
                              widget.onWithdraw(_withdrawalAmount);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isDarkMode ? 0 : 2,
                        foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}