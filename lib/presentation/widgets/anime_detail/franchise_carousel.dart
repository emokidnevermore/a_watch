import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/presentation/components/cards/hoverable_card.dart';

class FranchiseCarousel extends StatefulWidget {
  final String title;
  final List<Anime> animeList;
  final Function(Anime)? onAnimeTap;

  const FranchiseCarousel({
    super.key,
    required this.title,
    required this.animeList,
    this.onAnimeTap,
  });

  @override
  State<FranchiseCarousel> createState() => _FranchiseCarouselState();
}

class _FranchiseCarouselState extends State<FranchiseCarousel> with WidgetsBindingObserver {
  final ScrollController _franchiseScrollController = ScrollController();
  bool _showLeftFranchiseArrow = false;
  bool _showRightFranchiseArrow = false;
  int _currentFranchisePage = 0;

  @override
  void initState() {
    super.initState();
    _franchiseScrollController.addListener(_updateFranchiseArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFranchiseArrows());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    // Обновляем при изменении размера окна
    if (_isDesktop) {
      _updateFranchiseArrows();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _franchiseScrollController.removeListener(_updateFranchiseArrows);
    _franchiseScrollController.dispose();
    super.dispose();
  }

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  int _calculateItemsPerPage(double availableWidth, double itemWidth, double spacing) {
    if (availableWidth <= 0) return 1;
    final itemsCount = (availableWidth / (itemWidth + spacing)).floor();
    return itemsCount.clamp(1, 50); // Минимум 1, максимум 50 элементов
  }

  int get _franchiseItemsPerPage {
    if (!_isDesktop) return 1; // На мобильных скролл, не пейджинг
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth * 0.8; // 80% от ширины экрана
    // Вычитаем пространство для стрелок (80px = 40px слева + 40px справа)
    final contentWidth = availableWidth - 80;
    return _calculateItemsPerPage(contentWidth, 140, 8); // Ширина карточки 140px + отступ 8px
  }

  void _updateFranchiseArrows() {
    if (_isDesktop) {
      final totalPages = (widget.animeList.length / _franchiseItemsPerPage).ceil();
      setState(() {
        _showLeftFranchiseArrow = _currentFranchisePage > 0;
        _showRightFranchiseArrow = _currentFranchisePage < totalPages - 1;
      });
    } else {
      if (!_franchiseScrollController.hasClients) return;
      final maxScroll = _franchiseScrollController.position.maxScrollExtent;
      final currentScroll = _franchiseScrollController.offset;
      setState(() {
        _showLeftFranchiseArrow = currentScroll > 10;
        _showRightFranchiseArrow = currentScroll < maxScroll - 10;
      });
    }
  }

  void _nextFranchisePage() {
    final totalPages = (widget.animeList.length / _franchiseItemsPerPage).ceil();
    if (_currentFranchisePage < totalPages - 1) {
      setState(() {
        _currentFranchisePage++;
        _updateFranchiseArrows();
      });
    }
  }

  void _previousFranchisePage() {
    if (_currentFranchisePage > 0) {
      setState(() {
        _currentFranchisePage--;
        _updateFranchiseArrows();
      });
    }
  }

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return 'https://yummyanime.tv$url';
    return 'https://yummyanime.tv/$url';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animeList.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        _isDesktop ? _buildDesktopView() : _buildMobileView(),
      ],
    );
  }

  Widget _buildDesktopView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final startIndex = _currentFranchisePage * _franchiseItemsPerPage;
    final endIndex = startIndex + _franchiseItemsPerPage;
    final visibleAnimes = widget.animeList.sublist(
      startIndex,
      endIndex > widget.animeList.length ? widget.animeList.length : endIndex,
    );

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: visibleAnimes.map((anime) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: HoverableCard(
                  onTap: () => widget.onAnimeTap?.call(anime),
                  borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.15)
                            : colorScheme.outline.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        if (theme.brightness != Brightness.dark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.network(
                              _normalizeImageUrl(anime.poster),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: colorScheme.surface,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.surface,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, size: 24),
                                  ),
                                );
                              },
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          if (anime.rating != null)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [DesignTokens.softShadow],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 10, color: Colors.white),
                                    const SizedBox(width: 2),
                                    Text(
                                      anime.rating!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  anime.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 2),

                                if (anime.year != null)
                                  Text(
                                    anime.year!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              );
            }).toList(),
          ),

          if (_showLeftFranchiseArrow)
            Positioned(
              left: 0,
              child: GestureDetector(
                onTap: _previousFranchisePage,
                child: Container(
                  width: 40,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),

          if (_showRightFranchiseArrow)
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: _nextFranchisePage,
                child: Container(
                  width: 40,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          ListView.builder(
            controller: _franchiseScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.animeList.length,
            itemBuilder: (context, index) {
              final anime = widget.animeList[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.animeList.length - 1 ? 0 : 12,
                ),
                child: HoverableCard(
                  onTap: () => widget.onAnimeTap?.call(anime),
                  borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.15)
                            : colorScheme.outline.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        if (theme.brightness != Brightness.dark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.network(
                              _normalizeImageUrl(anime.poster),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: colorScheme.surface,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.surface,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, size: 24),
                                  ),
                                );
                              },
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),

                          if (anime.rating != null)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [DesignTokens.softShadow],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 10, color: Colors.white),
                                    const SizedBox(width: 2),
                                    Text(
                                      anime.rating!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  anime.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 2),

                                if (anime.year != null)
                                  Text(
                                    anime.year!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                );
              },
            ),

          if (_showLeftFranchiseArrow)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white70,
                ),
              ),
            ),

          if (_showRightFranchiseArrow)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
