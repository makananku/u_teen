import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  late final SharedPreferences _prefs;

  AuthProvider(SharedPreferences prefs) : _prefs = prefs;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isSeller => _user?.userType == 'seller';
  bool get isCustomer => _user?.userType == 'customer';
  String? get sellerEmail => isSeller ? _user?.email : null;
  String? get sellernim => isSeller ? _user?.nim : null; 
  String? get tenantName => isSeller ? _user?.name : null;
  String? get customerEmail => isCustomer ? _user?.email : null;
  String? get customerName => isCustomer ? _user?.name : null;
  String? get customernim => isCustomer ? _user?.nim : null;
  String? get customerPhoneNumber => isCustomer ? _user?.phoneNumber : null;
  String? get customerProdi => isCustomer ? _user?.prodi : null; 
  String? get customerAngkatan => isCustomer ? _user?.angkatan : null; 

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final email = _prefs.getString('user_email');
      final name = _prefs.getString('user_name');
      final userType = _prefs.getString('user_type');
      final nim = _prefs.getString('user_nim');
      final phoneNumber = _prefs.getString('user_phone_number');
      final prodi = _prefs.getString('user_prodi');
      final angkatan = _prefs.getString('user_angkatan');

      if (email != null && name != null && userType != null) {
        _user = User(
          email: email,
          name: name,
          userType: userType,
          nim: nim ?? '',
          phoneNumber: phoneNumber ?? '',
          prodi: prodi ?? '',
          angkatan: angkatan ?? '',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(
    String email,
    String name,
    String userType,
    String nim,
    String phoneNumber,
    String prodi,
    String angkatan,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _prefs.setString('user_email', email);
      await _prefs.setString('user_name', name);
      await _prefs.setString('user_type', userType);
      await _prefs.setString('user_nim', nim);
      await _prefs.setString('user_phone_number', phoneNumber);
      await _prefs.setString('user_prodi', prodi);
      await _prefs.setString('user_angkatan', angkatan);

      _user = User(
        email: email,
        name: name,
        userType: userType,
        nim: nim,
        phoneNumber: phoneNumber,
        prodi: prodi,
        angkatan: angkatan,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove('user_email');
    await _prefs.remove('user_name');
    await _prefs.remove('user_type');
    await _prefs.remove('user_nim');
    await _prefs.remove('user_phone_number');
    await _prefs.remove('user_prodi');
    await _prefs.remove('user_angkatan');

    _user = null;
    notifyListeners();
  }
}

class User {
  final String email;
  final String name;
  final String userType;
  final String nim;
  final String phoneNumber;
  final String prodi;
  final String angkatan;

  User({
    required this.email,
    required this.name,
    required this.userType,
    required this.nim,
    required this.phoneNumber,
    required this.prodi,
    required this.angkatan,
  });
}