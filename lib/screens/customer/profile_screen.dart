import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../widgets/custom_bottom_navigation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../auth/logout_service.dart';
import '../login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return Future.value(false);
      },
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                "My Account",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        _buildProfileOption(
                          icon: Icons.bookmark_border,
                          title: "My Favorites",
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.thumb_up_alt_outlined,
                          title: "Ratings & Review",
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.payment,
                          title: "Payment Methods",
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.security,
                          title: "Security",
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.help_outline,
                          title: "Help Centre",
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.logout,
                          title: "Logout",
                          onTap: () => LogoutService.showLogoutConfirmation(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.asset(
                  'assets/asset/profile_picture.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 30, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Javier Matthew",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Edit Profile  >",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}