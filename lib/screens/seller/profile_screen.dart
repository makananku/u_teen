import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/auth/logout_service.dart'; // Added for logout service
import 'package:u_teen/providers/order_provider.dart';
import 'package:u_teen/providers/rating_provider.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/screens/login_screen.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/utils/app_theme.dart';
import 'package:u_teen/widgets/seller/custom_bottom_navigation.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  bool _showBusinessInfo = false;
  bool _showStatisticInfo = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Theme(
      data: themeNotifier.currentTheme,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: AppTheme.getBackground(isDarkMode),
          appBar: AppBar(
            title: Text(
              'Merchant Profile',
              style: TextStyle(
                color: AppTheme.getPrimaryText(isDarkMode),
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
                    _buildProfileHeader(context),
                    const SizedBox(height: 16),
                    _buildBusinessStats(context),
                    const SizedBox(height: 16),
                    _buildAccountDetails(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SellerCustomBottomNavigation(
                  selectedIndex: NavIndices.profile,
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final tenantName = authProvider.tenantName ?? 'Merchant';
    final email = authProvider.sellerEmail ?? 'No Email';
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.getBorder(isDarkMode),
                    width: 3,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getAccentPurple(isDarkMode),
                      AppTheme.getAccentPurpleVariant(isDarkMode),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/merchant_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.storefront,
                      size: 40,
                      color: AppTheme.getPrimaryText(!isDarkMode),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getSnackBarSuccess(isDarkMode),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.getCard(isDarkMode),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.verified,
                  size: 16,
                  color: AppTheme.getPrimaryText(!isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tenantName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.getPrimaryText(isDarkMode),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getSecondaryText(isDarkMode),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBusinessStats(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ratingsProvider = Provider.of<RatingProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final merchantEmail = authProvider.sellerEmail ?? '';
    final averageRating = ratingsProvider.getAverageFoodRating(merchantEmail);
    final totalSales = orderProvider.getCompletedOrdersForMerchant(merchantEmail).length;
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleInfo('statistic'),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.getInfoBackground(isDarkMode).withOpacity(0.5),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                ),
              ),
            ],
          ),
          if (_showStatisticInfo)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getDetailBackground(isDarkMode),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Statistics are updated daily at midnight',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Sales',
                  totalSales.toString(),
                  Icons.trending_up,
                  AppTheme.getSnackBarSuccess(isDarkMode),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Rating',
                  averageRating.toStringAsFixed(1),
                  Icons.star_rate,
                  AppTheme.getRating(isDarkMode),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Products',
                  '24',
                  Icons.fastfood,
                  AppTheme.getAccentPurple(isDarkMode),
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    bool showFullTitle = false;
    bool showFullValue = false;

    return StatefulBuilder(
      builder: (context, setState) {
        void showFullText(String type) {
          setState(() {
            if (type == 'title') {
              showFullTitle = true;
            } else {
              showFullValue = true;
            }
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                if (type == 'title') {
                  showFullTitle = false;
                } else {
                  showFullValue = false;
                }
              });
            }
          });
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDarkMode ? 0.3 : 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => showFullText('title'),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                        overflow: showFullTitle ? null : TextOverflow.ellipsis,
                        maxLines: showFullTitle ? null : 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => showFullText('value'),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: showFullValue ? null : TextOverflow.ellipsis,
                  maxLines: showFullValue ? null : 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountDetails(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final sellerNim = authProvider.sellerNim ?? 'Not Available';
    final phoneNumber = authProvider.user?.phoneNumber ?? 'Not Available';
    final isDarkMode = themeNotifier.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleInfo('business'),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.getInfoBackground(isDarkMode).withOpacity(0.5),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                ),
              ),
            ],
          ),
          if (_showBusinessInfo)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getDetailBackground(isDarkMode),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Update your business details in the UMN Merchant Portal',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getSecondaryText(isDarkMode),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.badge_outlined,
            title: 'MERCHANT ID',
            value: sellerNim,
            iconColor: AppTheme.getAccentPurpleVariant(isDarkMode),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.phone_android_outlined,
            title: 'CONTACT NUMBER',
            value: phoneNumber,
            iconColor: AppTheme.getAccentCyan(isDarkMode),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildDetailItem(
            icon: Icons.email_outlined,
            title: 'BUSINESS EMAIL',
            value: authProvider.sellerEmail ?? 'Not Available',
            iconColor: AppTheme.getAccentPink(isDarkMode),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          _buildDarkModeToggle(context, isDarkMode, themeNotifier),
          const SizedBox(height: 16),
          _buildLogoutButton(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getDetailBackground(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorder(isDarkMode),
          width: 1,
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
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getPrimaryText(isDarkMode),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context, bool isDarkMode, ThemeNotifier themeNotifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getDetailBackground(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorder(isDarkMode),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.getAccentPurple(isDarkMode).withOpacity(isDarkMode ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.getAccentPurple(isDarkMode),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THEME',
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
                    fontSize: 14,
                    color: AppTheme.getPrimaryText(isDarkMode),
                    fontWeight: FontWeight.w600,
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
            activeColor: AppTheme.getAccentPurple(isDarkMode),
            inactiveThumbColor: AppTheme.getBorder(isDarkMode),
          ),
        ],
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
          onPressed: () async {
            final success = await LogoutService.showLogoutDialog(context);
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Failed to logout. Please try again.'),
                  backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _toggleInfo(String type) {
    setState(() {
      if (type == 'business') {
        _showBusinessInfo = !_showBusinessInfo;
      } else {
        _showStatisticInfo = !_showStatisticInfo;
      }
    });
  }
}