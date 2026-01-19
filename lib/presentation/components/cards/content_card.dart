import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/colors.dart';
import 'package:a_watch/core/theme/typography.dart';
import 'package:a_watch/core/theme/shadows.dart';
import 'package:a_watch/core/theme/borders.dart';

/// Базовая контентная карточка
/// Используется для отображения текстовой информации
class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;

  const ContentCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = enabled && onTap != null;

    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? AppColors.getSurfaceColor(brightness),
        elevation: elevation ?? (isEnabled ? 2 : 0),
        shadowColor: AppColors.shadow,
        borderRadius: borderRadius ?? AppBorders.radiusMD,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: borderRadius ?? AppBorders.radiusMD,
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.getSurfaceColor(brightness),
              borderRadius: borderRadius ?? AppBorders.radiusMD,
              border: Border.all(
                color: borderColor ?? AppColors.getBorderColor(brightness),
              ),
              boxShadow: AppShadows.getShadowList(shadowType),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Карточка с заголовком
class ContentCardWithTitle extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;
  final TextAlign? titleAlign;

  const ContentCardWithTitle({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.medium,
    this.titleAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return ContentCard(
      padding: EdgeInsets.zero,
      margin: margin,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      enabled: enabled,
      shadowType: shadowType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(brightness),
              borderRadius: BorderRadius.vertical(
                top: (borderRadius ?? AppBorders.radiusMD).topLeft,
              ),
              border: Border(
                bottom: BorderSide(
                  color: borderColor ?? AppColors.getBorderColor(brightness),
                ),
              ),
            ),
            child: Text(
              title,
              style: AppTypography.h5(brightness: brightness),
              textAlign: titleAlign,
            ),
          ),
          
          // Контент
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Карточка с действиями (actions)
class ContentCardWithActions extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;

  const ContentCardWithActions({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return ContentCardWithTitle(
      title: title,
      padding: EdgeInsets.zero,
      margin: margin,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      enabled: enabled,
      shadowType: shadowType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Контент
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: child,
          ),
          
          // Actions
          if (actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(brightness),
                borderRadius: BorderRadius.vertical(
                  bottom: (borderRadius ?? AppBorders.radiusMD).bottomLeft,
                ),
                border: Border(
                  top: BorderSide(
                    color: borderColor ?? AppColors.getBorderColor(brightness),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
        ],
      ),
    );
  }
}

/// Карточка с метками (badges)
class ContentCardWithBadges extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> badges;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;

  const ContentCardWithBadges({
    super.key,
    required this.title,
    required this.child,
    required this.badges,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return ContentCardWithTitle(
      title: title,
      padding: EdgeInsets.zero,
      margin: margin,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      enabled: enabled,
      shadowType: shadowType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Контент
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: child,
          ),
          
          // Badges
          if (badges.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(brightness),
                borderRadius: BorderRadius.vertical(
                  bottom: (borderRadius ?? AppBorders.radiusMD).bottomLeft,
                ),
                border: Border(
                  top: BorderSide(
                    color: borderColor ?? AppColors.getBorderColor(brightness),
                  ),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges,
              ),
            ),
        ],
      ),
    );
  }
}
