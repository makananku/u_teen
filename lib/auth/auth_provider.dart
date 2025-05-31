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
  final AuthService _authService = AuthService();
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSeller => _isSeller;
  bool get isCustomer => !_isSeller;
  String? get customerNim => _customerNim;
  String? get sellerNim => _sellerNim;
  String? get customerProdi => _customerProdi;
  String? get customerAngkatan => _customerAngkatan;
  String? get tenantName => _user?.tenantName;
  String? get sellerEmail => _user?.email;

  AuthProvider() {
    initialize();
    _firebaseAuth.authStateChanges().listen((fb.User? firebaseUser) {
      if (firebaseUser == null) {
        logout();
      } else if (_user == null || _user!.email != firebaseUser.email) {
        _loadUserData();
      }
    });
  }

  Future<void> initialize() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null || firebaseUser.isAnonymous) {
        debugPrint('AuthProvider: No authenticated user or anonymous user');
        await logout();
        return;
      }

      // Fetch from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (userDoc.exists) {
        _user = User.fromFirestore(userDoc);
        await _saveToPrefs(_user!);
        _isLoggedIn = true;
        _isSeller = _user!.userType == 'seller';
        _customerNim = !_isSeller ? _user!.nim : null;
        _sellerNim = _isSeller ? _user!.nim : null;
        _customerProdi = !_isSeller ? _user!.prodi : null;
        _customerAngkatan = !_isSeller ? _user!.angkatan : null;
        debugPrint('AuthProvider: Loaded user from Firestore: ${_user!.email}, type: ${_user!.userType}');
        notifyListeners();
      } else {
        debugPrint('AuthProvider: No Firestore document for UID: ${firebaseUser.uid}');
        await logout();
      }
    } catch (e) {
      debugPrint('AuthProvider initialize error: $e');
      await logout();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.login(email, password);
      if (user == null) {
        debugPrint('AuthProvider: Login failed');
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
      return true;
    } catch (e) {
      debugPrint('AuthProvider login error: $e');
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
  }

  Future<bool> logout() async {
    try {
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