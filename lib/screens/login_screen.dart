import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/auth/auth_service.dart';
import 'package:u_teen/screens/customer/home_screen.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/providers/favorite_provider.dart';
import 'package:u_teen/providers/cart_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime? _lastBackPressTime;

  @override
void initState() {
  super.initState();
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  
  _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
  );
  
  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutQuart,
  ));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    debugPrint('LoginScreen: Initializing AuthProvider');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (authProvider.isLoggedIn && authProvider.user != null && mounted) {
      debugPrint('LoginScreen: User is logged in, email: ${authProvider.user!.email}');
      try {
        await Provider.of<FavoriteProvider>(context, listen: false).initialize(context);
        debugPrint('FavoriteProvider initialized for user: ${authProvider.user?.email}');
        await Provider.of<CartProvider>(context, listen: false).initialize(authProvider.user!.email);
        debugPrint('CartProvider initialized for user: ${authProvider.user?.email}');
      } catch (e) {
        debugPrint('LoginScreen: Error initializing providers: $e');
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => authProvider.isSeller
                ? const SellerHomeScreen()
                : const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } else {
      debugPrint('LoginScreen: No logged-in user, showing login UI');
      _animationController.forward();
    }
  });
}

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint('LoginScreen: Attempting login for $email');
    final emailValidationError = authService.validateEmail(email);
    if (emailValidationError != null) {
      _showSnackBar(emailValidationError, AppTheme.getSnackBarError(isDarkMode));
      setState(() => _isLoading = false);
      return;
    }

    final user = await authService.login(email, password);

    if (!mounted) return;

    if (user != null) {
      final success = await authProvider.login(
        email: email,
        password: password,
      );

      if (success && authProvider.user != null && mounted) {
        try {
          await Provider.of<FavoriteProvider>(context, listen: false).initialize(context);
          debugPrint('FavoriteProvider initialized for user: ${authProvider.user!.email}');
          await Provider.of<CartProvider>(context, listen: false).initialize(authProvider.user!.email);
          debugPrint('CartProvider initialized for user: ${authProvider.user!.email}');
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            debugPrint('LoginScreen: Login successful, navigating to home');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => user.userType == 'seller'
                    ? const SellerHomeScreen()
                    : const HomeScreen(),
              ),
              (route) => false,
            );
          }
        } catch (e) {
          debugPrint('LoginScreen: Error initializing providers: $e');
          _showSnackBar('Error initializing app: $e', AppTheme.getSnackBarError(isDarkMode));
        }
      } else {
        debugPrint('LoginScreen: Failed to save login session');
        _showSnackBar('Failed to save login session.', AppTheme.getSnackBarError(isDarkMode));
      }
    } else {
      debugPrint('LoginScreen: Login failed, user is null');
      _showSnackBar('Login failed. Incorrect email or password, or user data not found.', AppTheme.getSnackBarError(isDarkMode));
    }
  } catch (e) {
    debugPrint('LoginScreen: Login error: $e');
    if (mounted) {
      _showSnackBar('An error occurred: $e', AppTheme.getSnackBarError(isDarkMode));
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<bool> _onWillPop() async {
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    final currentTime = DateTime.now();
    final backPressDuration = _lastBackPressTime == null
        ? Duration.zero
        : currentTime.difference(_lastBackPressTime!);

    if (backPressDuration >= const Duration(seconds: 2)) {
      _lastBackPressTime = currentTime;
      _showSnackBar('Press back again to exit', AppTheme.getSnackBarInfo(isDarkMode));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final blueColor = AppTheme.getBlue800(isDarkMode);
    final lightBlue = AppTheme.getBlue100(isDarkMode);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDarkMode),
        body: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: blueColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: lightBlue.withOpacity(isDarkMode ? 0.3 : 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 80),
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? AppTheme.getPrimaryText(isDarkMode) : AppTheme.getBlue900(isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? AppTheme.getGrey400(isDarkMode) : AppTheme.getGrey600(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.getCard(isDarkMode),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getShadowLight(isDarkMode),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDarkMode ? AppTheme.getDark2D(isDarkMode) : AppTheme.getCard(isDarkMode),
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: isDarkMode ? AppTheme.getGrey500(isDarkMode) : AppTheme.getGrey600(isDarkMode)),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: blueColor,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) => AuthService().validateEmail(value),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDarkMode ? AppTheme.getDark2D(isDarkMode) : AppTheme.getCard(isDarkMode),
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: isDarkMode ? AppTheme.getGrey500(isDarkMode) : AppTheme.getGrey600(isDarkMode)),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: blueColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          color: blueColor,
                                        ),
                                        onPressed: () {
                                          setState(() => _obscurePassword = !_obscurePassword);
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    validator: _validatePassword,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        foregroundColor: isDarkMode ? AppTheme.getPrimaryText(isDarkMode) : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                        shadowColor: blueColor.withOpacity(0.3),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'LOGIN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode ? AppTheme.getPrimaryText(isDarkMode) : Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}