import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'home_screen.dart';
import '../../widgets/customer/custom_bottom_navigation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../auth/logout_service.dart';
import '../customer/favorite_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  Navigator.pop(context);
                },
              ),
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        _buildProfileOption(
                          icon: Icons.bookmark_border,
                          title: "My Favorites",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoritesScreen(),
                              ),
                            );
                          },
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

  Widget _buildProfileHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final email = user?.email ?? '';
    final name = user?.name ?? '';
    final nit = user?.nit ?? '';
    final phoneNumber = user?.phoneNumber ?? '';

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        return const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Edit Profile  >",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileDetail(Icons.email, email),
            _buildProfileDetail(Icons.person, name),
            _buildProfileDetail(Icons.credit_card, nit),
            _buildProfileDetail(Icons.phone, phoneNumber, info: true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String text, {bool info = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          if (info) const Icon(Icons.info_outline, size: 16, color: Colors.grey),
        ],
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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}