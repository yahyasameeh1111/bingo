import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radii.dart';

enum BingoButtonType { primary, secondary, outline, lime, destructive }
typedef BingoButtonVariant = BingoButtonType;

enum BingoButtonSize { small, medium, large }

class BingoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BingoButtonType type;
  final dynamic icon; // Can be IconData or Widget
  final Widget? trailing;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BingoButtonSize size;

  const BingoButton({
    super.key,
    required this.label,
    required this.onPressed,
    BingoButtonType type = BingoButtonType.primary,
    BingoButtonVariant? variant,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.size = BingoButtonSize.medium,
  }) : type = variant ?? type;

  const BingoButton.lime({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.size = BingoButtonSize.medium,
  }) : type = BingoButtonType.lime;

  const BingoButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.size = BingoButtonSize.medium,
  }) : type = BingoButtonType.secondary;

  const BingoButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.size = BingoButtonSize.medium,
  }) : type = BingoButtonType.outline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    switch (type) {
      case BingoButtonType.primary:
        bg = isDark ? AppColors.limeAccent : AppColors.darkPill;
        fg = isDark ? AppColors.textPrimaryLight : AppColors.darkPillText;
        break;
      case BingoButtonType.lime:
        bg = AppColors.limeAccent;
        fg = AppColors.textPrimaryLight;
        break;
      case BingoButtonType.secondary:
      case BingoButtonType.outline:
        bg = isDark ? AppColors.cardDark : AppColors.cardLight;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        border = Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        );
        break;
      case BingoButtonType.destructive:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        border = Border.all(color: AppColors.error.withValues(alpha: 0.3));
        break;
    }

    double resolvedHeight;
    double fontSize;
    EdgeInsetsGeometry resolvedPadding;

    switch (size) {
      case BingoButtonSize.small:
        resolvedHeight = height ?? 38.0;
        fontSize = 13.0;
        resolvedPadding = padding ?? const EdgeInsets.symmetric(horizontal: 14);
        break;
      case BingoButtonSize.large:
        resolvedHeight = height ?? 58.0;
        fontSize = 16.0;
        resolvedPadding = padding ?? const EdgeInsets.symmetric(horizontal: 28);
        break;
      case BingoButtonSize.medium:
        resolvedHeight = height ?? 50.0;
        fontSize = 14.5;
        resolvedPadding = padding ?? const EdgeInsets.symmetric(horizontal: 22);
        break;
    }

    Widget? iconWidget;
    if (icon != null) {
      if (icon is IconData) {
        iconWidget = Icon(icon as IconData, size: fontSize + 4, color: fg);
      } else if (icon is Widget) {
        iconWidget = icon as Widget;
      }
    }

    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget != null) ...[
                iconWidget,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          );

    return SizedBox(
      width: width,
      height: resolvedHeight,
      child: Material(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: AppRadii.pillRadius,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadii.pillRadius,
          child: Container(
            padding: resolvedPadding,
            decoration: BoxDecoration(
              borderRadius: AppRadii.pillRadius,
              border: border,
            ),
            alignment: Alignment.center,
            child: buttonChild,
          ),
        ),
      ),
    );
  }
}

class BingoIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool hasBadge;
  final Color badgeColor;

  const BingoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 46,
    this.backgroundColor,
    this.borderColor,
    this.hasBadge = false,
    this.badgeColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final border = borderColor ?? (isDark ? AppColors.borderDark : AppColors.borderLight);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Material(
            color: bg,
            shape: CircleBorder(
              side: BorderSide(color: border, width: 1),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Center(child: icon),
            ),
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: bg, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
