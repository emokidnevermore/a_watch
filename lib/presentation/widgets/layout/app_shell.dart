import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/core/cache/recent_anime_cache.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/home/presentation/pages/home_page.dart';
import 'package:a_watch/features/catalog/presentation/widgets/catalog_section.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:a_watch/features/top100/presentation/widgets/top100_section.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_bloc.dart';
import 'package:a_watch/presentation/pages/menu_page.dart';
import 'package:a_watch/presentation/widgets/anime_detail/anime_detail_widget.dart';
import 'package:a_watch/core/di/service_locator.dart';
import 'dart:async';

// Добавляем поддержку кастомного окна для десктопа

import 'navigation_section.dart';
import 'desktop_nav.dart';
import 'mobile_nav.dart';

/// App shell with responsive navigation and IndexedStack for main pages
class AppShell extends StatefulWidget {
  final String? initialAnimeUrl; // For opening specific anime in recent tab

  const AppShell({
    super.key,
    this.initialAnimeUrl,
  });

  // Static method to access AppShell state from anywhere in the app
  static _AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppShellState>();
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final RecentAnimeCache _cache;
  Anime? _recentAnime;
  late StreamSubscription<List<Anime>> _streamSubscription;

  // Current active section
  NavigationSection _currentSection = NavigationSection.home;

  // Current anime URL for recent tab
  final ValueNotifier<String?> _currentAnimeUrl = ValueNotifier<String?>(null);

  // Main pages that should stay alive
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _cache = RecentAnimeCache();
    _loadRecentAnime();
    _listenToCacheChanges();

    // Initialize pages that should stay alive
    _pages = [
      // Home page (index 0)
      PageStorage(
        bucket: PageStorageBucket(),
        key: const ValueKey('home_page'),
        child: const HomePage(),
      ),

      // Recent anime page (index 1)
      PageStorage(
        bucket: PageStorageBucket(),
        key: const ValueKey('recent_page'),
        child: _RecentAnimePage(valueNotifier: _currentAnimeUrl),
      ),

      // Catalog page (index 2)
      PageStorage(
        bucket: PageStorageBucket(),
        key: const ValueKey('catalog_page'),
        child: BlocProvider<CatalogBloc>(
          create: (context) => getIt<CatalogBloc>(),
          child: const CatalogSection(),
        ),
      ),

      // Top100 page (index 3)
      PageStorage(
        bucket: PageStorageBucket(),
        key: const ValueKey('top100_page'),
        child: BlocProvider<Top100Bloc>(
          create: (context) => getIt<Top100Bloc>(),
          child: const Top100Section(),
        ),
      ),

      // Menu page (index 4)
      PageStorage(
        bucket: PageStorageBucket(),
        key: const ValueKey('menu_page'),
        child: const MenuPage(),
      ),
    ];
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

  void _onSectionChanged(NavigationSection section) {
    setState(() {
      _currentSection = section;
    });
  }

  // Method to show specific anime in recent tab
  void showAnimeInRecentTab(String animeUrl) {
    setState(() {
      _currentAnimeUrl.value = animeUrl;
      _currentSection = NavigationSection.recent;
    });
  }

  int _getCurrentPageIndex() {
    switch (_currentSection) {
      case NavigationSection.home:
        return 0;
      case NavigationSection.recent:
        return 1;
      case NavigationSection.catalog:
        return 2;
      case NavigationSection.top100:
        return 3;
      case NavigationSection.menu:
        return 4;
    }
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
          DesktopNav(
            currentSection: _currentSection,
            onSectionChanged: _onSectionChanged,
            recentAnime: _recentAnime,
          ),
          Expanded(
            child: IndexedStack(
              index: _getCurrentPageIndex(),
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'A-Watch',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: MobileNav(
        currentSection: _currentSection,
        onSectionChanged: _onSectionChanged,
      ),
      body: IndexedStack(
        index: _getCurrentPageIndex(),
        children: _pages,
      ),
    );
  }
}

/// Dynamic page for recent anime that responds to URL changes
class _RecentAnimePage extends StatefulWidget {
  final ValueNotifier<String?> valueNotifier;

  const _RecentAnimePage({required this.valueNotifier});

  @override
  State<_RecentAnimePage> createState() => _RecentAnimePageState();
}

class _RecentAnimePageState extends State<_RecentAnimePage> {
  String? _currentUrl;
  final RecentAnimeCache _cache = RecentAnimeCache();
  bool _hasRecentAnime = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.valueNotifier.value;
    widget.valueNotifier.addListener(_onUrlChanged);
    _checkRecentAnime();
  }

  @override
  void dispose() {
    widget.valueNotifier.removeListener(_onUrlChanged);
    super.dispose();
  }

  void _onUrlChanged() {
    setState(() {
      _currentUrl = widget.valueNotifier.value;
    });
  }

  Future<void> _checkRecentAnime() async {
    final hasRecent = await _cache.hasRecentAnime();
    if (mounted) {
      setState(() {
        _hasRecentAnime = hasRecent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUrl != null) {
      // Specific anime URL provided - show that anime
      return AnimeDetailWidget(
        key: ValueKey(_currentUrl), // Force rebuild when URL changes
        animeUrl: _currentUrl!,
      );
    } else if (_hasRecentAnime) {
      // No specific URL but we have cached recent anime - show it
      return const AnimeDetailWidget(
        key: ValueKey('recent'), // Use consistent key for recent anime
      );
    } else {
      // No recent anime at all - show placeholder
      return const _NoRecentAnimePlaceholder();
    }
  }
}

/// Placeholder widget when no recent anime is available
class _NoRecentAnimePlaceholder extends StatelessWidget {
  const _NoRecentAnimePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет недавних просмотров',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Просмотренные аниме появятся здесь',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
