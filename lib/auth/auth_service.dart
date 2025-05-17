class AuthService {
  final List<User> _dummyUsers = [
    User(
      email: '123@student.umn.ac.id',
      password: '123',
      name: 'Nicholas Soesilo',
      userType: 'customer',
      nim: '000000646490',
      phoneNumber: '628221110806',
      prodi: 'Information Systems',
      angkatan: '2022',
    ),
    User(
      email: '456@seller.umn.ac.id',
      password: '456',
      name: 'Masakan Minang',
      userType: 'seller',
      nim: 'TNT000123',
      phoneNumber: '628123456789',
      prodi: '', 
      angkatan: '',
    ),
  ];

  User? getUserByCredentials(String email, String password) {
    try {
      return _dummyUsers.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      return _dummyUsers.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  String? validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.endsWith('@student.umn.ac.id') &&
        !email.endsWith('@seller.umn.ac.id') &&
        !email.endsWith('@umn.ac.id') &&
        !email.endsWith('@lecturer.umn.ac.id')) {
      return 'Email must end with valid UMN domain';
    }
    return null;
  }
}

class User {
  final String email;
  final String password;
  final String name;
  final String userType;
  final String nim;
  final String phoneNumber;
  final String prodi;
  final String angkatan;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
    required this.nim,
    required this.phoneNumber,
    required this.prodi,
    required this.angkatan,
  });
}