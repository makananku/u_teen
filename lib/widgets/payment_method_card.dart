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
  late Animation<Color?> _colorAnimation;

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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _elevationAnimation = Tween<double>(
      begin: isDarkMode ? 0 : 2,
      end: isDarkMode ? 0 : 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _colorAnimation = ColorTween(
      begin: AppTheme.getCard(isDarkMode),
      end: widget.method.primaryColor?.withOpacity(0.05) ??
          AppTheme.getButton(isDarkMode).withOpacity(0.05),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: _elevationAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: widget.isSelected
                    ? (widget.method.primaryColor?.withOpacity(0.5) ??
                        AppTheme.getButton(isDarkMode).withOpacity(0.5))
                    : AppTheme.getDivider(isDarkMode),
                width: widget.isSelected ? 1.2 : 0.8,
              ),
            ),
            color: _colorAnimation.value,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: widget.isSelected
                            ? (widget.method.primaryColor?.withOpacity(0.1) ??
                                AppTheme.getButton(isDarkMode).withOpacity(0.1))
                            : AppTheme.getDivider(isDarkMode),
                      ),
                      child: Image.asset(
                        widget.method.iconPath,
                        height: 28,
                        width: 28,
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: widget.isSelected
                                  ? (widget.method.primaryColor ??
                                      AppTheme.getButton(isDarkMode))
                                  : AppTheme.getPrimaryText(isDarkMode),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.method.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.isSelected
                                  ? (widget.method.primaryColor?.withOpacity(0.8) ??
                                      AppTheme.getButton(isDarkMode).withOpacity(0.8))
                                  : AppTheme.getSecondaryText(isDarkMode),
                            ),
                          ),
                          if (widget.method.supportsTopUp) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (widget.method.primaryColor ??
                                        AppTheme.getButton(isDarkMode))
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Instant Transfer',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: widget.method.primaryColor ??
                                      AppTheme.getButton(isDarkMode),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                      child: widget.isSelected
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: widget.method.primaryColor ??
                                    AppTheme.getButton(isDarkMode),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: AppTheme.getPrimaryText(!isDarkMode),
                                size: 16,
                              ),
                            )
                          : Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.getDivider(isDarkMode),
                                  width: 1.5,
                                ),
                              ),
                            ),
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