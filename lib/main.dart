import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:u_teen/firebase_options.dart';
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
import 'providers/theme_notifier.dart';
import 'package:u_teen/data/data_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling (from code 2)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize data only if it's the first run (from code 2)
    final firstRun = await DataInitializer.isFirstRun();
    if (firstRun) {
      try {
        await DataInitializer.initializeData();
        await DataInitializer.setFirstRunComplete();
      } catch (e) {
        debugPrint('Error during data initialization: $e');
      }
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        Provider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => FoodProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(
            Provider.of<NotificationProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RatingProvider(
            Provider.of<OrderProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.currentTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Using the improved error handling from code 2
    return FutureBuilder(
      future: auth.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error initializing app: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        auth.initialize().then((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthWrapper(),
                            ),
                          );
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SplashScreen();
        }
        // Keep the loading screen from code 1 (simpler version)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers from code 1
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoFadeOut;

  late final AnimationController _textController;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;

  late final AnimationController _textShiftController;
  late final Animation<Offset> _textShift;

  late final AnimationController _bgController;
  late final Animation<Color?> _bgColor;
  late final Animation<Color?> _textColor;

  late final AnimationController _buttonController;
  late final Animation<double> _buttonScale;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _buttonSlideY;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();

    Future.delayed(Duration.zero, () {
      _startAnimations();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimations());
  }

  Widget _buildDynamicContent() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _textController,
        _bgController,
      ]),
      builder: (context, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoAnimation(),
            const SizedBox(height: 30),
            _buildTextAnimation(),
            if (_bgController.isCompleted) _buildAuthSection(),
          ],
        );
      },
    );
  }

  Widget _buildAuthSection() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 100),
          child: _buildAnimatedAuthButtons(),
        );
      },
    );
  }

  void _initializeControllers() {
    // Exact same controller setup from code 1
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textShiftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _initializeAnimations() {
    // Exact same animation setup from code 1
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
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

    _textShift = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(
      CurvedAnimation(
        parent: _textShiftController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _bgColor = ColorTween(
      begin: Colors.blue[800],
      end: Colors.white,
    ).animate(_bgController);

    _textColor = ColorTween(
      begin: Colors.white,
      end: Colors.blue[800],
    ).animate(_bgController);

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
  }

  Future<void> _startAnimations() async {
    // Exact same animation sequence from code 1
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _bgController.forward().then((_) {
      if (!mounted) return;
      _logoController.reverse();
      _textShiftController.forward();

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
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: _bgColor.value,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _textColor.value,
          displayColor: _textColor.value,
        ),
      ),
      child: Scaffold(
        backgroundColor: _bgColor.value,
        body: Center(child: _buildDynamicContent()),
      ),
    );
  }

  Widget _buildLogoAnimation() {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoOpacity,
        child: FadeTransition(
          opacity: _logoFadeOut,
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
    );
  }

  Widget _buildTextAnimation() {
    return SlideTransition(
      position: _textSlide,
      child: SlideTransition(
        position: _textShift,
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
                  color: _bgController.value < 0.5 ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
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
                        return FadeTransition(opacity: animation, child: child);
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