import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:a_watch/domain/entities/viewing_state.dart';
import 'package:a_watch/presentation/widgets/anime_detail/episode_shimmer.dart';
import 'package:a_watch/presentation/widgets/anime_detail/translation_shimmer.dart';

class SeasonalNavigator extends StatefulWidget {
  final Map<String, dynamic> fileList;
  final Function(String episodeId, String episodeHash) onEpisodeSelected;
  final Function(String mediaId, String mediaHash) onTranslationSelected;
  final ViewingState? currentViewingState;

  const SeasonalNavigator({
    super.key,
    required this.fileList,
    required this.onEpisodeSelected,
    required this.onTranslationSelected,
    this.currentViewingState,
  });

  @override
  State<SeasonalNavigator> createState() => _SeasonalNavigatorState();
}

class _SeasonalNavigatorState extends State<SeasonalNavigator> with WidgetsBindingObserver {
  String? _selectedSeason;
  String? _selectedEpisode;
  String? _selectedTranslation;
  final ScrollController _seasonScrollController = ScrollController();
  final ScrollController _episodeScrollController = ScrollController();
  final ScrollController _translationScrollController = ScrollController();

  bool _showLeftSeasonArrow = false;
  bool _showRightSeasonArrow = false;
  bool _showLeftEpisodeArrow = false;
  bool _showRightEpisodeArrow = false;
  bool _showLeftTranslationArrow = false;
  bool _showRightTranslationArrow = false;

  int _currentEpisodePage = 0;
  int _currentTranslationPage = 0;

  Map<String, dynamic> get _allContent =>
      widget.fileList['all'] as Map<String, dynamic>? ?? {};
  List<Map<String, dynamic>> get _translations =>
      (widget.fileList['translations'] as List?)
          ?.cast<Map<String, dynamic>>() ??
      [];

