import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';

class BingoChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? dotColor;
  final bool hasDot;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const BingoChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.dotColor,
    this.hasDot = false,
    this.fontSize = 11,
    this.padding,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  const BingoChip.online({
    super.key,
    this.label = 'Online',
    this.fontSize = 11,
    this.padding,
  })  : backgroundColor = const Color(0xFFE8F5E9),
        textColor = const Color(0xFF2E7D32),
        dotColor = AppColors.success,
        hasDot = true,
        isSelected = false,
        onTap = null,
        icon = null;

  const BingoChip.live({
    super.key,
    this.label = 'LIVE',
    this.fontSize = 10,
    this.padding,
  })  : backgroundColor = const Color(0xFFEFEFEF),
        textColor = const Color(0xFF333333),
        dotColor = null,
        hasDot = false,
        isSelected = false,
        onTap = null,
        icon = null;

  const BingoChip.urgent({
    super.key,
    required this.label,
    this.fontSize = 10,
    this.padding,
  })  : backgroundColor = const Color(0xFFFFEBEE),
        textColor = AppColors.error,
        dotColor = AppColors.error,
        hasDot = true,
        isSelected = false,
        onTap = null,
        icon = null;

  const BingoChip.lime({
    super.key,
    required this.label,
    this.fontSize = 11,
    this.padding,
  })  : backgroundColor = AppColors.limeAccent,
        textColor = AppColors.textPrimaryLight,
        dotColor = null,
        hasDot = false,
        isSelected = false,
        onTap = null,
        icon = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;

    if (isSelected) {
      bg = isDark ? AppColors.limeAccent : AppColors.darkPill;
      fg = isDark ? AppColors.textPrimaryLight : Colors.white;
    } else {
      bg = backgroundColor ?? (isDark ? const Color(0xFF252B30) : const Color(0xFFF0F3ED));
      fg = textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: fg),
            const SizedBox(width: 5),
          ],
          if (hasDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor ?? fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
