import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isSeller = false;
  String? _customerNim;
  String? _sellerNim;
  String? _customerProdi;
  String? _customerAngkatan;
  bool _isInitializing = false;
  bool _isLoggingOut = false;
  bool _isInitialized = false;
  final AuthService _authService = AuthService();
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  late Future<void> _initializationFuture;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSeller => _isSeller;
  bool get isCustomer => !_isSeller;
  String? get customerNim => _customerNim;
  String? get sellerNim => _sellerNim;
  String? get customerProdi => _customerProdi;
  String? get customerAngkatan => _customerAngkatan;
  String? get tenantName => _user?.tenantName ?? _user?.name;
  String? get sellerEmail => _user?.email;
  bool get isInitialized => _isInitialized;
  fb.FirebaseAuth get firebaseAuth => _firebaseAuth;
  Future<void> get initializationFuture => _initializationFuture;

  AuthProvider() {
    debugPrint('AuthProvider: Constructor called');
    _initializationFuture = initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AuthProvider: Already initialized, skipping');
      return;
    }
    debugPrint('AuthProvider: Starting initialization');
    _isInitializing = true;
    try {
      await _loadUserData();
      _isInitialized = true;
      debugPrint('AuthProvider: Initialization complete');
    } catch (e) {
      debugPrint('AuthProvider: Initialization error: $e');
      throw Exception('Gagal menginisialisasi AuthProvider: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
    _firebaseAuth.authStateChanges().listen((fb.User? firebaseUser) async {
      debugPrint('AuthProvider: authStateChanges triggered, user: ${firebaseUser?.email}');
      if (firebaseUser == null) {
        if (_isLoggedIn && !_isLoggingOut && !_isInitializing) {
          await logout();
        }
      } else if (_user == null || _user!.email != firebaseUser.email) {
        await _loadUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null || firebaseUser.isAnonymous) {
        debugPrint('AuthProvider: No authenticated user or anonymous user');
        if (!_isInitializing && !_isLoggingOut) await logout();
        return;
      }

      debugPrint('AuthProvider: Fetching data for UID: ${firebaseUser.uid}, email: ${firebaseUser.email}');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (userDoc.exists) {
        _user = User.fromFirestore(userDoc);
      } else {
        debugPrint('AuthProvider: No Firestore document for UID: ${firebaseUser.uid}');
        throw Exception('Dokumen pengguna tidak ditemukan untuk UID: ${firebaseUser.uid}');
      }
      await _saveToPrefs(_user!);
      _isLoggedIn = true;
      _isSeller = _user!.userType == 'seller';
      _customerNim = !_isSeller ? _user!.nim : null;
      _sellerNim = _isSeller ? _user!.nim : null;
      _customerProdi = !_isSeller ? _user!.prodi : null;
      _customerAngkatan = !_isSeller ? _user!.angkatan : null;
      debugPrint('AuthProvider: Loaded user: ${_user!.email}, type: ${_user!.userType}, tenantName: ${_user!.tenantName ?? _user!.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider loadUserData error: $e');
      if (!_isInitializing && !_isLoggingOut) await logout();
      throw e;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      debugPrint('AuthProvider: Starting login for $email');
      _isInitializing = true;
      final user = await _authService.login(email, password);
      if (user == null) {
        debugPrint('AuthProvider: Login failed, no user returned');
        _isInitializing = false;
        return false;
      }
      _user = user;
      await _saveToPrefs(user);
      _isLoggedIn = true;
      _isSeller = user.userType == 'seller';
      _customerNim = !_isSeller ? user.nim : null;
      _sellerNim = _isSeller ? user.nim : null;
      _customerProdi = !_isSeller ? user.prodi : null;
      _customerAngkatan = !_isSeller ? user.angkatan : null;
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.initialize(user.email);
      debugPrint('AuthProvider: Logged in user: ${user.email}, type: ${user.userType}');
      notifyListeners();
      _isInitializing = false;
      return true;
    } catch (e) {
      debugPrint('AuthProvider login error: $e');
      _isInitializing = false;
      return false;
    }
  }

  Future<void> _saveToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email);
    await prefs.setString('name', user.name);
    await prefs.setString('userType', user.userType);
    if (user.nim != null) await prefs.setString('nim', user.nim!);
    if (user.phoneNumber != null) await prefs.setString('phoneNumber', user.phoneNumber!);
    if (user.prodi != null) await prefs.setString('prodi', user.prodi!);
    if (user.angkatan != null) await prefs.setString('angkatan', user.angkatan!);
    if (user.tenantName != null) await prefs.setString('tenantName', user.tenantName!);
    debugPrint('AuthProvider: Saved user data to SharedPreferences');
  }

  Future<bool> logout() async {
    if (_isLoggingOut) {
      debugPrint('AuthProvider: Logout already in progress, skipping');
      return false;
    }
    _isLoggingOut = true;
    try {
      debugPrint('AuthProvider: Attempting logout');
      await _firebaseAuth.signOut().catchError((e) {
        debugPrint('AuthProvider: Sign out error: $e');
      });
      await _firebaseAuth.setPersistence(fb.Persistence.NONE).catchError((e) {
        debugPrint('AuthProvider: Set persistence error: $e');
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _user = null;
      _isLoggedIn = false;
      _isSeller = false;
      _customerNim = null;
      _sellerNim = null;
      _customerProdi = null;
      _customerAngkatan = null;
      debugPrint('AuthProvider: Logged out successfully');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthProvider logout error: $e');
      // Force state reset even on error
      _user = null;
      _isLoggedIn = false;
      _isSeller = false;
      _customerNim = null;
      _sellerNim = null;
      _customerProdi = null;
      _customerAngkatan = null;
      notifyListeners();
      return false;
    } finally {
      _isLoggingOut = false;
    }
  }
}