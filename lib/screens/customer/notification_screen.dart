import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../auth/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customerEmail = authProvider.user?.email ?? '';
    final notifications = notificationProvider.getNotificationsForCustomer(customerEmail);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.getDetailBackground(isDarkMode),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
        ),
        backgroundColor: AppTheme.getCard(isDarkMode),
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppTheme.getTextMedium(isDarkMode)),
        actions: [
          if (notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.done_all, size: 24, color: AppTheme.getPrimaryText(isDarkMode)),
                onPressed: () => notificationProvider.markAllAsRead(customerEmail: customerEmail),
                tooltip: 'Mark all as read',
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isDarkMode)
          : RefreshIndicator(
              color: AppTheme.getButton(isDarkMode),
              onRefresh: () async {
                await notificationProvider.initialize(customerEmail);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification, context, isDarkMode);
                },
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, BuildContext context, bool isDarkMode) {
    final statusColor = notification.payload?['statusColor'] != null
        ? Color(int.parse(notification.payload!['statusColor'], radix: 16))
        : AppTheme.getButton(isDarkMode);

    final isUnread = !notification.isRead;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Provider.of<NotificationProvider>(context, listen: false)
            .markAsRead(notification.id);
        if (notification.payload != null && notification.payload!['orderId'] != null) {
          final orderId = notification.payload!['orderId'];
          debugPrint('Navigating to order details for order ID: $orderId');
          // Tambahkan navigasi ke detail order jika diperlukan
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCard(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isUnread
                ? statusColor.withOpacity(0.3)
                : AppTheme.getDivider(isDarkMode),
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.getTextDark(isDarkMode),
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.getSecondaryText(isDarkMode),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y • h:mm a').format(notification.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                      ),
                      const Spacer(),
                      if (notification.payload?['status'] == 'ready')
                        GestureDetector(
                          onTap: () {
                            // Action for order ready
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'View Order',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      if (notification.payload?['status'] == 'cancelled')
                        GestureDetector(
                          onTap: () {
                            // Action for cancelled order
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Reorder',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animation/empty_notification.json',
                width: 220,
                height: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'No Notifications Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextDark(isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your order updates and promotions will appear here when available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppTheme.getSecondaryText(isDarkMode),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}