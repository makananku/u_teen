import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../models/payment_method.dart';
import '../../data/payment_methods_data.dart';
import '../../widgets/payment_method_card.dart';
import '../../widgets/customer/time_picker_widget.dart';
import '../../widgets/customer/notes_field.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'payment_success_screen.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/cart_item.dart';
import '../../models/order_model.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> items;
  final int totalPrice;

  const PaymentScreen({Key? key, required this.items, required this.totalPrice})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPaymentMethod;
  DateTime pickupTime = DateTime.now().add(const Duration(hours: 1));
  String notes = '';
  String phoneNumber = '';
  bool isProcessing = false;
  bool showPhoneInput = false;
  bool isTimeValid = true;
  String? timeErrorMessage;
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _formKey = GlobalKey<FormState>();

  Color _getBorderColor(bool isDarkMode) {
    if (selectedPaymentMethod == null) return AppTheme.getTextGrey(isDarkMode);
    final method = paymentMethods.firstWhere(
      (m) => m.id == selectedPaymentMethod,
      orElse: () => PaymentMethod(id: '', name: '', iconPath: '', description: ''),
    );
    return method.primaryColor ?? AppTheme.getButton(isDarkMode);
  }

  String? _getSellerEmailFromItems() {
    if (widget.items.isEmpty) return null;
    return widget.items.first.sellerEmail;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _validateInitialTime();
    });
  }

  void _validateInitialTime() {
    final now = DateTime.now();
    final isValid = !pickupTime.isBefore(now) &&
        pickupTime.hour >= 8 &&
        pickupTime.hour < 17;
    setState(() {
      isTimeValid = isValid;
      timeErrorMessage = isValid
          ? null
          : 'Pickup time cannot be in the past or outside 08:00 AM - 05:00 PM';
    });
  }

  @override
  Widget build(BuildContext context) {
    final merchantName = widget.items.isNotEmpty ? widget.items.first.subtitle : 'Unknown Merchant';
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.getCard(isDarkMode),
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(
            color: AppTheme.getPrimaryText(isDarkMode),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.getCard(isDarkMode),
        foregroundColor: AppTheme.getPrimaryText(isDarkMode),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppTheme.getPrimaryText(isDarkMode)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(merchantName, isDarkMode),
                const SizedBox(height: 24),
                TimePickerWidget(
                  onTimeSelected: (time) => setState(() => pickupTime = time),
                  onValidationChanged: (isValid, errorMessage) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        isTimeValid = isValid;
                        timeErrorMessage = errorMessage;
                      });
                    });
                  },
                ),
                const SizedBox(height: 24),
                _buildPaymentMethodSelector(isDarkMode),
                const SizedBox(height: 24),
                NotesField(
                  onNotesChanged: (value) => setState(() => notes = value),
                ),
                const SizedBox(height: 32),
                _buildPlaceOrderButton(context, isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(String merchantName, bool isDarkMode) {
    return Card(
      color: AppTheme.getCard(isDarkMode),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              merchantName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppTheme.getTextGrey(isDarkMode)),
                const SizedBox(width: 8),
                Text(
                  'Order for',
                  style: TextStyle(color: AppTheme.getTextGrey(isDarkMode)),
                ),
                const SizedBox(width: 4),
                Text(
                  'Today, ${DateFormat('hh:mm a').format(pickupTime)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: AppTheme.getDivider(isDarkMode)),
            ...widget.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${item.name} (${item.quantity}x)',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
                      ),
                    ),
                    Text(
                      '${currencyFormat.format(item.price)} x ${item.quantity}',
                      style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 24, color: AppTheme.getDivider(isDarkMode)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
                Text(
                  currencyFormat.format(widget.totalPrice),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 12),
        ...paymentMethods.map(
          (method) => Column(
            children: [
              PaymentMethodCard(
                method: method,
                isSelected: selectedPaymentMethod == method.id,
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = method.id;
                    showPhoneInput = method.requiresPhoneNumber;
                    if (!method.requiresPhoneNumber) phoneNumber = '';
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing || !isTimeValid || selectedPaymentMethod == null
            ? null
            : () => _processPayment(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isProcessing || !isTimeValid || selectedPaymentMethod == null
              ? AppTheme.getTextGrey(isDarkMode)
              : _getBorderColor(isDarkMode),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: isProcessing ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'Place Order',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getPrimaryText(!isDarkMode),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isProcessing)
              SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.getPrimaryText(!isDarkMode),
                  strokeWidth: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => isProcessing = true);

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final sellerEmail = widget.items.isNotEmpty ? widget.items.first.sellerEmail : null;

      if (sellerEmail == null) {
        throw Exception('Seller information not available');
      }

      final merchantName = widget.items.isNotEmpty ? widget.items.first.subtitle : 'Unknown Merchant';
      final customerName = authProvider.user?.name ?? 'Customer';

      final newOrder = Order(
        id: _generateOrderId(),
        orderTime: DateTime.now(),
        createdAt: DateTime.now(),
        pickupTime: pickupTime,
        readyAt: null,
        completedAt: null,
        cancelledAt: null,
        items: widget.items
            .map(
              (item) => OrderItem(
                name: item.name,
                subtitle: item.subtitle,
                price: item.price,
                quantity: item.quantity,
                sellerEmail: item.sellerEmail,
                imgBase64: item.imgBase64
              ),
            )
            .toList(),
        paymentMethod: paymentMethods.firstWhere((m) => m.id == selectedPaymentMethod).name,
        merchantName: merchantName,
        merchantEmail: sellerEmail,
        customerName: customerName,
        notes: notes.isNotEmpty ? notes : null,
      );

      await orderProvider.addOrder(newOrder);
      cartProvider.clearCart();

      debugPrint('Order sent to seller: $sellerEmail');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(order: newOrder),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  String _generateOrderId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}