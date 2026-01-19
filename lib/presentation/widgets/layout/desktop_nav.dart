import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/core/theme/colors.dart';
import 'package:a_watch/presentation/widgets/layout/navigation_section.dart';

import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

/// Desktop navigation header
class DesktopNav extends StatelessWidget {
  final NavigationSection currentSection;
  final ValueChanged<NavigationSection> onSectionChanged;
  final Anime? recentAnime;

  const DesktopNav({
    super.key,
    required this.currentSection,
    required this.onSectionChanged,
    this.recentAnime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      onEnter: (_) {
        // Начинаем слушать клики при наведении
      },
      onExit: (_) {
        // Прекращаем слушать клики при уходе
      },
      child: GestureDetector(
        onPanStart: (_) async {
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            await windowManager.startDragging();
          }
        },
        child: Container(
        height: 64,
        color: colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingLG),
            child: Row(
              children: [
                // Logo and title
                Row(
                  children: [
                    Icon(
                      Icons.movie,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: DesignTokens.spacingSM),
                    AppH5(
                      'A-Watch',
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                
                const SizedBox(width: DesignTokens.spacingLG),

                // Navigation tabs
                Expanded(
                  child: Row(
                    children: [
                      _buildHeaderTab(context,
                        label: 'Главная',
                        section: NavigationSection.home,
                      ),
                      const SizedBox(width: DesignTokens.spacingMD),
                      _buildHeaderTab(context,
                        label: 'Каталог',
                        section: NavigationSection.catalog,
                      ),
                      const SizedBox(width: DesignTokens.spacingMD),
                      _buildHeaderTab(context,
                        label: 'Топ 100',
                        section: NavigationSection.top100,
                      ),
                      const SizedBox(width: DesignTokens.spacingMD),

                      const SizedBox(width: DesignTokens.spacingMD),
                      // Recent anime tab - show if we have recent anime OR we're on the recent section
                      if (recentAnime != null || currentSection == NavigationSection.recent)
                        _buildRecentAnimeTab(context, recentAnime),
                    ],
                  ),
                ),

                // Settings button (icon only)
                _buildHeaderIconButton(context,
                  icon: Icons.menu,
                  tooltip: 'Меню',
                  section: NavigationSection.menu,
                ),

                // Window controls for desktop
                if (isDesktop)
                  const SizedBox(width: DesignTokens.spacingMD),

                if (isDesktop)
                  Row(
                    children: [
                      // Minimize button
                      _buildWindowControlButton(context,
                        icon: Icons.remove,
                        tooltip: '',
                        onPressed: () async {
                          if (isDesktop) {
                            await windowManager.minimize();
                          }
                        },
                      ),

                      const SizedBox(width: 2),

                      // Maximize/Restore button
                      _buildWindowControlButton(context,
                        icon: Icons.crop_square,
                        tooltip: '',
                        onPressed: () async {
                          if (isDesktop) {
                            if (await windowManager.isMaximized()) {
                              await windowManager.unmaximize();
                            } else {
                              await windowManager.maximize();
                            }
                          }
                        },
                      ),

                      const SizedBox(width: 2),

                      // Close button
                      _buildWindowControlButton(context,
                        icon: Icons.close,
                        tooltip: '',
                        isClose: true,
                        onPressed: () async {
                          if (isDesktop) {
                            await windowManager.close();
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeaderTab(BuildContext context, {
    required String label,
    required NavigationSection section,
  }) {
    final isSelected = currentSection == section;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSectionChanged(section),
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingLG,
            vertical: DesignTokens.spacingSM,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: AppBodyMedium(
            label,
            color: isSelected ? colorScheme.primary : colorScheme.secondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnimeTab(BuildContext context, Anime? anime) {
    final isSelected = currentSection == NavigationSection.recent;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSectionChanged(NavigationSection.recent),
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMD,
            vertical: DesignTokens.spacingSM,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Mini poster or icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[200],
                ),
                child: anime != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          anime.poster,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 16),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.history, color: Colors.grey, size: 16),
                      ),
              ),

              const SizedBox(width: DesignTokens.spacingXS),

              // Title or placeholder
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: AppBodySmall(
                  anime?.title ?? 'Последнее просмотренное',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: isSelected ? colorScheme.primary : colorScheme.secondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWindowControlButton(BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isClose = false,
  }) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent, // No red background for close button
            ),
            child: Icon(
              icon,
              size: 16,
              color: isClose ? Colors.white : AppColors.getTextColor(theme.brightness, type: TextType.secondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(BuildContext context, {
    required IconData icon,
    required String tooltip,
    required NavigationSection section,
  }) {
    final isSelected = currentSection == section;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSectionChanged(section),
          borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacingSM),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
