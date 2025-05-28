import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/providers/theme_notifier.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryScreen> {
  String selectedTab = 'All';
  bool _isLoading = false;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    setState(() => _isLoading = true);

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sellerEmail = authProvider.user?.email ?? '';

    final allTransactions = orderProvider.getTransactionsForMerchant(sellerEmail);

    transactions = allTransactions.map((order) {
      final isWithdrawal = order.customerName == 'Withdrawal';
      return {
        'id': order.id,
        'title': isWithdrawal
            ? 'Withdrawal to ${order.paymentMethod}'
            : 'Payment by ${order.customerName}',
        'date': isWithdrawal ? order.orderTime : (order.completedTime ?? order.orderTime),
        'amount': order.totalPrice,
        'type': isWithdrawal ? 'Money Out' : 'Money In',
        'status': isWithdrawal
            ? (order.status == 'processed' ? 'Processed' : 'Completed')
            : (order.status == 'completed' ? 'Completed' : 'Processing'),
        'order': order,
      };
    }).toList();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          final isDarkMode = themeNotifier.isDarkMode;
          final filteredTransactions = transactions.where((transaction) {
            return selectedTab == 'All' || transaction['type'] == selectedTab;
          }).toList();

          return Theme(
            data: themeNotifier.currentTheme,
            child: Scaffold(
              backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
              appBar: AppBar(
                title: Text(
                  'Transaction History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
                          : [Colors.blue[700]!, Colors.blue[400]!],
                    ),
                  ),
                ),
                elevation: 0,
              ),
              body: Column(
                children: [
                  _buildSummaryCard(isDarkMode),
                  _buildTabBar(isDarkMode),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode ? Colors.white : Colors.blue,
                              ),
                            ),
                          )
                        : filteredTransactions.isEmpty
                            ? _buildEmptyState(isDarkMode)
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 8),
                                itemCount: filteredTransactions.length,
                                itemBuilder: (context, index) {
                                  return _buildTransactionCard(
                                    filteredTransactions[index],
                                    isDarkMode,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(bool isDarkMode) {
    final totalIn = transactions
        .where((t) => t['type'] == 'Money In')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    final totalOut = transactions
        .where((t) => t['type'] == 'Money Out')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
              : [Colors.blue[600]!, Colors.blue[400]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            'Transaction Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total In',
                formatter.format(totalIn.round()),
              ),
              _buildSummaryItem(
                'Total Out',
                formatter.format(totalOut.round()),
              ),
              _buildSummaryItem(
                'Balance',
                formatter.format((totalIn - totalOut).round()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabButton('All', Icons.list_alt, isDarkMode),
          _buildTabButton('Money In', Icons.arrow_downward, isDarkMode),
          _buildTabButton('Money Out', Icons.arrow_upward, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, IconData icon, bool isDarkMode) {
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.blue),
              ),
              const SizedBox(width: 6),
              Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.blue),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, bool isDarkMode) {
    final isMoneyIn = transaction['type'] == 'Money In';
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');
    final amount = transaction['amount'] as double;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isDarkMode ? 0 : 1,
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(transaction, isDarkMode),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMoneyIn
                      ? (isDarkMode ? Colors.green[900] : Colors.green[50])
                      : (isDarkMode ? Colors.red[900] : Colors.red[50]),
                ),
                child: Icon(
                  isMoneyIn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isMoneyIn ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(transaction['date']),
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isMoneyIn ? '+' : '-'} ${formatter.format(amount.round())}',
                    style: TextStyle(
                      color: isMoneyIn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      transaction['status'],
                      style: TextStyle(
                        color: _getStatusColor(transaction['status']),
                        fontSize: 10,
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

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 60,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you have transactions, they\'ll appear here',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processed':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Transaction ID', transaction['id'], isDarkMode),
              _buildDetailRow('Type', transaction['type'], isDarkMode),
              _buildDetailRow(
                'Date',
                DateFormat('dd MMMM yyyy, HH:mm').format(transaction['date']),
                isDarkMode,
              ),
              _buildDetailRow(
                'Amount',
                '${transaction['type'] == 'Money In' ? '+' : '-'} ${NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format((transaction['amount'] as double).round())}',
                isDarkMode,
              ),
              _buildDetailRow('Status', transaction['status'], isDarkMode),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
                            : [Colors.blue[400]!, Colors.blue[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}