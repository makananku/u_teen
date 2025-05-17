import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import '../login_screen.dart'; 
import '../../widgets/customer/custom_bottom_navigation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showPhoneInfo = false;

  void _togglePhoneInfo() {
    setState(() {
      _showPhoneInfo = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showPhoneInfo = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                "My Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 24),
                      _buildLogoutButton(context),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                if (_showPhoneInfo)
                  Positioned(
                    bottom: 120,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      opacity: _showPhoneInfo ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[800],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Keep your phone number updated at my.umn.ac.id",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: CustomBottomNavigation(
              selectedIndex: 3,
              context: context,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final email = user?.email ?? 'No Email';
    final name = user?.name ?? 'No Name';
    final nim = authProvider.isCustomer ? authProvider.customerNim : authProvider.sellerNim;
    final prodi = authProvider.customerProdi ?? 'No Prodi';
    final angkatan = authProvider.customerAngkatan ?? 'No Angkatan';
    final phoneNumber = user?.phoneNumber ?? 'No Phone';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.purple[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/asset/profile_picture.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 18,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade200, Colors.white],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailItem(
                icon: Icons.badge_outlined,
                title: authProvider.isCustomer ? 'STUDENT ID' : 'SELLER ID',
                value: nim ?? 'Not Available',
                iconColor: Colors.purple[600]!,
              ),
              if (authProvider.isCustomer)
                _buildDetailItem(
                  icon: Icons.school_outlined,
                  title: 'STUDY PROGRAM',
                  value: prodi == 'No Prodi' || angkatan == 'No Angkatan'
                      ? 'Not Available'
                      : '$prodi ($angkatan)',
                  iconColor: Colors.blue[600]!,
                ),
              _buildDetailItem(
                icon: Icons.phone_android_outlined,
                title: 'PHONE NUMBER',
                value: phoneNumber,
                showInfo: true,
                iconColor: Colors.teal[600]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool showInfo = false,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (showInfo) const SizedBox(width: 8),
                    if (showInfo)
                      GestureDetector(
                        onTap: _togglePhoneInfo,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout, size: 22),
          label: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red.shade600,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shadowColor: Colors.red.withOpacity(0.1),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout,
                          size: 40,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Ready to Leave?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "You'll be signed out of your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                bool success = await authProvider.logout();
                                if (success) {
                                  print('Logout successful, navigating to LoginScreen');
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                } else {
                                  print('Logout failed');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to logout. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}