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
  bool _isInitialized = false;

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
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(fb.User? firebaseUser) async {
    if (firebaseUser == null) {
      await logout();
    } else if (_user == null || _user!.email != firebaseUser.email) {
      await _loadUserData(firebaseUser);
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser);
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('AuthProvider initialize error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(fb.User firebaseUser) async {
    try {
      if (!firebaseUser.emailVerified) {
        debugPrint('Email not verified');
        await logout();
        return;
      }

      // Cek SharedPreferences terlebih dahulu
      final prefs = await SharedPreferences.getInstance();
      final cachedEmail = prefs.getString('email');
      
      if (cachedEmail == firebaseUser.email) {
        _loadFromPreferences(prefs);
        return;
      }

      // Jika tidak ada di SharedPreferences atau email berbeda, ambil dari Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        _user = User.fromFirestore(userDoc);
        await _saveToPrefs(_user!);
        _updateUserState();
        debugPrint('Loaded user from Firestore: ${_user!.email}');
      } else {
        debugPrint('User document does not exist in Firestore');
        await logout();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      await logout();
    }
  }

  void _loadFromPreferences(SharedPreferences prefs) {
    final email = prefs.getString('email');
    final name = prefs.getString('name');
    final userType = prefs.getString('userType');
    
    if (email == null || name == null || userType == null) {
      throw Exception('Incomplete user data in SharedPreferences');
    }

    _user = User(
      email: email,
      name: name,
      userType: userType,
      nim: prefs.getString('nim'),
      phoneNumber: prefs.getString('phoneNumber'),
      prodi: prefs.getString('prodi'),
      angkatan: prefs.getString('angkatan'),
      tenantName: prefs.getString('tenantName'),
    );
    
    _updateUserState();
    debugPrint('Loaded user from SharedPreferences: $email');
  }

  void _updateUserState() {
    _isLoggedIn = true;
    _isSeller = _user!.userType == 'seller';
    _customerNim = !_isSeller ? _user!.nim : null;
    _sellerNim = _isSeller ? _user!.nim : null;
    _customerProdi = !_isSeller ? _user!.prodi : null;
    _customerAngkatan = !_isSeller ? _user!.angkatan : null;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.login(email, password);
      if (user == null) return false;

      // Verifikasi email
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null || !firebaseUser.emailVerified) {
        debugPrint('Email not verified');
        await logout();
        return false;
      }

      _user = user;
      await _saveToPrefs(user);
      _updateUserState();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
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
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }
}