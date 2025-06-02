import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isSeller = false;
  String? _customerNim;
  String? _sellerNim;
  String? _customerProdi;
  String? _customerAngkatan;
  bool _isInitializing = false; // Flag untuk mencegah logout saat inisialisasi
  final AuthService _authService = AuthService();
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  DateTime? _lastAuthStateChange; // Track last auth state change
  static const _debounceDuration = Duration(milliseconds: 500); // Debounce duration

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSeller => _isSeller;
  bool get isCustomer => !_isSeller;
  String? get customerNim => _customerNim;
  String? get sellerNim => _sellerNim;
  String? get customerProdi => _customerProdi;
  String? get customerAngkatan => _customerAngkatan;
  String? get tenantName => _user?.tenantName ?? _user?.name; // Gunakan name jika tenantName null
  String? get sellerEmail => _user?.email;

  AuthProvider() {
    debugPrint('AuthProvider: Constructor called');
    initialize();
    _firebaseAuth.authStateChanges().listen((fb.User? firebaseUser) async {
      // Debounce auth state changes
      final now = DateTime.now();
      if (_lastAuthStateChange != null &&
          now.difference(_lastAuthStateChange!).inMilliseconds < _debounceDuration.inMilliseconds) {
        debugPrint('AuthProvider: Debouncing authStateChanges, skipping');
        return;
      }
      _lastAuthStateChange = now;

      debugPrint('AuthProvider: authStateChanges triggered, user: ${firebaseUser?.email}');
      if (firebaseUser == null) {
        if (!_isInitializing) {
          await logout();
        }
      } else if (_user == null || _user!.email != firebaseUser.email) {
        await _loadUserData();
      }
    });
  }

  Future<void> initialize() async {
    debugPrint('AuthProvider: Starting initialization');
    _isInitializing = true;
    await _loadUserData();
    _isInitializing = false;
    debugPrint('AuthProvider: Initialization complete');
  }

  Future<void> _loadUserData() async {
    try {
      // Check SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final cachedEmail = prefs.getString('email');
      if (cachedEmail != null) {
        final cachedUser = await _loadFromPrefs();
        if (cachedUser != null && _firebaseAuth.currentUser?.email == cachedEmail) {
          _user = cachedUser;
          _isLoggedIn = true;
          _isSeller = _user!.userType == 'seller';
          _customerNim = !_isSeller ? _user!.nim : null;
          _sellerNim = _isSeller ? _user!.nim : null;
          _customerProdi = !_isSeller ? _user!.prodi : null;
          _customerAngkatan = !_isSeller ? _user!.angkatan : null;
          debugPrint('AuthProvider: Loaded user from SharedPreferences: ${_user!.email}');
          notifyListeners();
          return; // Skip Firestore if cached data is valid
        }
      }

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null || firebaseUser.isAnonymous) {
        debugPrint('AuthProvider: No authenticated user or anonymous user');
        if (!_isInitializing) await logout();
        return;
      }

      debugPrint('AuthProvider: Fetching data for UID: ${firebaseUser.uid}, email: ${firebaseUser.email}');
      // Fetch from Firestore with timeout
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Firestore query timed out');
      });

      if (userDoc.exists) {
        _user = User.fromFirestore(userDoc);
        await _saveToPrefs(_user!);
        _isLoggedIn = true;
        _isSeller = _user!.userType == 'seller';
        _customerNim = !_isSeller ? _user!.nim : null;
        _sellerNim = _isSeller ? _user!.nim : null;
        _customerProdi = !_isSeller ? _user!.prodi : null;
        _customerAngkatan = !_isSeller ? _user!.angkatan : null;
        debugPrint('AuthProvider: Loaded user from Firestore: ${_user!.email}, type: ${_user!.userType}, tenantName: ${_user!.tenantName ?? _user!.name}');
        notifyListeners();
      } else {
        debugPrint('AuthProvider: No Firestore document for UID: ${firebaseUser.uid}. Keeping user logged in.');
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AuthProvider initialize error: $e');
      if (!_isInitializing) await logout();
    }
  }

  Future<User?> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final name = prefs.getString('name');
    final userType = prefs.getString('userType');
    final nim = prefs.getString('nim');
    final phoneNumber = prefs.getString('phoneNumber');
    final prodi = prefs.getString('prodi');
    final angkatan = prefs.getString('angkatan');
    final tenantName = prefs.getString('tenantName');

    if (email != null && name != null && userType != null) {
      return User(
        email: email,
        name: name,
        userType: userType,
        nim: nim,
        phoneNumber: phoneNumber,
        prodi: prodi,
        angkatan: angkatan,
        tenantName: tenantName,
      );
    }
    return null;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthProvider: Starting login for $email');
      _isInitializing = true;
      final user = await _authService.login(email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Login timed out'),
      );
      if (user == null) {
        debugPrint('AuthProvider: Login failed');
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
    else await prefs.remove('nim');
    if (user.phoneNumber != null) await prefs.setString('phoneNumber', user.phoneNumber!);
    else await prefs.remove('phoneNumber');
    if (user.prodi != null) await prefs.setString('prodi', user.prodi!);
    else await prefs.remove('prodi');
    if (user.angkatan != null) await prefs.setString('angkatan', user.angkatan!);
    else await prefs.remove('angkatan');
    if (user.tenantName != null) await prefs.setString('tenantName', user.tenantName!);
    else await prefs.remove('tenantName');
    debugPrint('AuthProvider: Saved user data to SharedPreferences');
  }

  Future<bool> logout() async {
    try {
      debugPrint('AuthProvider: Attempting logout');
      await _firebaseAuth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _user = null;
      _isLoggedIn = false;
      _isSeller = false;
      _customerNim = null;
      _sellerNim = null;
      _customerProdi = null;
      _customerAngkatan = null;
      debugPrint('AuthProvider: Logged out');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthProvider logout error: $e');
      return false;
    }
  }
}