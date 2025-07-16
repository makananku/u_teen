import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/widgets/order_card.dart';
import 'package:u_teen/widgets/seller/empty_state_widget.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'package:intl/intl.dart';

class OnProcessScreen extends StatefulWidget {
  const OnProcessScreen({super.key});

  @override
  State<OnProcessScreen> createState() => _OnProcessScreenState();
}

class _OnProcessScreenState extends State<OnProcessScreen> {
  final Map<String, bool> _expandedOrders = {};

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Theme(
      data: themeNotifier.currentTheme,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDarkMode),
        appBar: AppBar(
          backgroundColor: AppTheme.getCard(isDarkMode),
          title: Text(
            'Processing Orders',
            style: TextStyle(
              color: AppTheme.getPrimaryText(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: isDarkMode ? 0 : 0.5,
        ),
        body: _buildOrderList(context),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final sellerEmail = authProvider.user?.email ?? '';
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    // Filter orders by seller email and processing status
    final processingOrders =
        orderProvider.orders
            .where(
              (order) =>
                  order.merchantEmail == sellerEmail &&
                  (order.status == 'pending' ||
                      order.status == 'processing' ||
                      order.status == 'ready'),
            )
            .toList();

    // Sort orders: pending > processing > ready
    processingOrders.sort((a, b) {
      const statusPriority = {'pending': 1, 'processing': 2, 'ready': 3};
      return statusPriority[a.status]!.compareTo(statusPriority[b.status]!);
    });

    if (processingOrders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.hourglass_empty,
        message: 'No orders currently processing',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: processingOrders.length,
      itemBuilder: (context, index) {
        final order = processingOrders[index];
        final isExpanded = _expandedOrders[order.id] ?? false;

        return Column(
          children: [
            // Compact order item
            InkWell(
              onTap: () {
                setState(() {
                  _expandedOrders[order.id] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      isDarkMode
                          ? []
                          : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                ),
                child: Row(
                  children: [
                    // Status indicator
                    Container(
                      width: 8,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status, isDarkMode),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Order info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER #${order.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.items.length} items • ${_formatCurrency(order.totalPrice.round())}',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          order.status,
                          isDarkMode,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order.status, isDarkMode),
                        ),
                      ),
                    ),
                    // Expand/collapse icon
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            // Expanded order card
            if (isExpanded) ...[
              const SizedBox(height: 8),
              OrderCard(order: order, isSellerView: true),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status) {
      case 'completed':
        return isDarkMode ? const Color(0xFF3EB872) : const Color(0xFF00C853);
      case 'cancelled':
        return isDarkMode ? const Color(0xFFE05450) : const Color(0xFFFF5252);
      case 'ready':
        return isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFF2979FF);
      case 'pending':
        return isDarkMode ? const Color(0xFFE0A32E) : const Color(0xFFFFA000);
      case 'processing':
        return isDarkMode ? const Color(0xFF7E57C2) : const Color(0xFF7C4DFF);
      default:
        return isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF9E9E9E);
    }
  }

  String _formatCurrency(int amount) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount);
  }
}