  @override
  void initState() {
    super.initState();
    _initializeSelection();
    _seasonScrollController.addListener(_updateArrows);
    _episodeScrollController.addListener(_updateEpisodeArrows);
    _translationScrollController.addListener(_updateTranslationArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrows();
      _updateEpisodeArrows();
      _updateTranslationArrows();
    });
  }

  @override
  void didUpdateWidget(covariant SeasonalNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fileList != oldWidget.fileList ||
        widget.currentViewingState != oldWidget.currentViewingState) {
      _initializeSelection();
    }
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
      _updateEpisodeArrows();
      _updateTranslationArrows();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _seasonScrollController.removeListener(_updateArrows);
    _episodeScrollController.removeListener(_updateEpisodeArrows);
    _translationScrollController.removeListener(_updateTranslationArrows);
    _seasonScrollController.dispose();
    _episodeScrollController.dispose();
    _translationScrollController.dispose();
    super.dispose();
  }

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  int _calculateItemsPerPage(double availableWidth, double itemWidth, double spacing) {
    if (availableWidth <= 0) return 1;
    final itemsCount = (availableWidth / (itemWidth + spacing)).floor();
    return itemsCount.clamp(1, 50); // Минимум 1, максимум 50 элементов
  }

  int get _episodesPerPage {
    if (!_isDesktop) return 1; // На мобильных скролл, не пейджинг
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth * 0.8; // 80% от ширины экрана (с учетом padding)
    // Вычитаем пространство для стрелок (80px = 40px слева + 40px справа)
    final contentWidth = availableWidth - 80;
    return _calculateItemsPerPage(contentWidth, 50, 8); // Ширина серии 50px + отступ 8px
  }

  int get _translationsPerPage {
    if (!_isDesktop) return 1; // На мобильных скролл, не пейджинг
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth * 0.8; // 80% от ширины экрана
    // Вычитаем пространство для стрелок (80px = 40px слева + 40px справа)
    final contentWidth = availableWidth - 80;
    // Для озвучек ширина зависит от текста, но возьмем среднюю ширину ~120px
    return _calculateItemsPerPage(contentWidth, 120, 8);
  }

  void _updateArrows() {
    if (!_seasonScrollController.hasClients) return;
    final maxScroll = _seasonScrollController.position.maxScrollExtent;
    final currentScroll = _seasonScrollController.offset;
    setState(() {
      _showLeftSeasonArrow = currentScroll > 10;
      _showRightSeasonArrow = currentScroll < maxScroll - 10;
    });
  }

  void _updateEpisodeArrows() {
    if (_isDesktop) {
      final episodeCount = _allContent[_selectedSeason]?.keys.length ?? 0;
      final totalPages = (episodeCount / _episodesPerPage).ceil();
      setState(() {
        _showLeftEpisodeArrow = _currentEpisodePage > 0;
        _showRightEpisodeArrow = _currentEpisodePage < totalPages - 1;
      });
    } else {
      if (!_episodeScrollController.hasClients) return;
      final maxScroll = _episodeScrollController.position.maxScrollExtent;
      final currentScroll = _episodeScrollController.offset;
      setState(() {
        _showLeftEpisodeArrow = currentScroll > 10;
        _showRightEpisodeArrow = currentScroll < maxScroll - 10;
      });
    }
  }

  void _updateTranslationArrows() {
    if (_isDesktop) {
      final totalPages = (_translations.length / _translationsPerPage).ceil();
      setState(() {
        _showLeftTranslationArrow = _currentTranslationPage > 0;
        _showRightTranslationArrow = _currentTranslationPage < totalPages - 1;
      });
    } else {
      if (!_translationScrollController.hasClients) return;
      final maxScroll = _translationScrollController.position.maxScrollExtent;
      final currentScroll = _translationScrollController.offset;
      setState(() {
        _showLeftTranslationArrow = currentScroll > 10;
        _showRightTranslationArrow = currentScroll < maxScroll - 10;
      });
    }
  }

  void _nextEpisodePage() {
    final episodeCount = _allContent[_selectedSeason]?.keys.length ?? 0;
    final totalPages = (episodeCount / _episodesPerPage).ceil();
    if (_currentEpisodePage < totalPages - 1) {
      setState(() {
        _currentEpisodePage++;
        _updateEpisodeArrows();
      });
    }
  }

  void _previousEpisodePage() {
    if (_currentEpisodePage > 0) {
      setState(() {
        _currentEpisodePage--;
        _updateEpisodeArrows();
      });
    }
  }

  void _nextTranslationPage() {
    final totalPages = (_translations.length / _translationsPerPage).ceil();
    if (_currentTranslationPage < totalPages - 1) {
      setState(() {
        _currentTranslationPage++;
        _updateTranslationArrows();
      });
    }
  }

  void _previousTranslationPage() {
    if (_currentTranslationPage > 0) {
      setState(() {
        _currentTranslationPage--;
        _updateTranslationArrows();
      });
    }
  }

  void _initializeSelection() {
    if (widget.fileList['type'] != 'serial') return;

    // Сначала пробуем использовать currentViewingState для инициализации
    if (widget.currentViewingState != null) {
      final state = widget.currentViewingState!;
      _selectedSeason = state.currentSeason;
      _selectedEpisode = state.currentEpisode;
      _selectedTranslation = state.currentTranslationId;
      log('[SeasonalNavigator] Initialized from viewing state: season=$_selectedSeason, episode=$_selectedEpisode, translation=$_selectedTranslation');
      return;
    }

    // Fallback к fileList['active']
    final active = widget.fileList['active'] as Map<String, dynamic>?;
    if (active != null) {
      _selectedSeason = active['season']?.toString();
      _selectedEpisode =
          active['episode_num']?.toString() ?? active['episode']?.toString();
      _selectedTranslation = active['translation']?.toString();
      log('[SeasonalNavigator] Initialized from fileList active: season=$_selectedSeason, episode=$_selectedEpisode, translation=$_selectedTranslation');
    } else {
      // Последний fallback
      final seasons = _allContent;
      if (seasons.isEmpty) return;

      _selectedSeason = seasons.keys.first;
      final episodes = seasons[_selectedSeason!] as Map<String, dynamic>;
      _selectedEpisode = episodes.keys.first;

      if (_translations.isNotEmpty) {
        _selectedTranslation = _translations.first['id']?.toString();
      }
      log('[SeasonalNavigator] Initialized fallback: season=$_selectedSeason, episode=$_selectedEpisode, translation=$_selectedTranslation');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fileList['type'] != 'serial') return const SizedBox.shrink();

    final episodes =
        (_allContent[_selectedSeason] as Map<String, dynamic>?) ?? {};
    final episodeKeys = episodes.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Episode Selection
        if (_allContent.isEmpty)
          const EpisodeShimmer()
        else
          _buildEpisodeGrid(episodeKeys, episodes),

        const SizedBox(height: 16),

        // Translation Selection
        if (_translations.isEmpty)
          const TranslationShimmer()
        else
          _buildTranslationRow(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildScrollableSeasonRow(List<String> seasons) {
    return SizedBox(
      height: 45,
      child: Stack(
        children: [
          ListView.builder(
            controller: _seasonScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final s = seasons[index];
              final isSelected = s == _selectedSeason;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$s сезон'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedSeason = s;
                      final newEpisodes =
                          _allContent[s] as Map<String, dynamic>;
                      _selectedEpisode = newEpisodes.keys.first;
                      _notifyEpisode();
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
          if (_showLeftSeasonArrow)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildArrowGradient(true),
            ),
          if (_showRightSeasonArrow)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildArrowGradient(false),
            ),
        ],
      ),
    );
  }

  Widget _buildArrowGradient(bool isLeft) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
        ),
      ),
      child: Icon(
        isLeft ? Icons.chevron_left : Icons.chevron_right,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildEpisodeGrid(
    List<String> episodeNumbers,
    Map<String, dynamic> episodes,
  ) {
    // Remove black background on mobile for cleaner look
    final containerDecoration = _isDesktop
        ? BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          )
        : null;

    if (_isDesktop) {
      // ПК: пейджинг с стрелками
      final startIndex = _currentEpisodePage * _episodesPerPage;
      final endIndex = startIndex + _episodesPerPage;
      final visibleEpisodes = episodeNumbers.sublist(
        startIndex,
        endIndex > episodeNumbers.length ? episodeNumbers.length : endIndex,
      );

      return Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: visibleEpisodes.map((ep) {
                final isSelected = ep == _selectedEpisode;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedEpisode = ep;
                        _notifyEpisode();
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.white30 : Colors.white10,
                        ),
                      ),
                        child: Center(
                          child: Text(
                            ep,
                            style: TextStyle(
                              color: isSelected
                                  ? (Theme.of(context).primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                  : (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white70),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_showLeftEpisodeArrow)
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: _previousEpisodePage,
                  child: Container(
                    width: 40,
                    height: 55,
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
            if (_showRightEpisodeArrow)
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: _nextEpisodePage,
                  child: Container(
                    width: 40,
                    height: 55,
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
    } else {
      // Мобильный: горизонтальный скролл в 1 ряд (без черного фона)
      return SizedBox(
        height: 55,
        child: Stack(
          children: [
            ListView.builder(
              controller: _episodeScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: episodeNumbers.length,
              itemBuilder: (context, index) {
                final ep = episodeNumbers[index];
                final isSelected = ep == _selectedEpisode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedEpisode = ep;
                        _notifyEpisode();
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.white30 : Colors.white10,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ep,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white70),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // No arrows on mobile - clean horizontal scrolling only
          ],
        ),
      );
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildTranslationRow() {
    if (_isDesktop) {
      // ПК: пейджинг с стрелками
      final startIndex = _currentTranslationPage * _translationsPerPage;
      final endIndex = startIndex + _translationsPerPage;
      final visibleTranslations = _translations.sublist(
        startIndex,
        endIndex > _translations.length ? _translations.length : endIndex,
      );

      return Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: visibleTranslations.map((t) {
                final id = t['id'].toString();
                final isSelected = id == _selectedTranslation;
                final primaryColor = Theme.of(context).primaryColor;
                final backgroundColor = isSelected ? primaryColor : Colors.white.withValues(alpha: 0.05);
                final textColor = isSelected
                    ? (primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                    : (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white70);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      if (isSelected) return;
                      setState(() => _selectedTranslation = id);
                      widget.onTranslationSelected(
                        t['mediaId'] ?? '',
                        t['mediaHash'] ?? '',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.white30 : Colors.white10,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _truncateText(t['title'] ?? 'Неизвестно', 14),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_showLeftTranslationArrow)
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: _previousTranslationPage,
                  child: Container(
                    width: 40,
                    height: 45,
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
            if (_showRightTranslationArrow)
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: _nextTranslationPage,
                  child: Container(
                    width: 40,
                    height: 45,
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
    } else {
      // Мобильный: горизонтальный скролл (без черного фона)
      return SizedBox(
        height: 45,
        child: Stack(
          children: [
            ListView.builder(
              controller: _translationScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _translations.length,
              itemBuilder: (context, index) {
                final t = _translations[index];
                final id = t['id'].toString();
                final isSelected = id == _selectedTranslation;
                final primaryColor = Theme.of(context).primaryColor;
                final backgroundColor = isSelected ? primaryColor : Colors.white.withValues(alpha: 0.05);
                final textColor = isSelected
                    ? (primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                    : (Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white70);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      if (isSelected) return;
                      setState(() => _selectedTranslation = id);
                      widget.onTranslationSelected(
                        t['mediaId'] ?? '',
                        t['mediaHash'] ?? '',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.white30 : Colors.white10,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _truncateText(t['title'] ?? 'Неизвестно', 14),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // No arrows on mobile - clean horizontal scrolling only
          ],
        ),
      );
    }
  }

  void _notifyEpisode() {
    final seasonData = _allContent[_selectedSeason] as Map<String, dynamic>?;
    if (seasonData == null) return;
    final epData = seasonData[_selectedEpisode] as Map<String, dynamic>?;
    if (epData == null) return;

    widget.onEpisodeSelected(
      epData['id'].toString(),
      epData['hash'].toString(),
    );
  }
}
