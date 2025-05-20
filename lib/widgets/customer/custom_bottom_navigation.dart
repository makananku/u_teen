import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../screens/customer/home_screen.dart';
import '../../screens/customer/my_orders_screen.dart';
import '../../screens/customer/shopping_cart_screen.dart';
import '../../screens/customer/profile_screen.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final BuildContext context;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.context,
  });

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> with TickerProviderStateMixin {
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
      case 0:
        nextPage = const HomeScreen();
        break;
      case 1:
        nextPage = const MyOrdersScreen();
        break;
      case 2:
        nextPage = const ShoppingCartScreen();
        break;
      case 3:
        nextPage = const ProfileScreen();
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
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
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
                  margin: EdgeInsets.only(
                    bottom: isKeyboardVisible ? 0 : 16,
                  ),
                  width: MediaQuery.of(context).size.width * 0.92,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.getCard(isDarkMode),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getShadow(isDarkMode).withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(Icons.home_outlined, 'Home', 0, isDarkMode),
                          _buildNavItem(Icons.receipt_long_outlined, 'Orders', 1, isDarkMode),
                          _buildNavItem(Icons.shopping_bag_outlined, 'Cart', 2, isDarkMode),
                          _buildNavItem(Icons.person_outline, 'Profile', 3, isDarkMode),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
              color: isActive ? AppTheme.getAccentPurple(isDarkMode) : AppTheme.getInactive(isDarkMode),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.getAccentPurple(isDarkMode) : AppTheme.getInactive(isDarkMode),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}