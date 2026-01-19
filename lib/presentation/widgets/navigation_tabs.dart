import 'dart:developer';
import 'dart:async';

import 'package:a_watch/core/cache/recent_anime_cache.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:flutter/material.dart';

class NavigationTabs extends StatefulWidget {
  final Function(Anime) onTabTap;
  final Function() onClearTabs;
  final Function(Anime)? onAnimeViewed; // New callback for when anime is viewed

  const NavigationTabs({
    super.key,
    required this.onTabTap,
    required this.onClearTabs,
    this.onAnimeViewed,
  });

  @override
  State<NavigationTabs> createState() => _NavigationTabsState();
}

class _NavigationTabsState extends State<NavigationTabs> {
  final _cache = RecentAnimeCache();
  List<Anime> _recentAnimes = [];
  bool _isLoading = true;
  late StreamSubscription<List<Anime>> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _loadRecentAnimes();
    _listenToCacheChanges();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadRecentAnimes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final animes = await _cache.getRecentAnimes();
      setState(() {
        _recentAnimes = animes;
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading recent animes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenToCacheChanges() {
    _streamSubscription = _cache.recentAnimesStream.listen((animes) {
      setState(() {
        _recentAnimes = animes;
        _isLoading = false;
      });
    });
  }

  Future<void> _removeTab(Anime anime) async {
    try {
      // For now, we only have 1 tab, so clearing removes it
      await _cache.clearRecentAnimes();
      widget.onClearTabs();
      log('Tab removed: ${anime.title}');
    } catch (e) {
      log('Error removing tab: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : _buildTabs(),
    );
  }

  Widget _buildTabs() {
    if (_recentAnimes.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'Нет недавно открытых аниме',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentAnimes.length + 1, // +1 for the "Закрыть все" button
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Закрыть все" button
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: OutlinedButton(
                onPressed: () {
                  _recentAnimes.firstOrNull?.let((anime) => _removeTab(anime));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.close, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Закрыть',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final anime = _recentAnimes[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mini poster
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      child: Image.network(
                        anime.poster,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Title
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      anime.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Close button
                  IconButton(
                    onPressed: () => _removeTab(anime),
                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

extension<T> on T? {
  void let(void Function(T value) callback) {
    if (this != null) callback(this as T);
  }
}
