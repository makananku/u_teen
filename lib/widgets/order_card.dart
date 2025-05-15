import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../providers/ratings_provider.dart';
import 'rating_widget.dart';

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

    final List<Widget> children = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Order #${order.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Chip(
            label: Text(
              order.status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusTextColor(order.status),
              ),
            ),
            backgroundColor: _getStatusColor(order.status),
          ),
        ],
      ),
      const SizedBox(height: 8),
      isSellerView
          ? Text(
              'Customer: ${order.customerName}',
              style: TextStyle(color: Colors.grey[600]),
            )
          : Text(
              'Merchant: ${order.merchantName}',
              style: TextStyle(color: Colors.grey[600]),
            ),
      Text(
        'Ordered: ${DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt)}',
        style: TextStyle(color: Colors.grey[600]),
      ),
      Text(
        'Pickup: ${DateFormat('dd MMM yyyy, HH:mm').format(order.pickupTime)}',
        style: TextStyle(color: Colors.grey[600]),
      ),
      if (order.status == 'completed' && order.completedAt != null)
        Text(
          'Completed: ${DateFormat('dd MMM yyyy, HH:mm').format(order.completedAt!)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      if (order.status == 'ready' && order.readyAt != null)
        Text(
          'Ready: ${DateFormat('dd MMM yyyy, HH:mm').format(order.readyAt!)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      if (order.status == 'cancelled' && order.cancelledAt != null)
        Text(
          'Cancelled: ${DateFormat('dd MMM yyyy, HH:mm').format(order.cancelledAt!)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      if (!isSellerView)
        Text(
          'Paid with ${order.paymentMethod}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      if (order.notes != null && order.notes!.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSellerView ? 'Customer Notes:' : 'Your Notes:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.notes!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
      if (order.status == 'cancelled' && order.cancellationReason != null) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSellerView ? 'Cancellation Reason:' : 'Order Cancelled:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.cancellationReason!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
      if (order.status == 'completed' &&
          (order.foodRating != null || order.appRating != null)) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Rating:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              if (order.foodRating != null)
                Row(
                  children: [
                    const Text('Food: '),
                    ...List.generate(
                      order.foodRating!,
                      (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                    ...List.generate(
                      5 - order.foodRating!,
                      (index) =>
                          const Icon(Icons.star_border, color: Colors.amber, size: 16),
                    ),
                  ],
                ),
              if (order.foodNotes != null && order.foodNotes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Food Notes: ${order.foodNotes}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              if (order.appRating != null)
                Row(
                  children: [
                    const Text('App Experience: '),
                    ...List.generate(
                      order.appRating!,
                      (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                    ...List.generate(
                      5 - order.appRating!,
                      (index) =>
                          const Icon(Icons.star_border, color: Colors.amber, size: 16),
                    ),
                  ],
                ),
              if (order.appNotes != null && order.appNotes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'App Notes: ${order.appNotes}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
            ],
          ),
        ),
      ],
      const Divider(height: 24),
      ...order.items.map((item) => _buildOrderItem(item, currencyFormat)).toList(),
      const Divider(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            currencyFormat.format(order.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ];

    if (isSellerView && (order.status == 'pending' || order.status == 'processing')) {
      children.addAll([
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _markAsReady(context, order),
                child: const Text('MARK AS READY'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _cancelOrder(context, order),
                child: const Text('CANCEL ORDER'),
              ),
            ),
          ],
        ),
      ]);
    }

    if (!isSellerView && order.status == 'ready') {
      children.addAll([
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => RatingDialog(
                order: order,
                onSubmit: (foodRating, appRating, foodNotes, appNotes) {
                  Provider.of<RatingsProvider>(context, listen: false).submitRating(
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
          child: const Text('Confirm Pickup'),
        ),
      ]);
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                width: 50,
                height: 50,
                child: const Icon(Icons.fastfood),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Text('${item.quantity}x'),
          const SizedBox(width: 12),
          Text(currencyFormat.format(item.price)),
        ],
      ),
    );
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green[100]!;
      case 'cancelled':
        return Colors.red[100]!;
      case 'ready':
        return Colors.blue[100]!;
      case 'pending':
      case 'processing':
      default:
        return Colors.orange[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green[800]!;
      case 'cancelled':
        return Colors.red[800]!;
      case 'ready':
        return Colors.blue[800]!;
      case 'pending':
      case 'processing':
      default:
        return Colors.orange[800]!;
    }
  }
}