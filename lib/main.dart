import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_provider.dart';
import 'auth/auth_service.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/food_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/login_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/seller/home_screen.dart';
import 'providers/rating_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();
  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider(prefs)),
        Provider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider(prefs)),
        ChangeNotifierProvider(create: (context) => FoodProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider(prefs)),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(
            prefs,
            Provider.of<NotificationProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RatingProvider(
            Provider.of<OrderProvider>(context, listen: false),
          ),
        ),
        
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return FutureBuilder(
      future: auth.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const SplashScreen();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoFadeOut; // Untuk menghilangkan logo

  late AnimationController _textController;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  late AnimationController _textShiftController; // Untuk pergeseran teks ke atas
  late Animation<Offset> _textShift; // Pergeseran teks ke atas

  late AnimationController _bgController;
  late Animation<Color?> _bgColor;
  late Animation<Color?> _textColor; // Untuk transisi warna teks

  late AnimationController _buttonController;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;
  late Animation<double> _buttonSlideY;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    _logoFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut), // Fade out di akhir
    ));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutQuart),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textShiftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Durasi lebih lama untuk pergeseran halus
    );
    _textShift = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5), // Geser lebih jauh untuk menggantikan posisi logo
    ).animate(
      CurvedAnimation(parent: _textShiftController, curve: Curves.easeInOutQuad),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _bgColor = ColorTween(
      begin: Colors.blue[800],
      end: Colors.white,
    ).animate(_bgController);
    _textColor = ColorTween(
      begin: Colors.white,
      end: Colors.blue[800],
    ).animate(_bgController);

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buttonScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _buttonSlideY = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _bgController.forward().then((_) {
      // Setelah latar belakang selesai, mulai animasi pergeseran teks dan fade out logo
      _logoController.reverse(); // Memudarkan logo
      _textShiftController.forward(); // Geser teks ke atas

      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                auth.isSeller ? const SellerHomeScreen() : const HomeScreen(),
          ),
        );
      } else {
        _buttonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _textShiftController.dispose();
    _bgController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _textController,
        _textShiftController,
        _bgController,
        _buttonController,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgColor.value,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: _logoController,
                        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
                      ),
                    ), // Kembalikan kombinasi fade in dan fade out
                    child: Image.asset(
                      'assets/logo/u.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const FlutterLogo(size: 100);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SlideTransition(
                  position: _textSlide,
                  child: SlideTransition(
                    position: _textShift, // Animasi pergeseran ke atas
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'U-Teen',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _textColor.value,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'UMN Canteen',
                            style: TextStyle(
                              fontSize: 16,
                              color: _bgController.value < 0.5
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_bgController.isCompleted) ...[
                  const SizedBox(height: 100),
                  _buildAnimatedAuthButtons(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAuthButtons() {
    return Transform.translate(
      offset: Offset(0, _buttonSlideY.value),
      child: Opacity(
        opacity: _buttonOpacity.value,
        child: Transform.scale(
          scale: _buttonScale.value,
          child: _buildAuthButtons(),
        ),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          MouseRegion(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3 * _buttonOpacity.value),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const LoginScreen(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 800),
                      settings: const RouteSettings(name: '/login'),
                    ),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}