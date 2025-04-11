import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: TransactionHistoryScreen(),
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryScreen> {
  String selectedTab = 'All';
  bool _isLoading = false;

  // Enhanced transaction data with more details
  final List<Map<String, dynamic>> transactions = [
    {
      'id': '1',
      'title': 'Payment by Theo56',
      'date': DateTime(2022, 11, 1, 14, 30),
      'amount': '15000', // Amount as String here
      'type': 'Money In',
      'status': 'Completed',
      'customerImage': 'assets/users/user1.jpg',
    },
    {
      'id': '2',
      'title': 'Payment by Javier M',
      'date': DateTime(2022, 11, 23, 9, 15),
      'amount': '20000', // Amount as String here
      'type': 'Money In',
      'status': 'Completed',
      'customerImage': 'assets/users/user2.jpg',
    },
    {
      'id': '3',
      'title': 'Withdrawal to Bank',
      'date': DateTime(2022, 11, 15, 16, 45),
      'amount': 50000, // Amount as int here
      'type': 'Money Out',
      'status': 'Processed',
      'customerImage': 'assets/users/bank.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions =
        transactions.where((transaction) {
          return selectedTab == 'All' || transaction['type'] == selectedTab;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[700]!, Colors.blue[400]!],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),

          // Tab buttons with better styling
          _buildTabBar(),

          // Transaction list with enhanced UI
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: EdgeInsets.only(top: 8),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionCard(
                          filteredTransactions[index],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final int totalIn = transactions
        .where((t) => t['type'] == 'Money In')
        .fold(
          0,
          (int sum, t) => sum + _parseAmount(t['amount']),
        ); // Use _parseAmount

    final int totalOut = transactions
        .where(
          (t) => t['type'] == 'Money Out',
        ) // Corrected from 'Money In' to 'Money Out'
        .fold(
          0,
          (int sum, t) => sum + _parseAmount(t['amount']),
        ); // Use _parseAmount

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[400]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
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
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total In',
                '+Rp${NumberFormat('#,###').format(totalIn)}',
              ),
              _buildSummaryItem(
                'Total Out',
                '-Rp${NumberFormat('#,###').format(totalOut)}',
              ),
              _buildSummaryItem(
                'Balance',
                'Rp${NumberFormat('#,###').format(totalIn - totalOut)}',
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
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabButton('All', Icons.list_alt),
          _buildTabButton('Money In', Icons.arrow_downward),
          _buildTabButton('Money Out', Icons.arrow_upward),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, IconData icon) {
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tab;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.all(4),
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
                color: isSelected ? Colors.white : Colors.blue,
              ),
              SizedBox(width: 6),
              Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isMoneyIn = transaction['type'] == 'Money In';
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');
    final amount = _parseAmount(transaction['amount']); // Use _parseAmount

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show transaction details
          _showTransactionDetails(transaction);
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMoneyIn ? Colors.green[50] : Colors.red[50],
                ),
                child: Icon(
                  isMoneyIn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isMoneyIn ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateFormat.format(transaction['date']),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isMoneyIn ? '+' : '-'}Rp${NumberFormat('#,###').format(amount)}',
                    style: TextStyle(
                      color: isMoneyIn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        transaction['status'],
                      ).withOpacity(0.1),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'When you have transactions, they\'ll appear here',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
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

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context, // Add this required parameter
      builder: (context) {
        // Add this required parameter
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Transaction Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildDetailRow('Transaction ID', transaction['id']),
              _buildDetailRow('Type', transaction['type']),
              _buildDetailRow(
                'Date',
                DateFormat('dd MMMM yyyy, HH:mm').format(transaction['date']),
              ),
              _buildDetailRow(
                'Amount',
                '${transaction['type'] == 'Money In' ? '+' : '-'}Rp${NumberFormat('#,###').format(_parseAmount(transaction['amount']))}',
              ),
              _buildDetailRow('Status', transaction['status']),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true, // This is optional
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(value, style: TextStyle(color: Colors.grey[800])),
        ],
      ),
    );
  }

  int _parseAmount(dynamic amount) {
    if (amount is int) {
      return amount;
    } else if (amount is String) {
      return int.tryParse(amount.replaceAll('Rp', '').replaceAll('.', '')) ?? 0;
    }
    return 0; // default value if the amount is invalid
  }
}
