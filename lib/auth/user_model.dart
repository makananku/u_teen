class User {
  final String email;
  final String? password; // Bisa nullable untuk AuthProvider
  final String name;
  final String userType; // 'customer' or 'seller'

  User({
    required this.email,
    this.password, // Di AuthProvider tidak butuh password
    required this.name,
    required this.userType,
  });
}