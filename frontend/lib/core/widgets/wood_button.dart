import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum WoodButtonVariant { primary, secondary, gold, outline, text }

class WoodButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final WoodButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const WoodButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = WoodButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  State<WoodButton> createState() => _WoodButtonState();
}

class _WoodButtonState extends State<WoodButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case WoodButtonVariant.primary:
        bgColor = _isHovered ? AppColors.darkWalnut : AppColors.espresso;
        textColor = Colors.white;
        break;
      case WoodButtonVariant.secondary:
        bgColor = _isHovered ? AppColors.lightWood : AppColors.naturalWood;
        textColor = Colors.white;
        break;
      case WoodButtonVariant.gold:
        bgColor = _isHovered ? AppColors.antiqueGold : AppColors.warmGold;
        textColor = AppColors.deepEbony;
        break;
      case WoodButtonVariant.outline:
        bgColor = _isHovered ? AppColors.softBeige.withOpacity(0.3) : Colors.transparent;
        textColor = AppColors.espresso;
        borderSide = const BorderSide(color: AppColors.espresso, width: 1.2);
        break;
      case WoodButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = _isHovered ? AppColors.naturalWood : AppColors.espresso;
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed == null || widget.isLoading
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.onPressed == null ? AppColors.softBeige : bgColor,
          borderRadius: BorderRadius.circular(6),
          border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
          boxShadow: _isHovered && widget.variant != WoodButtonVariant.text && widget.onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.espresso.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(6),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: textColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: AppTypography.buttonText(color: textColor),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
