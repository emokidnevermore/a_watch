import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/colors.dart';
import 'package:a_watch/core/theme/typography.dart';
import 'package:a_watch/core/theme/shadows.dart';
import 'package:a_watch/core/theme/borders.dart';

/// Карточка с изображением и контентом
class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? imageHeight;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;
  final BoxFit imageFit;

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.margin,
    this.height,
    this.imageHeight,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.imageCard,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = enabled && onTap != null;

    return Container(
      margin: margin,
      child: Material(
        color: AppColors.getSurfaceColor(brightness),
        elevation: isEnabled ? 2 : 0,
        shadowColor: AppColors.shadow,
        borderRadius: borderRadius ?? AppBorders.radiusMD,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: borderRadius ?? AppBorders.radiusMD,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(brightness),
              borderRadius: borderRadius ?? AppBorders.radiusMD,
              border: Border.all(color: AppColors.getBorderColor(brightness)),
              boxShadow: AppShadows.getShadowList(shadowType),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Изображение
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: (borderRadius ?? AppBorders.radiusMD).topLeft,
                  ),
                  child: Image.network(
                    imageUrl,
                    height: imageHeight ?? 120,
                    fit: imageFit,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight ?? 120,
                        color: AppColors.getSurfaceColor(brightness),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight ?? 120,
                        color: AppColors.getSurfaceColor(brightness),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 32),
                        ),
                      );
                    },
                  ),
                ),

                // Контент
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.bodyLarge(
                                brightness: brightness,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle != null) const SizedBox(height: 2),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: AppTypography.caption(
                                  brightness: brightness,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),

                      if (trailing != null) const SizedBox(width: 8),

                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка с изображением и метками
class ImageCardWithBadges extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final List<Widget> badges;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? imageHeight;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;
  final BoxFit imageFit;

  const ImageCardWithBadges({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.badges,
    this.margin,
    this.height,
    this.imageHeight,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.imageCard,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = enabled && onTap != null;

    return Container(
      margin: margin,
      child: Material(
        color: AppColors.getSurfaceColor(brightness),
        elevation: isEnabled ? 2 : 0,
        shadowColor: AppColors.shadow,
        borderRadius: borderRadius ?? AppBorders.radiusMD,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: borderRadius ?? AppBorders.radiusMD,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(brightness),
              borderRadius: borderRadius ?? AppBorders.radiusMD,
              border: Border.all(color: AppColors.getBorderColor(brightness)),
              boxShadow: AppShadows.getShadowList(shadowType),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Изображение
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: (borderRadius ?? AppBorders.radiusMD).topLeft,
                  ),
                  child: Image.network(
                    imageUrl,
                    height: imageHeight ?? 120,
                    fit: imageFit,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight ?? 120,
                        color: AppColors.getSurfaceColor(brightness),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight ?? 120,
                        color: AppColors.getSurfaceColor(brightness),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 32),
                        ),
                      );
                    },
                  ),
                ),

                // Контент
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge(brightness: brightness),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) const SizedBox(height: 2),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTypography.caption(brightness: brightness),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Badges
                if (badges.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Wrap(spacing: 6, runSpacing: 6, children: badges),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Круглая карточка с изображением
class RoundImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double size;
  final VoidCallback? onTap;
  final bool enabled;
  final ShadowType shadowType;

  const RoundImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.size = 80,
    this.onTap,
    this.enabled = true,
    this.shadowType = ShadowType.medium,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEnabled = enabled && onTap != null;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.getSurfaceColor(brightness),
        elevation: isEnabled ? 2 : 0,
        shadowColor: AppColors.shadow,
        borderRadius: AppBorders.radiusRound,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: AppBorders.radiusRound,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(brightness),
              borderRadius: AppBorders.radiusRound,
              border: Border.all(color: AppColors.getBorderColor(brightness)),
              boxShadow: AppShadows.getShadowList(shadowType),
            ),
            child: Stack(
              children: [
                // Изображение
                ClipRRect(
                  borderRadius: AppBorders.radiusRound,
                  child: Image.network(
                    imageUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: size,
                        height: size,
                        color: AppColors.getSurfaceColor(brightness),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: size,
                        height: size,
                        color: AppColors.getSurfaceColor(brightness),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 24),
                        ),
                      );
                    },
                  ),
                ),

                // Тень для текста
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: size * 0.3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Текст
                Positioned(
                  bottom: 6,
                  left: 8,
                  right: 8,
                  child: Text(
                    title,
                    style: AppTypography.caption(
                      brightness: brightness,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
