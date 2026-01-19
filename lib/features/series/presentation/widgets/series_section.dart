import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/features/series/presentation/bloc/series_bloc.dart';
import 'package:a_watch/features/series/presentation/bloc/series_state.dart';
import 'package:a_watch/features/series/presentation/bloc/series_event.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/presentation/widgets/anime_detail/franchise_carousel.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/presentation/widgets/layout/app_shell.dart';
import 'package:a_watch/features/home/presentation/widgets/clickable_section_header.dart';
import 'series_filters_widget.dart';
import 'pagination_widget.dart';

class SeriesSection extends StatefulWidget {
  final bool isDesktop;
  final Function(String animeUrl)? onAnimeSelected;

  const SeriesSection({
    super.key,
    required this.isDesktop,
    this.onAnimeSelected,
  });

  @override
  State<SeriesSection> createState() => _SeriesSectionState();
}

class _SeriesSectionState extends State<SeriesSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  SeriesFilters _currentFilters = SeriesFilters.empty();

  // Store carousel data separately to preserve it during filtering
  List<Anime> _carouselData = [];
  SeriesFilters _availableFilters = SeriesFilters.empty();

  @override
  void initState() {
    super.initState();
    if (!widget.isDesktop) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.isDesktop) {
      final show = _scrollController.offset > 200;
      if (_showScrollToTop != show) {
        setState(() {
          _showScrollToTop = show;
        });
      }

      // Infinite scroll
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<SeriesBloc>().state;
        if (state is SeriesLoaded && state.data.hasNextPage) {
          context.read<SeriesBloc>().add(SeriesLoadMore(
            state.data.nextPageUrl,
            filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
          ));
        }
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onFiltersChanged(SeriesFilters filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  void _onApplyFilters() {
    // Применяем фильтры - загружаем первую страницу с фильтрами
    // Используем специальный флаг для фильтрации без полной перезагрузки UI
    context.read<SeriesBloc>().add(SeriesLoad(
      url: 'https://yummyanime.tv/series-y10/',
      filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
      isFiltering: true, // Флаг для индикации фильтрации
    ));
  }

  void _onResetFilters() {
    setState(() {
      _currentFilters = SeriesFilters.empty();
    });
    context.read<SeriesBloc>().add(const SeriesLoad(
      url: 'https://yummyanime.tv/series',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeriesBloc, SeriesState>(
      builder: (context, state) {
        Widget content;
        if (state is SeriesInitial) {
          // Загружаем данные сериалов при первом заходе
          context.read<SeriesBloc>().add(const SeriesLoad(
            url: 'https://yummyanime.tv/series-y10/',
          ));
          content = const SizedBox();
        } else if (state is SeriesLoading) {
          content = _buildLoadingSection();
        } else if (state is SeriesFiltering) {
          // Filtering state - show stored carousel and filters, loading for list only
          final children = <Widget>[];

          // Секция карусели (из сохраненных данных)
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, widget.isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Секция фильтров (из сохраненных данных)
          children.add(SeriesFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Секция списка сериалов с индикацией загрузки
          children.add(_buildSeriesListSection(state.currentData, widget.isDesktop));
          children.add(const Center(child: CircularProgressIndicator()));

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        } else if (state is SeriesLoaded) {
          final children = <Widget>[];

          // Store carousel and filters data when first loaded or when not filtering
          if (state.data.carousel.isNotEmpty && (_carouselData.isEmpty || !_currentFilters.hasActiveFilters)) {
            _carouselData = state.data.carousel;
          }
          if (_availableFilters.types.isEmpty || !_currentFilters.hasActiveFilters) {
            _availableFilters = state.data.availableFilters;
          }

          // Секция карусели (если есть данные) - always use stored data
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, widget.isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Секция фильтров - always use stored data
          children.add(SeriesFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Секция списка сериалов - use current data for list and pagination
          children.add(_buildSeriesListSection(state.data, widget.isDesktop));

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        } else if (state is SeriesError) {
          // Show error banner but keep functionality
          final children = <Widget>[];

          // Error banner at the top
          children.add(
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ошибка загрузки: ${state.message}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Retry loading
                      context.read<SeriesBloc>().add(const SeriesLoad(
                        url: 'https://yummyanime.tv/series-y10/',
                      ));
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: 'Повторить',
                  ),
                ],
              ),
            ),
          );

          // Секция фильтров (всегда доступна)
          children.add(SeriesFiltersWidget(
            availableFilters: SeriesFilters.empty(), // Empty filters when error
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Placeholder content
          children.add(_buildErrorPlaceholder());

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        } else if (state is SeriesLoadingMore) {
          // Показываем текущие данные с индикацией загрузки
          final children = <Widget>[];

          // Use stored carousel data
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, widget.isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Use stored filters data
          children.add(SeriesFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));
          children.add(_buildSeriesListSection(state.currentData, widget.isDesktop));
          children.add(const Center(child: CircularProgressIndicator()));

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        } else {
          content = const SizedBox();
        }

        // Add floating button for mobile
        if (!widget.isDesktop && _showScrollToTop) {
          return Stack(
            children: [
              content,
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'series_scroll_to_top',
                  onPressed: _scrollToTop,
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
            ],
          );
        }

        return content;
      },
    );
  }

  Widget _buildCarouselSection(List<Anime> carousel, bool isDesktop) {
    return FranchiseCarousel(
      title: 'Популярное',
      animeList: carousel,
      onAnimeTap: (anime) => context.go('/animeDetail/${Uri.encodeComponent(anime.url)}'),
    );
  }

  Widget _buildSeriesListSection(SeriesPageData data, bool isDesktop) {
    final listWidget = isDesktop
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 2 / 3.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: data.items.length,
            itemBuilder: (context, index) {
              final anime = data.items[index];
              return AnimeCard(
                anime: anime,
                variant: CardVariant.detailed,
                heroTag: 'series_list_${anime.id}_$index',
                onTap: () {
                  final appShellState = AppShell.of(context);
                  if (appShellState != null) {
                    appShellState.showAnimeInRecentTab(anime.url);
                  } else {
                    // Fallback to navigation if AppShell not found
                    context.go('/animeDetail/${Uri.encodeComponent(anime.url)}');
                  }
                },
              );
            },
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (data.items.length / 2).ceil(),
            itemBuilder: (context, rowIndex) {
              final startIndex = rowIndex * 2;
              final endIndex = (startIndex + 2).clamp(0, data.items.length);
              final rowItems = data.items.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final cardWidth = rowItems.length == 1 ? 160.0 : (availableWidth - 12) / 2; // 12px spacing

                    return Row(
                      mainAxisAlignment: rowItems.length == 1 ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: rowItems.map((anime) {
                        final index = data.items.indexOf(anime);
                        return Container(
                          width: cardWidth,
                          height: 240,
                          margin: EdgeInsets.only(right: rowItems.last != anime ? 12 : 0),
                          child: AnimeCard(
                            anime: anime,
                            variant: CardVariant.detailed,
                            heroTag: 'series_list_${anime.id}_$index',
                            onTap: () {
                              final appShellState = AppShell.of(context);
                              if (appShellState != null) {
                                appShellState.showAnimeInRecentTab(anime.url);
                              } else {
                                // Fallback to navigation if AppShell not found
                                context.go('/animeDetail/${Uri.encodeComponent(anime.url)}');
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              );
            },
          );

    return _buildSection(
      title: 'Все сериалы',
      isDesktop: isDesktop,
      onTitleTap: null,
      child: Column(
        children: [
          listWidget,
          if (isDesktop)
            PaginationWidget(
              currentPage: data.currentPage,
              totalPages: data.totalPages,
              filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
              onPageChanged: (page, filters) {
                context.read<SeriesBloc>().add(SeriesChangePage(page, filters: filters));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDesktop,
    required Widget child,
    VoidCallback? onTitleTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: onTitleTap != null
                ? ClickableSectionHeader(
                    title: title,
                    onTap: onTitleTap,
                    isDesktop: isDesktop,
                  )
                : AppH2(title),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppH2('Сериалы'),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return _buildSection(
      title: 'Сериалы',
      isDesktop: widget.isDesktop,
      onTitleTap: null,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.movie_filter,
                size: 64,
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Попробуйте применить фильтры для поиска сериалов',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppH2('Сериалы'),
          ),
          const SizedBox(height: 8),
          Center(child: AppBodyMedium('Error: $message')),
        ],
      ),
    );
  }
}
