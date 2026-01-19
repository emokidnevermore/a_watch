import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_state.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_event.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/presentation/widgets/anime_detail/franchise_carousel.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/presentation/widgets/layout/app_shell.dart';
import 'package:a_watch/features/home/presentation/widgets/clickable_section_header.dart';
import 'movies_filters_widget.dart';
import 'package:a_watch/features/series/presentation/widgets/pagination_widget.dart';
import 'package:a_watch/core/di/service_locator.dart';
import 'package:a_watch/core/logger/logger.dart';

class MoviesSection extends StatefulWidget {
  final bool isDesktop;
  final Function(String animeUrl)? onAnimeSelected;

  const MoviesSection({
    super.key,
    required this.isDesktop,
    this.onAnimeSelected,
  });

  @override
  State<MoviesSection> createState() => _MoviesSectionState();
}

class _MoviesSectionState extends State<MoviesSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _hasLoaded = false;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    getIt<ILogger>().logDebug('didChangeDependencies called, _hasLoaded: $_hasLoaded', 'MOVIES_SECTION');
    if (!_hasLoaded) {
      getIt<ILogger>().logInfo('Loading movies for the first time', 'MOVIES_SECTION');
      final moviesBloc = context.read<MoviesBloc>();
      moviesBloc.add(const MoviesLoad(
        url: 'https://yummyanime.tv/movies-y10/',
        useCache: false, // Не использовать кеш при переходе на секцию
      ));
      _hasLoaded = true;
    } else {
      getIt<ILogger>().logDebug('Already loaded, skipping', 'MOVIES_SECTION');
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
        final state = context.read<MoviesBloc>().state;
        if (state is MoviesLoaded && state.data.hasNextPage) {
          context.read<MoviesBloc>().add(MoviesLoadMore(
            nextPageUrl: state.data.nextPageUrl,
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
    context.read<MoviesBloc>().add(MoviesLoad(
      url: 'https://yummyanime.tv/movies-y2/',
      filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
      isFiltering: true, // Флаг для индикации фильтрации
    ));
  }

  void _onResetFilters() {
    setState(() {
      _currentFilters = SeriesFilters.empty();
    });
    context.read<MoviesBloc>().add(const MoviesLoad(
      url: 'https://yummyanime.tv/movies',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoviesBloc, MoviesState>(
      builder: (context, state) {
        getIt<ILogger>().logDebug('BlocBuilder state: ${state.runtimeType}', 'MOVIES_SECTION');
        Widget content;
        if (state is MoviesLoading) {
          getIt<ILogger>().logDebug('Building loading section', 'MOVIES_SECTION');
          content = _buildLoadingSection();
        } else if (state is MoviesFiltering) {
          getIt<ILogger>().logDebug('Building filtering section', 'MOVIES_SECTION');
          // Filtering state - show stored carousel and filters, loading for list only
          final children = <Widget>[];

          // Секция карусели (из сохраненных данных)
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, widget.isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Секция фильтров (из сохраненных данных)
          children.add(MoviesFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Секция списка фильмов с индикацией загрузки
          children.add(_buildMoviesListSection(state.currentData, widget.isDesktop));
          children.add(const Center(child: CircularProgressIndicator()));

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        } else if (state is MoviesLoaded) {
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
          children.add(MoviesFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Секция списка фильмов - use current data for list and pagination
          children.add(_buildMoviesListSection(state.data, widget.isDesktop));

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        } else if (state is MoviesError) {
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
                      context.read<MoviesBloc>().add(const MoviesLoad(
                        url: 'https://yummyanime.tv/movies-y2/',
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
          children.add(MoviesFiltersWidget(
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
        } else if (state is MoviesLoadingMore) {
          // Показываем текущие данные с индикацией загрузки
          final children = <Widget>[];

          // Use stored carousel data
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, widget.isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Use stored filters data
          children.add(MoviesFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: widget.isDesktop,
          ));
          children.add(const SizedBox(height: 16));
          children.add(_buildMoviesListSection(state.currentData, widget.isDesktop));
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
                  heroTag: 'movies_scroll_to_top',
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

  Widget _buildMoviesListSection(SeriesPageData data, bool isDesktop) {
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
                heroTag: 'movies_list_${anime.id}_$index',
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
                            heroTag: 'movies_list_${anime.id}_$index',
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
      title: 'Все фильмы',
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
                context.read<MoviesBloc>().add(MoviesChangePage(page: page, filters: filters));
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
            child: AppH2('Фильмы'),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return _buildSection(
      title: 'Фильмы',
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
                'Попробуйте применить фильтры для поиска фильмов',
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
            child: AppH2('Фильмы'),
          ),
          const SizedBox(height: 8),
          Center(child: AppBodyMedium('Error: $message')),
        ],
      ),
    );
  }
}
