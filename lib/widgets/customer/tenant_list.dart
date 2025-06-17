import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Ultra Modern Tenant List with:
/// - Asymmetric card design with layered elements
/// - Floating effect with dynamic shadows
/// - Vibrant yet tasteful color accents
/// - Interactive 3D tilt effect
/// - Custom shape clipping
class TenantList extends StatefulWidget {
  final Function(String, String, String, String, String) onItemTap;

  const TenantList({
    Key? key,
    required this.onItemTap,
  }) : super(key: key);

  @override
  _TenantListState createState() => _TenantListState();
}

class _TenantListState extends State<TenantList> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchTenants() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();
      final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      final tenantMap = <String, Map<String, dynamic>>{};
      for (var product in products) {
        if (!tenantMap.containsKey(product.tenantName)) {
          tenantMap[product.tenantName] = {
            'tenantName': product.tenantName,
            'sellerEmail': product.sellerEmail,
            'itemCount': 0,
            'sampleImage': product.imgBase64.isNotEmpty ? product.imgBase64 : '',
          };
        }
        tenantMap[product.tenantName]!['itemCount'] += 1;
      }
      return tenantMap.values.toList();
    } catch (e) {
      debugPrint('TenantList: Error fetching tenants: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTenants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.getAccentPurple(isDarkMode),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  'Failed to load vendors',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SizedBox(
              height: 240,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 40,
                      color: AppTheme.getSecondaryText(isDarkMode),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No vendors available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final tenants = snapshot.data!;
          return SizedBox(
            height: 260, // Extra space for floating effect
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenants[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateX(-0.03), // Slight upward tilt
                    alignment: Alignment.center,
                    child: TenantCard3D(
                      tenantName: tenant['tenantName'] ?? '',
                      itemCount: tenant['itemCount'] ?? 0,
                      imgBase64: tenant['sampleImage'] ?? '',
                      sellerEmail: tenant['sellerEmail'] ?? '',
                      onTap: () {
                        widget.onItemTap(
                          tenant['tenantName'] ?? '',
                          '',
                          tenant['sampleImage'] ?? '',
                          '',
                          tenant['sellerEmail'] ?? '',
                        );
                      },
                      index: index,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TenantCard3D extends StatefulWidget {
  final String tenantName;
  final int itemCount;
  final String imgBase64;
  final String sellerEmail;
  final VoidCallback onTap;
  final int index;

  const TenantCard3D({
    Key? key,
    required this.tenantName,
    required this.itemCount,
    required this.imgBase64,
    required this.sellerEmail,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _TenantCard3DState createState() => _TenantCard3DState();
}

class _TenantCard3DState extends State<TenantCard3D> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  // Color variations based on index
  final List<Color> _accentColors = [
    const Color(0xFF6C63FF),
    const Color(0xFF00BFA5),
    const Color(0xFFF50057),
    const Color(0xFF651FFF),
    const Color(0xFF00C853),
  ];

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutBack,
    ));
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutQuad,
    ));
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: -0.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutBack,
    ));
    _colorAnimation = ColorTween(
      begin: _accentColors[widget.index % _accentColors.length].withOpacity(0.2),
      end: _accentColors[widget.index % _accentColors.length].withOpacity(0.4),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutQuad,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isHovered = false);
    _hoverController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('TenantCard3D: Error decoding Base64 for ${widget.tenantName}: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final theme = Theme.of(context);
    final accentColor = _accentColors[widget.index % _accentColors.length];

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _elevationAnimation,
        _rotateAnimation,
        _colorAnimation,
      ]),
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateZ(_rotateAnimation.value),
          alignment: Alignment.center,
          child: Container(
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getShadow(isDarkMode)
                      .withOpacity(0.3 * _elevationAnimation.value/16),
                  blurRadius: 20 * _elevationAnimation.value/8,
                  spreadRadius: 1 * _elevationAnimation.value/8,
                  offset: Offset(0, 10 * _elevationAnimation.value/8),
                ),
              ],
            ),
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Stack(
                children: [
                  // Background shape
                  ClipPath(
                    clipper: _DiagonalClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _colorAnimation.value!,
                            AppTheme.getCard(isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor image with floating effect
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getShadow(isDarkMode)
                                      .withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: widget.imgBase64.isNotEmpty
                                  ? Image.memory(
                                      _decodeBase64(widget.imgBase64),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                    )
                                  : _buildPlaceholder(),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Vendor name with accent underline
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tenantName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getPrimaryText(isDarkMode),
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              height: 3,
                              width: 40,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Item count and CTA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.itemCount} items',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.getSecondaryText(isDarkMode),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Container(
      color: AppTheme.getDivider(isDarkMode),
      child: Center(
        child: Icon(
          Icons.store_mall_directory_rounded,
          size: 40,
          color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.3),
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}