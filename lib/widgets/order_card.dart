import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../providers/rating_provider.dart';
import 'rating/rating_dialog.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isSellerView;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.isSellerView = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _getStatusGradient(order.status),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with order number and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORDER #${order.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Order summary section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant/Customer info
                      Row(
                        children: [
                          Icon(
                            isSellerView ? Icons.person : Icons.store,
                            size: 18,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSellerView
                                ? order.customerName
                                : order.merchantName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Timeline information
                      _buildTimelineItem(
                        icon: Icons.schedule,
                        title: 'Ordered',
                        time: order.createdAt,
                        isHighlighted: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.timer,
                        title: 'Pickup',
                        time: order.pickupTime,
                        isHighlighted: false,
                      ),
                      if (order.status == 'completed' && order.completedAt != null)
                        _buildTimelineItem(
                          icon: Icons.check_circle,
                          title: 'Completed',
                          time: order.completedAt!,
                          isHighlighted: true,
                        ),
                      if (order.status == 'ready' && order.readyAt != null)
                        _buildTimelineItem(
                          icon: Icons.emoji_food_beverage,
                          title: 'Ready',
                          time: order.readyAt!,
                          isHighlighted: true,
                        ),
                      if (order.status == 'cancelled' && order.cancelledAt != null)
                        _buildTimelineItem(
                          icon: Icons.cancel,
                          title: 'Cancelled',
                          time: order.cancelledAt!,
                          isHighlighted: true,
                        ),

                      // Payment method
                      if (!isSellerView)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                _getPaymentMethodIcon(order.paymentMethod),
                                size: 16,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Paid with ${order.paymentMethod}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Notes section
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoBox(
                          icon: Icons.note,
                          title: isSellerView ? 'Customer Notes' : 'Your Notes',
                          content: order.notes!,
                          color: Colors.blue[100]!,
                          textColor: Colors.blue[800]!,
                        ),
                      ],

                      // Cancellation reason
                      if (order.status == 'cancelled' &&
                          order.cancellationReason != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoBox(
                          icon: Icons.warning,
                          title: isSellerView
                              ? 'Cancellation Reason'
                              : 'Order Cancelled',
                          content: order.cancellationReason!,
                          color: Colors.red[100]!,
                          textColor: Colors.red[800]!,
                        ),
                      ],

                      // Ratings section
                      if (order.status == 'completed' &&
                          (order.foodRating != null || order.appRating != null)) ...[
                        const SizedBox(height: 12),
                        _buildRatingSection(),
                      ],

                      // Order items
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      ...order.items
                          .map((item) => _buildOrderItem(item, currencyFormat))
                          .toList(),

                      // Total price
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currencyFormat.format(order.totalPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons
                if (isSellerView &&
                    (order.status == 'pending' || order.status == 'processing'))
                  _buildSellerActions(context),
                if (!isSellerView && order.status == 'ready')
                  _buildCustomerReadyAction(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required DateTime time,
    required bool isHighlighted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? Colors.deepOrange : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isHighlighted ? Colors.black : Colors.grey[600],
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: isHighlighted ? Colors.black : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 8),
              Text(
                'Your Rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.foodRating != null) ...[
            Row(
              children: [
                const Text('Food: ', style: TextStyle(fontSize: 13)),
                const Spacer(),
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < order.foodRating! ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ],
            ),
            if (order.foodNotes != null && order.foodNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '"${order.foodNotes!}"',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
          if (order.appRating != null) ...[
            Row(
              children: [
                const Text('App Experience: ', style: TextStyle(fontSize: 13)),
                const Spacer(),
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < order.appRating! ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ],
            ),
            if (order.appNotes != null && order.appNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '"${order.appNotes!}"',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
              image: DecorationImage(
                image: AssetImage(item.image),
                fit: BoxFit.cover,
                onError: (_, __) => Container(), // Fallback to background color
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.quantity}x',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Text(
            currencyFormat.format(item.price),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 20),
              label: const Text('MARK AS READY'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => _markAsReady(context, order),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, size: 20),
              label: const Text('CANCEL'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _cancelOrder(context, order),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReadyAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_bag, size: 20),
          label: const Text('CONFIRM PICKUP'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => RatingDialog(
                order: order,
                onSubmit: (foodRating, appRating, foodNotes, appNotes) {
                  Provider.of<RatingProvider>(context, listen: false).submitRating(
                    orderId: order.id,
                    foodRating: foodRating,
                    appRating: appRating,
                    foodNotes: foodNotes,
                    appNotes: appNotes,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status) {
      case 'completed':
        return const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF5EFC82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cancelled':
        return const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF867F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ready':
        return const LinearGradient(
          colors: [Color(0xFF2979FF), Color(0xFF448AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFFFA000), Color(0xFFFFC046)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'processing':
        return const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'gopay':
        return Icons.account_balance_wallet;
      case 'ovo':
        return Icons.phone_android;
      case 'dana':
        return Icons.payment;
      case 'credit card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  // Keep your existing _markAsReady, _cancelOrder, and other helper methods
  // They can remain exactly the same as in your original code
  // ...
}

  void _markAsReady(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Confirm Ready',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to mark this order as ready for pickup?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 6,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text('Marking order as ready...'),
                              ],
                            ),
                          ),
                        ),
                      );

                      await Provider.of<OrderProvider>(context, listen: false)
                          .updateOrderStatus(order.id, 'ready');

                      if (context.mounted) {
                        Navigator.pop(context);
                        await _showSuccessAnimation(context);
                      }
                    },
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(color: Colors.white),
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

  void _cancelOrder(BuildContext context, Order order) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Please provide a reason for cancellation:'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Cancellation Reason',
                    hintText: 'E.g. Out of stock, kitchen closed',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('DISCARD'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 6,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Cancelling order...'),
                                ],
                              ),
                            ),
                          ),
                        );

                        await Provider.of<OrderProvider>(context, listen: false)
                            .updateOrderStatus(
                          order.id,
                          'cancelled',
                          reason: reasonController.text,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          await _showCancelledAnimation(context);
                        }
                      },
                      child: const Text(
                        'CONFIRM',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessAnimation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Success!',                
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Order marked as ready'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelledAnimation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Order Cancelled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('The order has been cancelled'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

