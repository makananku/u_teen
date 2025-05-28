import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/screens/login_screen.dart';
import 'package:u_teen/widgets/customer/custom_bottom_navigation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:u_teen/screens/customer/home_screen.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

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

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Theme(
      data: themeNotifier.currentTheme,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Scaffold(
              backgroundColor: AppTheme.getBackground(isDarkMode),
              appBar: AppBar(
                title: Text(
                  "My Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryText(isDarkMode),
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: true,
                backgroundColor: AppTheme.getCard(isDarkMode),
                elevation: 0.5,
                iconTheme: IconThemeData(
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileCard(context, isDarkMode),
                        const SizedBox(height: 24),
                        _buildThemeToggle(context, isDarkMode, themeNotifier),
                        const SizedBox(height: 16),
                        _buildLogoutButton(context, isDarkMode),
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
                            color: AppTheme.getAccentBlue(isDarkMode),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.1),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.getPrimaryText(!isDarkMode), size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Keep your phone number updated at my.umn.ac.id",
                                  style: TextStyle(
                                    color: AppTheme.getPrimaryText(!isDarkMode),
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
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDarkMode) {
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
        color: AppTheme.getCard(isDarkMode),
        elevation: isDarkMode ? 0 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.getBorder(isDarkMode),
            width: 1,
          ),
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
                    colors: [
                      AppTheme.getAccentBlue(isDarkMode),
                      AppTheme.getAccentPurpleLight(isDarkMode),
                    ],
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
                      color: AppTheme.getCard(isDarkMode),
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
                          color: AppTheme.getDetailBackground(isDarkMode),
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: AppTheme.getSecondaryText(isDarkMode),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.getAccentBlueLight(isDarkMode),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 18,
                      color: AppTheme.getAccentBlue(isDarkMode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getCard(isDarkMode),
                      AppTheme.getDivider(isDarkMode),
                      AppTheme.getCard(isDarkMode),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailItem(
                icon: Icons.badge_outlined,
                title: authProvider.isCustomer ? 'STUDENT ID' : 'SELLER ID',
                value: nim ?? 'Not Available',
                iconColor: AppTheme.getAccentPurpleDark(isDarkMode),
                isDarkMode: isDarkMode,
              ),
              if (authProvider.isCustomer)
                _buildDetailItem(
                  icon: Icons.school_outlined,
                  title: 'STUDY PROGRAM',
                  value: prodi == 'No Prodi' || angkatan == 'No Angkatan'
                      ? 'Not Available'
                      : '$prodi ($angkatan)',
                  iconColor: AppTheme.getAccentBlueDark(isDarkMode),
                  isDarkMode: isDarkMode,
                ),
              _buildDetailItem(
                icon: Icons.phone_android_outlined,
                title: 'PHONE NUMBER',
                value: phoneNumber,
                showInfo: true,
                iconColor: AppTheme.getAccentTeal(isDarkMode),
                isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getDetailBackground(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorder(isDarkMode),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isDarkMode ? 0.2 : 0.1),
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
                    color: AppTheme.getSecondaryText(isDarkMode),
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
                        color: AppTheme.getTextDark(isDarkMode),
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
                            color: AppTheme.getAccentBlueLight(isDarkMode),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppTheme.getAccentBlue(isDarkMode),
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

  Widget _buildThemeToggle(BuildContext context, bool isDarkMode, ThemeNotifier themeNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.getDetailBackground(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorder(isDarkMode),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getAccentBlueLight(isDarkMode),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.getAccentBlue(isDarkMode),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APP THEME',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryText(isDarkMode),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextDark(isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDarkMode,
              onChanged: (value) {
                themeNotifier.toggleTheme();
              },
              activeColor: AppTheme.getButton(isDarkMode),
              inactiveThumbColor: AppTheme.getSwitchInactive(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.logout, size: 22, color: AppTheme.getSnackBarError(isDarkMode)),
          label: Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.getSnackBarError(isDarkMode),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.getCard(isDarkMode),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: AppTheme.getAccentRedLight(isDarkMode),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shadowColor: AppTheme.getSnackBarError(isDarkMode).withOpacity(0.1),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: AppTheme.getCard(isDarkMode),
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
                          color: AppTheme.getAccentRedLight(isDarkMode),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout,
                          size: 40,
                          color: AppTheme.getSnackBarError(isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Ready to Leave?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryText(isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You'll be signed out of your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.getSecondaryText(isDarkMode),
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
                                side: BorderSide(
                                  color: AppTheme.getSwitchInactive(isDarkMode),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: AppTheme.getDetailBackground(isDarkMode),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: AppTheme.getTextMedium(isDarkMode),
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
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Failed to logout. Please try again.'),
                                      backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  color: AppTheme.getPrimaryText(!isDarkMode),
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