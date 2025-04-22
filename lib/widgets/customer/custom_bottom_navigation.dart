import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../screens/customer/home_screen.dart';
import '../../screens/customer/my_orders_screen.dart';
import '../../screens/customer/shopping_cart_screen.dart';
import '../../screens/customer/profile_screen.dart';

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

class _CustomBottomNavigationState extends State<CustomBottomNavigation> 
    with TickerProviderStateMixin {
  late int _currentIndex;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.easeOutQuad;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _navigateWithDirectionalSlide(int newIndex) {
    if (_currentIndex == newIndex) return;

    // Trigger tap animation
    _scaleController.forward().then((_) => _scaleController.reverse());

    final currentIndex = _currentIndex;
    setState(() {
      _currentIndex = newIndex;
    });

    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      final Offset begin = newIndex > currentIndex 
          ? const Offset(1.0, 0.0)  // Slide from right to left
          : const Offset(-1.0, 0.0); // Slide from left to right

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

      Navigator.of(widget.context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        widget.context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final positionAnimation = Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ));

            final fadeAnimation = Tween<double>(
              begin: 0.4,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Interval(0.3, 1.0, curve: Curves.easeOut),
            ));

            return SlideTransition(
              position: positionAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return AnimatedContainer(
          duration: _animationDuration,
          curve: _animationCurve,
          height: isKeyboardVisible ? 0 : 72,
          child: AnimatedOpacity(
            duration: _animationDuration,
            curve: _animationCurve,
            opacity: isKeyboardVisible ? 0 : 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: _animationDuration,
                curve: _animationCurve,
                margin: EdgeInsets.only(
                  bottom: isKeyboardVisible ? 0 : 20,
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.grid_view, 0),
                        _buildNavItem(Icons.receipt_long, 1),
                        _buildNavItem(Icons.shopping_cart, 2),
                        _buildNavItem(Icons.person, 3),
                      ],
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

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _navigateWithDirectionalSlide(index),
      child: ScaleTransition(
        scale: isSelected ? _scaleAnimation : AlwaysStoppedAnimation(1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 28,
          ),
        ),
      ),
    );
  }
}