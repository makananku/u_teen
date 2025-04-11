import 'package:flutter/material.dart';
import '../../models/payment_method.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact(); // Haptic feedback added
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: widget.isSelected
              ? widget.method.primaryColor?.withOpacity(0.08)
              : Colors.white,
          elevation: widget.isSelected ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: widget.isSelected
                  ? widget.method.primaryColor ?? Colors.blue
                  : Colors.grey[300]!,
              width: widget.isSelected ? 1.8 : 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Logo with glowing effect when selected
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.method.primaryColor?.withOpacity(0.15)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: widget.method.primaryColor!
                                  .withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Image.asset(
                    widget.method.iconPath,
                    height: 36,
                    width: 36,
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
                              ? widget.method.primaryColor
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.method.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isSelected
                              ? widget.method.primaryColor?.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkmark with animation
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: widget.isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: widget.method.primaryColor ?? Colors.blue,
                          size: 28,
                        )
                      : SizedBox(width: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
