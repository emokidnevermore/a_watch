import 'package:flutter/material.dart';

import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/core/cache/recent_anime_cache.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'dart:async';

// Добавляем поддержку кастомного окна для десктопа
import 'dart:io' show Platform;

import 'package:window_manager/window_manager.dart';

/// Navigation section enum
enum NavigationSection {
  home,
  catalog,
  top100,
  collections,
  menu,
  recent, // Добавляем секцию для последнего аниме
}

/// App shell with responsive navigation
class AppShell extends StatefulWidget {
  final Widget child;
  final NavigationSection currentSection;
  final ValueChanged<NavigationSection> onSectionChanged;

  const AppShell({
    super.key,
    required this.child,
    required this.currentSection,
    required this.onSectionChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final RecentAnimeCache _cache;
  Anime? _recentAnime;
  late StreamSubscription<List<Anime>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    // _themeManager removed

    _cache = RecentAnimeCache();
    _loadRecentAnime();
    _listenToCacheChanges();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadRecentAnime() async {
    try {
      final animes = await _cache.getRecentAnimes();
      setState(() {
        _recentAnime = animes.isNotEmpty ? animes.first : null;
      });
    } catch (e) {
      // Ignore errors when loading recent anime
    }
  }

  void _listenToCacheChanges() {
    _streamSubscription = _cache.recentAnimesStream.listen((animes) {
      setState(() {
        _recentAnime = animes.isNotEmpty ? animes.first : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= DesignTokens.desktopMinWidth;

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          // Красивый нижний бордер с тенью
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar() as PreferredSizeWidget?,
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: widget.child,
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

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
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingLG,
              ),
              child: Row(
                children: [
                  // Logo and title
                  Row(
                    children: [
                      Icon(Icons.movie, size: 24, color: colorScheme.primary),
                      const SizedBox(width: DesignTokens.spacingSM),
                      Text(
                        'A-Watch',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: DesignTokens.spacingLG),

                  // Navigation tabs
                  Expanded(
                    child: Row(
                      children: [
                        _buildHeaderTab(
                          label: 'Главная',
                          section: NavigationSection.home,
                        ),
                        const SizedBox(
                          width: DesignTokens.spacingMD,
                        ), // Уменьшенный отступ
                        _buildHeaderTab(
                          label: 'Каталог',
                          section: NavigationSection.catalog,
                        ),
                        const SizedBox(
                          width: DesignTokens.spacingMD,
                        ), // Уменьшенный отступ
                        _buildHeaderTab(
                          label: 'Топ 100',
                          section: NavigationSection.top100,
                        ),
                        const SizedBox(
                          width: DesignTokens.spacingMD,
                        ), // Уменьшенный отступ
                        _buildHeaderTab(
                          label: 'Подборки',
                          section: NavigationSection.collections,
                        ),
                        const SizedBox(
                          width: DesignTokens.spacingMD,
                        ), // Уменьшенный отступ
                        // Recent anime tab
                        if (_recentAnime != null)
                          _buildRecentAnimeTab(_recentAnime!),
                      ],
                    ),
                  ),

                  // Settings button (icon only)
                  _buildHeaderIconButton(
                    icon: Icons.menu,
                    tooltip: 'Меню',
                    section: NavigationSection.menu,
                  ),

                  // Window controls for desktop
                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    const SizedBox(
                      width: DesignTokens.spacingMD,
                    ), // Уменьшенный отступ

                  if (Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    Row(
                      children: [
                        // Minimize button
                        _buildWindowControlButton(
                          icon: Icons.remove,
                          tooltip: '', // Убрана подсказка
                          onPressed: () async {
                            if (Platform.isWindows ||
                                Platform.isMacOS ||
                                Platform.isLinux) {
                              await windowManager.minimize();
                            }
                          },
                        ),

                        const SizedBox(width: 2), // Уменьшенный отступ
                        // Maximize/Restore button
                        _buildWindowControlButton(
                          icon: Icons.crop_square,
                          tooltip: '', // Убрана подсказка
                          onPressed: () async {
                            if (Platform.isWindows ||
                                Platform.isMacOS ||
                                Platform.isLinux) {
                              if (await windowManager.isMaximized()) {
                                await windowManager.unmaximize();
                              } else {
                                await windowManager.maximize();
                              }
                            }
                          },
                        ),

                        const SizedBox(width: 2), // Уменьшенный отступ
                        // Close button
                        _buildWindowControlButton(
                          icon: Icons.close,
                          tooltip: '', // Убрана подсказка
                          onPressed: () async {
                            if (Platform.isWindows ||
                                Platform.isMacOS ||
                                Platform.isLinux) {
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

  Widget _buildHeaderTab({
    required String label,
    required NavigationSection section,
    bool isSettings = false,
  }) {
    final isSelected = widget.currentSection == section;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSectionChanged(section),
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSettings
                ? DesignTokens.spacingMD
                : DesignTokens.spacingLG,
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTokens.fontSizeMD,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnimeTab(Anime anime) {
    final isSelected = widget.currentSection == NavigationSection.recent;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSectionChanged(NavigationSection.recent),
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
              // Mini poster
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    anime.poster,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: DesignTokens.spacingXS),

              // Title
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  anime.title,
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeSM,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWindowControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isClose = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              color: isClose
                  ? (theme.brightness == Brightness.dark
                        ? Colors.red[700]
                        : Colors.red[600])
                  : Colors
                        .transparent, // Фон только для закрытия, для остальных - только при наведении
            ),
            child: Icon(
              icon,
              size: 16,
              color: isClose
                  ? Colors.white
                  : colorScheme.secondary, // Цвет иконок
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required NavigationSection section,
  }) {
    final isSelected = widget.currentSection == section;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSectionChanged(section),
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

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.movie, size: 24, color: colorScheme.primary),
          const SizedBox(width: DesignTokens.spacingSM),
          Text(
            'A-Watch',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // TODO: Implement notifications
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: _getBottomNavigationIndex(widget.currentSection),
      onDestinationSelected: (index) {
        final section = _getSectionFromBottomIndex(index);
        widget.onSectionChanged(section);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Главная'),
        NavigationDestination(icon: Icon(Icons.explore), label: 'Каталог'),
        NavigationDestination(icon: Icon(Icons.leaderboard), label: 'Топ'),
        NavigationDestination(
          icon: Icon(Icons.collections),
          label: 'Подборки',
        ),
        NavigationDestination(icon: Icon(Icons.menu), label: 'Меню'),
      ],
    );
  }

  int _getBottomNavigationIndex(NavigationSection section) {
    switch (section) {
      case NavigationSection.home:
        return 0;
      case NavigationSection.catalog:
        return 1;
      case NavigationSection.top100:
        return 2;
      case NavigationSection.collections:
        return 3;
      case NavigationSection.menu:
        return 4;
      case NavigationSection.recent:
        return 0; // For mobile, recent anime goes to home
    }
  }

  NavigationSection _getSectionFromBottomIndex(int index) {
    switch (index) {
      case 0:
        return NavigationSection.home;
      case 1:
        return NavigationSection.catalog;
      case 2:
        return NavigationSection.top100;
      case 3:
        return NavigationSection.collections;
      case 4:
        return NavigationSection.menu;
      default:
        return NavigationSection.home;
    }
  }
}

/// Animated page transition
class AnimatedPageTransition extends PageRouteBuilder {
  final Widget page;

  AnimatedPageTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
        transitionDuration: DesignTokens.mediumDuration,
      );
}

/// Hero animation wrapper for cards
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final String heroTag;

  const AnimatedCard({super.key, required this.child, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      child: child,
    );
  }
}

/// Staggered animation for lists
class StaggeredListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationController controller;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(index * 0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(scale: animation.value, child: child),
        );
      },
      child: child,
    );
  }
}
