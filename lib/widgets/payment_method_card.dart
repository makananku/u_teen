import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment_method.dart';
import '../../providers/theme_notifier.dart';
import '../../utils/app_theme.dart';
import 'package:flutter/services.dart';

class PaymentMethodCard extends StatefulWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _PaymentMethodCardState createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<BorderRadius?> _borderRadiusAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _initializeAnimations();

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  void _initializeAnimations() {
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    final primaryColor = widget.method.primaryColor ?? AppTheme.getAccentPrimaryBlue(isDarkMode);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _elevationAnimation = Tween<double>(
      begin: isDarkMode ? 0 : 1,
      end: isDarkMode ? 2 : 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _borderRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(12),
      end: BorderRadius.circular(16),
    ).animate(_controller);

    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: primaryColor.withOpacity(0.3),
    ).animate(_controller);

    _backgroundColorAnimation = ColorTween(
      begin: AppTheme.getCard(isDarkMode),
      end: isDarkMode 
          ? AppTheme.getDark2D(isDarkMode).withOpacity(0.8)
          : Colors.white.withOpacity(0.9),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant PaymentMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      widget.isSelected ? _controller.forward() : _controller.reverse();
    }

    if (widget.method != oldWidget.method) {
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final primaryColor = widget.method.primaryColor ?? AppTheme.getAccentPrimaryBlue(isDarkMode);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: _elevationAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: _borderRadiusAnimation.value ?? BorderRadius.circular(12),
              side: BorderSide(
                color: _borderColorAnimation.value!,
                width: 1.5,
              ),
            ),
            color: _backgroundColorAnimation.value,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              borderRadius: _borderRadiusAnimation.value,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: widget.isSelected
                            ? primaryColor.withOpacity(0.08)
                            : AppTheme.getDivider(isDarkMode).withOpacity(0.2),
                        border: Border.all(
                          color: widget.isSelected
                              ? primaryColor.withOpacity(0.3)
                              : AppTheme.getDivider(isDarkMode).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        widget.method.iconPath,
                        height: 24,
                        width: 24,
                        color: widget.isSelected
                            ? primaryColor
                            : AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.method.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: widget.isSelected
                                  ? primaryColor
                                  : AppTheme.getPrimaryText(isDarkMode),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.method.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.isSelected
                                  ? primaryColor.withOpacity(0.8)
                                  : AppTheme.getSecondaryText(isDarkMode),
                            ),
                          ),
                          if (widget.method.supportsTopUp) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Instant Transfer',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isSelected
                              ? primaryColor
                              : AppTheme.getDivider(isDarkMode),
                          width: widget.isSelected ? 8 : 1.5,
                        ),
                      ),
                      child: widget.isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.getPrimaryText(!isDarkMode),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}