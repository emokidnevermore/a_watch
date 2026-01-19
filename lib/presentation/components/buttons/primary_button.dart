import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/colors.dart';
import 'package:a_watch/core/theme/typography.dart';
import 'package:a_watch/core/theme/borders.dart';

/// Primary кнопка - основной акцентный элемент
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final IconData? icon;
  final double? fontSize;
  final FontWeight? fontWeight;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.margin,
    this.icon,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = onPressed != null && !isLoading;

    return Container(
      margin: margin,
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: Size(width ?? double.infinity, height!),
          shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusMD),
        ),
        child: _buildContent(context, brightness),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentContrast),
              const SizedBox(width: 8),
            ],
          ),
        Text(
          text,
          style:
              AppTypography.buttonLarge(
                brightness: brightness,
                color: AppColors.accentContrast,
              ).copyWith(
                fontSize: fontSize,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
        ),
        if (isLoading) const SizedBox(width: 8),
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentContrast,
              ),
            ),
          ),
      ],
    );
  }
}

/// Secondary кнопка - вторичный элемент с outline
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.margin,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = onPressed != null && !isLoading;

    return Container(
      margin: margin,
      child: FilledButton.tonal(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: Size(width ?? double.infinity, height!),
          shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusMD),
        ),
        child: _buildContent(context, brightness),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    textColor ??
                    AppColors.getTextColor(brightness, type: TextType.primary),
              ),
              const SizedBox(width: 8),
            ],
          ),
        Text(
          text,
          style: AppTypography.buttonLarge(
            brightness: brightness,
            color: textColor,
          ),
        ),
        if (isLoading) const SizedBox(width: 8),
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ??
                    AppColors.getTextColor(brightness, type: TextType.primary),
              ),
            ),
          ),
      ],
    );
  }
}

/// Ghost кнопка - прозрачный элемент
class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final IconData? icon;
  final Color? textColor;

  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.margin,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = onPressed != null && !isLoading;

    return Container(
      margin: margin,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor:
              textColor ??
              AppColors.getTextColor(brightness, type: TextType.primary),
          elevation: 0,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: Size(width ?? double.infinity, height!),
          shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusMD),
          side: isEnabled ? BorderSide.none : AppBorderStyles.disabled,
        ),
        child: _buildContent(context, brightness),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    textColor ??
                    AppColors.getTextColor(brightness, type: TextType.primary),
              ),
              const SizedBox(width: 8),
            ],
          ),
        Text(
          text,
          style: AppTypography.buttonLarge(
            brightness: brightness,
            color: textColor,
          ),
        ),
        if (isLoading) const SizedBox(width: 8),
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ??
                    AppColors.getTextColor(brightness, type: TextType.primary),
              ),
            ),
          ),
      ],
    );
  }
}

/// Круглая кнопка (FAB)
class RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double elevation;

  const RoundButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.accentPrimary,
      foregroundColor: iconColor ?? AppColors.accentContrast,
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusRound),
      child: Icon(icon, size: 24, color: iconColor ?? AppColors.accentContrast),
    );
  }
}
