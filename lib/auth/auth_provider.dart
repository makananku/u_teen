import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isSeller = false;
  String? _customerNim;
  String? _sellerNim;
  String? _customerProdi;
  String? _customerAngkatan;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSeller => _isSeller;
  bool get isCustomer => !_isSeller;
  String? get customerNim => _customerNim;
  String? get sellerNim => _sellerNim;
  String? get customerProdi => _customerProdi;
  String? get customerAngkatan => _customerAngkatan;
  String? get tenantName => _user?.tenantName; // Added for sellers
  String? get sellerEmail => _user?.email; // For consistency

  AuthProvider() {
    initialize();
  }

  Future<void> initialize() async {
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
      _user = User(
        email: email,
        name: name,
        userType: userType,
        nim: nim,
        phoneNumber: phoneNumber,
        prodi: prodi,
        angkatan: angkatan,
        tenantName: tenantName,
      );
      _isLoggedIn = true;
      _isSeller = userType == 'seller';
      _customerNim = !_isSeller ? nim : null;
      _sellerNim = _isSeller ? nim : null;
      _customerProdi = !_isSeller ? prodi : null;
      _customerAngkatan = !_isSeller ? angkatan : null;
      notifyListeners();
    }
  }

  Future<bool> login(
    String email,
    String name,
    String userType,
    String? nim,
    String? phoneNumber,
    String? prodi,
    String? angkatan,
    String? tenantName, // Added for sellers
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('name', name);
      await prefs.setString('userType', userType);
      if (nim != null) await prefs.setString('nim', nim);
      if (phoneNumber != null) await prefs.setString('phoneNumber', phoneNumber);
      if (prodi != null) await prefs.setString('prodi', prodi);
      if (angkatan != null) await prefs.setString('angkatan', angkatan);
      if (tenantName != null) await prefs.setString('tenantName', tenantName);

      _user = User(
        email: email,
        name: name,
        userType: userType,
        nim: nim,
        phoneNumber: phoneNumber,
        prodi: prodi,
        angkatan: angkatan,
        tenantName: tenantName,
      );
      _isLoggedIn = true;
      _isSeller = userType == 'seller';
      _customerNim = !_isSeller ? nim : null;
      _sellerNim = _isSeller ? nim : null;
      _customerProdi = !_isSeller ? prodi : null;
      _customerAngkatan = !_isSeller ? angkatan : null;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login save error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
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