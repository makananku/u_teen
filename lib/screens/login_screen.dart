import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/auth/auth_service.dart';
import 'package:u_teen/screens/customer/home_screen.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'package:u_teen/providers/theme_notifier.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      if (authProvider.isLoggedIn && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => authProvider.isSeller
                ? const SellerHomeScreen()
                : const HomeScreen(),
          ),
          (route) => false,
        );
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = AuthService();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final emailValidationError = authService.validateEmail(email);
      if (emailValidationError != null) {
        _showSnackBar(emailValidationError, Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      final user = await authService.login(email, password);

      if (!mounted) return;

      if (user != null) {
        final success = await authProvider.login(
          user.email,
          user.name,
          user.userType,
          user.nim,
          user.phoneNumber,
          user.prodi,
          user.angkatan,
          user.tenantName,
        );

        if (success && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => user.userType == 'seller'
                  ? const SellerHomeScreen()
                  : const HomeScreen(),
            ),
            (route) => false,
          );
        } else {
          _showSnackBar('Failed to save login session.', Colors.red);
        }
      } else {
        _showSnackBar('Login failed. Incorrect email or password.', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('An error occurred: $e', Colors.red);
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
    final currentTime = DateTime.now();
    final backPressDuration = _lastBackPressTime == null
        ? Duration.zero
        : currentTime.difference(_lastBackPressTime!);

    if (backPressDuration >= const Duration(seconds: 2)) {
      _lastBackPressTime = currentTime;
      _showSnackBar('Press back again to exit', Colors.blue);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.getBackground(isDarkMode),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getPrimaryText(isDarkMode),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'UMN Canteen Management',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.getSecondaryText(isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildLoginForm(isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDarkMode) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.getCard(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.getDetailBackground(isDarkMode),
                hintText: 'Email',
                hintStyle: TextStyle(color: AppTheme.getTextGrey(isDarkMode)),
                prefixIcon: Icon(Icons.email, color: AppTheme.getButton(isDarkMode)),
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
                fillColor: AppTheme.getDetailBackground(isDarkMode),
                hintText: 'Password',
                hintStyle: TextStyle(color: AppTheme.getTextGrey(isDarkMode)),
                prefixIcon: Icon(Icons.lock, color: AppTheme.getButton(isDarkMode)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppTheme.getButton(isDarkMode),
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
                  backgroundColor: AppTheme.getButton(isDarkMode),
                  foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(!isDarkMode),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}