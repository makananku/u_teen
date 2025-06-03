import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/models/order_model.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class OrderDialogUtils {
  static void showMarkAsReadyDialog(BuildContext context, Order order) {
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.getCard(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppTheme.getSnackBarSuccess(isDarkMode), size: 48),
              const SizedBox(height: 16),
              Text(
                'Confirm Ready',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to mark this order as ready for pickup?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getSnackBarSuccess(isDarkMode),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: isDarkMode ? 0 : 2,
                    ),
                    onPressed: () async {
                      Navigator.pop(context); // Close confirmation dialog
                      await _processOrderStatusUpdate(
                        context: context,
                        order: order,
                        newStatus: 'ready',
                        successMessage: 'Order marked as ready',
                        isDarkMode: isDarkMode,
                      );
                    },
                    child: Text(
                      'CONFIRM',
                      style: TextStyle(color: AppTheme.getPrimaryText(!isDarkMode)),
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

  static void showCancelOrderDialog(BuildContext context, Order order) {
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.getCard(isDarkMode),
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
                Icon(Icons.cancel, color: AppTheme.getSnackBarError(isDarkMode), size: 48),
                const SizedBox(height: 16),
                Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide a reason for cancellation:',
                  style: TextStyle(
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Cancellation Reason',
                    hintText: 'E.g. Out of stock, kitchen closed',
                    labelStyle: TextStyle(
                      color: AppTheme.getSecondaryText(isDarkMode),
                    ),
                    hintStyle: TextStyle(
                      color: AppTheme.getSecondaryText(isDarkMode),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.getButton(isDarkMode),
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.getPrimaryText(isDarkMode),
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
                      child: Text(
                        'DISCARD',
                        style: TextStyle(
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: isDarkMode ? 0 : 2,
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        Navigator.pop(context); // Close confirmation dialog
                        await _processOrderStatusUpdate(
                          context: context,
                          order: order,
                          newStatus: 'cancelled',
                          reason: reasonController.text,
                          successMessage: 'The order has been cancelled',
                          isDarkMode: isDarkMode,
                        );
                      },
                      child: Text(
                        'CONFIRM',
                        style: TextStyle(color: AppTheme.getPrimaryText(!isDarkMode)),
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

  static Future<void> _processOrderStatusUpdate({
    required BuildContext context,
    required Order order,
    required String newStatus,
    String? reason,
    required String successMessage,
    required bool isDarkMode,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button during loading
        child: Dialog(
          backgroundColor: AppTheme.getCard(isDarkMode),
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
                      AppTheme.getSnackBarSuccess(isDarkMode),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  newStatus == 'ready' ? 'Marking order as ready...' : 'Cancelling order...',
                  style: TextStyle(
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Process the update with a timeout
    try {
      await Provider.of<OrderProvider>(context, listen: false)
          .updateOrderStatus(order.id, newStatus, reason: reason)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Operation timed out');
      });

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        await _showSuccessDialog(context, newStatus, successMessage, isDarkMode);
      }
    } catch (e) {
      debugPrint('OrderDialogUtils: Error updating order status: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        await _showErrorDialog(context, 'Failed to update order: $e', isDarkMode);
      }
    }
  }

  static Future<void> _showSuccessDialog(
      BuildContext context, String status, String message, bool isDarkMode) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.getCard(isDarkMode),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == 'ready' ? Icons.check_circle : Icons.cancel,
                color: status == 'ready'
                    ? AppTheme.getSnackBarSuccess(isDarkMode)
                    : AppTheme.getSnackBarError(isDarkMode),
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                status == 'ready' ? 'Success!' : 'Order Cancelled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'ready'
                      ? AppTheme.getSnackBarSuccess(isDarkMode)
                      : AppTheme.getSnackBarError(isDarkMode),
                  foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: isDarkMode ? 0 : 2,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _showErrorDialog(BuildContext context, String message, bool isDarkMode) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.getCard(isDarkMode),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: AppTheme.getSnackBarError(isDarkMode), size: 60),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                  foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: isDarkMode ? 0 : 2,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}