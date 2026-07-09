import 'package:flutter/material.dart';
import '../app_colors.dart';

/// زر مخصص بتصميم مرح ومناسب للأطفال
/// يدعم أيقونة نصية (إيموجي) ونص، مع تأثير ضغط بسيط
class CustomButton extends StatefulWidget {
  final String label;
  final String? icon;
  final Color color;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double fontSize;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.onPressed,
    this.width = double.infinity,
    this.height = 56,
    this.fontSize = 18,
    this.isOutlined = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final Color effectiveColor = isEnabled ? widget.color : Colors.grey.shade400;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.white : effectiveColor,
            borderRadius: BorderRadius.circular(widget.height / 2.5),
            border: widget.isOutlined
                ? Border.all(color: effectiveColor, width: 2)
                : null,
            boxShadow: widget.isOutlined || !isEnabled
                ? []
                : [
                    BoxShadow(
                      color: effectiveColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Text(widget.icon!, style: TextStyle(fontSize: widget.fontSize + 4)),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isOutlined ? effectiveColor : Colors.white,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
