import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/customer/custom_bottom_navigation.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';
import 'home_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final customerName = authProvider.user?.name ?? '';

    // Get orders for this customer
    final ongoingOrders = orderProvider.orders
        .where((order) =>
            (order.status == 'pending' ||
                order.status == 'processing' ||
                order.status == 'ready') &&
            order.customerName == customerName)
        .toList()
      ..sort((a, b) {
        const statusPriority = {
          'ready': 1,
          'pending': 2,
          'processing': 3,
        };
        return statusPriority[a.status]!.compareTo(statusPriority[b.status]!);
      });

    final historyOrders = orderProvider.orders
        .where((order) =>
            (order.status == 'completed' || order.status == 'cancelled') &&
            order.customerName == customerName)
        .toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.blue,
            tabs: const [Tab(text: "Ongoing"), Tab(text: "History")],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(ongoingOrders, "Ongoing"),
            _buildOrderList(historyOrders, "History"),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CustomBottomNavigation(
          selectedIndex: 1,
          context: context,
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String type) {
    if (orders.isEmpty) {
      return _buildEmptyOrderView(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => OrderCard(
          order: orders[index],
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildEmptyOrderView(String type) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animation/empty_order.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                type == "Ongoing" ? "No Active Orders" : "No Order History",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  type == "Ongoing"
                      ? "Your ongoing orders will appear here once you place an order"
                      : "Your completed or cancelled orders will appear here for future reference",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.shopping_bag, color: Colors.white),
                label: const Text(
                  "Order Now",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}