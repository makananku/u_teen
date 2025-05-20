import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/rating_provider.dart';
import '../utils/order_dialog_utils.dart';
import 'rating/rating_dialog.dart';
import '../providers/theme_notifier.dart';

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
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: isDarkMode ? 0 : 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _getStatusGradient(order.status, isDarkMode),
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
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(
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
                    color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDarkMode
                        ? []
                        : [
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
                            color: isDarkMode ? Colors.grey[400] : Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSellerView
                                ? order.customerName
                                : order.merchantName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
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
                        isDarkMode: isDarkMode,
                      ),
                      _buildTimelineItem(
                        icon: Icons.timer,
                        title: 'Pickup',
                        time: order.pickupTime,
                        isHighlighted: false,
                        isDarkMode: isDarkMode,
                      ),
                      if (order.status == 'completed' && order.completedAt != null)
                        _buildTimelineItem(
                          icon: Icons.check_circle,
                          title: 'Completed',
                          time: order.completedAt!,
                          isHighlighted: true,
                          isDarkMode: isDarkMode,
                        ),
                      if (order.status == 'ready' && order.readyAt != null)
                        _buildTimelineItem(
                          icon: Icons.emoji_food_beverage,
                          title: 'Ready',
                          time: order.readyAt!,
                          isHighlighted: true,
                          isDarkMode: isDarkMode,
                        ),
                      if (order.status == 'cancelled' && order.cancelledAt != null)
                        _buildTimelineItem(
                          icon: Icons.cancel,
                          title: 'Cancelled',
                          time: order.cancelledAt!,
                          isHighlighted: true,
                          isDarkMode: isDarkMode,
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
                                color: isDarkMode ? Colors.grey[400] : Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Paid with ${order.paymentMethod}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
                          color: isDarkMode ? Colors.blue[900]! : Colors.blue[100]!,
                          textColor: isDarkMode ? Colors.blue[200]! : Colors.blue[800]!,
                          isDarkMode: isDarkMode,
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
                          color: isDarkMode ? Colors.red[900]! : Colors.red[100]!,
                          textColor: isDarkMode ? Colors.red[200]! : Colors.red[800]!,
                          isDarkMode: isDarkMode,
                        ),
                      ],

                      // Ratings section
                      if (order.status == 'completed' &&
                          (order.foodRating != null || order.appRating != null)) ...[
                        const SizedBox(height: 12),
                        _buildRatingSection(isDarkMode),
                      ],

                      // Order items
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      ...order.items
                          .map((item) => _buildOrderItem(item, currencyFormat, isDarkMode))
                          .toList(),

                      // Total price
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
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
                  _buildSellerActions(context, isDarkMode),
                if (!isSellerView && order.status == 'ready')
                  _buildCustomerReadyAction(context, isDarkMode),
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
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? Colors.deepOrange
                : (isDarkMode ? Colors.grey[400] : Colors.grey),
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
                    color: isHighlighted
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: isHighlighted
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? Colors.grey[600] : Colors.grey[500]),
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
    required bool isDarkMode,
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

  Widget _buildRatingSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.green[900] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                'Your Rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.green[200] : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.foodRating != null) ...[
            Row(
              children: [
                Text(
                  'Food: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
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
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
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
                Text(
                  'App Experience: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
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
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
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

  Widget _buildOrderItem(OrderItem item, NumberFormat currencyFormat, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              image: DecorationImage(
                image: AssetImage(item.image),
                fit: BoxFit.cover,
                onError: (_, __) => Container(),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.quantity}x',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            currencyFormat.format(item.price),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerActions(BuildContext context, bool isDarkMode) {
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
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isDarkMode ? 0 : 2,
              ),
              onPressed: () => OrderDialogUtils.showMarkAsReadyDialog(context, order),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, size: 20),
              label: const Text('CANCEL'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white : Colors.grey[800],
                side: BorderSide(color: isDarkMode ? Colors.grey[600]! : Colors.grey[800]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => OrderDialogUtils.showCancelOrderDialog(context, order),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReadyAction(BuildContext context, bool isDarkMode) {
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
            elevation: isDarkMode ? 0 : 2,
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

  LinearGradient _getStatusGradient(String status, bool isDarkMode) {
    if (isDarkMode) {
      switch (status) {
        case 'completed':
          return const LinearGradient(
            colors: [Color(0xFF007B37), Color(0xFF3EB872)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'cancelled':
          return const LinearGradient(
            colors: [Color(0xFFB71C1C), Color(0xFFE05450)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'ready':
          return const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'pending':
          return const LinearGradient(
            colors: [Color(0xFFB76D00), Color(0xFFE0A32E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'processing':
          return const LinearGradient(
            colors: [Color(0xFF4A2C9C), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        default:
          return const LinearGradient(
            colors: [Color(0xFF616161), Color(0xFF9E9E9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
      }
    } else {
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
}