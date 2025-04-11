class AuthService {
  final List<User> _dummyUsers = [
    User(
      email: '123@student.umn.ac.id',
      password: '123',
      name: 'Nicholas Soesilo',
      userType: 'customer',
    ),
    User(
      email: 'dosen@lecturer.umn.ac.id',
      password: '123',
      name: 'Dosen',
      userType: 'customer',
    ),
    User(
      email: 'staff@umn.ac.id',
      password: '123',
      name: 'Staff',
      userType: 'customer',
    ),
    User(
      email: '456@seller.umn.ac.id',
      password: '456',
      name: 'Masakan Minang',
      userType: 'seller',
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

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
  });
}