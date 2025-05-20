import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/screens/seller/my_balance_screen.dart' as balance_screen;
import 'package:u_teen/screens/seller/home_screen.dart' as home_screen;
import 'package:u_teen/screens/seller/my_product_screen.dart' as product_screen;
import 'package:u_teen/screens/seller/profile_screen.dart' as profile_screen;
import 'package:u_teen/providers/theme_notifier.dart';

class NavIndices {
  static const home = 0;
  static const balance = 1;
  static const products = 2;
  static const profile = 3;
}

class SellerCustomBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final BuildContext context;

  const SellerCustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.context,
  });

  @override
  _SellerCustomBottomNavigationState createState() =>
      _SellerCustomBottomNavigationState();
}

class _SellerCustomBottomNavigationState
    extends State<SellerCustomBottomNavigation> with TickerProviderStateMixin {
  late int _currentIndex;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.easeOutQuad;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _navigateToScreen(int newIndex) {
    if (_currentIndex == newIndex) return;

    setState(() {
      _currentIndex = newIndex;
    });

    Widget nextPage;
    switch (newIndex) {
      case NavIndices.home:
        nextPage = const home_screen.SellerHomeScreen();
        break;
      case NavIndices.balance:
        nextPage = const balance_screen.SellerBalanceScreen();
        break;
      case NavIndices.products:
        nextPage = const product_screen.SellerMyProductScreen();
        break;
      case NavIndices.profile:
        nextPage = const profile_screen.SellerProfileScreen();
        break;
      default:
        return;
    }

    Navigator.of(widget.context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(widget.context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Material(
      type: MaterialType.transparency,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        height: 80,
        child: AnimatedOpacity(
          duration: _animationDuration,
          curve: _animationCurve,
          opacity: 1,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: _animationDuration,
              curve: _animationCurve,
              margin: const EdgeInsets.only(bottom: 16),
              width: MediaQuery.of(context).size.width * 0.92,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDarkMode
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF64748B).withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_outlined, 'Home', NavIndices.home, isDarkMode),
                      _buildNavItem(Icons.account_balance_wallet_outlined, 'Balance', NavIndices.balance, isDarkMode),
                      _buildNavItem(Icons.fastfood_outlined, 'Products', NavIndices.products, isDarkMode),
                      _buildNavItem(Icons.person_outline, 'Profile', NavIndices.profile, isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDarkMode) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateToScreen(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : isDarkMode
                      ? Colors.grey[400]
                      : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? const Color(0xFF6366F1)
                    : isDarkMode
                        ? Colors.grey[400]
                        : const Color(0xFF94A3B8),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}