import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/presentation/widgets/anime_detail/franchise_carousel.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/presentation/widgets/layout/app_shell.dart';
import 'package:a_watch/features/home/presentation/widgets/clickable_section_header.dart';
import 'catalog_filters_widget.dart';
import 'pagination_widget.dart';

class CatalogSection extends StatefulWidget {
  final Function(String animeUrl)? onAnimeSelected;

  const CatalogSection({
    super.key,
    this.onAnimeSelected,
  });

  static bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024; // Same breakpoint as DesignTokens
  }

  @override
  State<CatalogSection> createState() => _CatalogSectionState();
}

class _CatalogSectionState extends State<CatalogSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  CatalogFilters _currentFilters = CatalogFilters.empty();

  // Store carousel data separately to preserve it during filtering
  List<Anime> _carouselData = [];
  CatalogFilters _availableFilters = CatalogFilters.empty();

  @override
  void initState() {
    super.initState();
    // Scroll controller will be initialized when context is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDesktop = CatalogSection._isDesktop(context);
    if (!isDesktop && !_scrollController.hasClients) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isDesktop = CatalogSection._isDesktop(context);
    if (!isDesktop) {
      final show = _scrollController.offset > 200;
      if (_showScrollToTop != show) {
        setState(() {
          _showScrollToTop = show;
        });
      }

      // Infinite scroll
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<CatalogBloc>().state;
        if (state is CatalogLoaded && state.data.hasNextPage) {
          context.read<CatalogBloc>().add(CatalogLoadMore(
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

  void _onFiltersChanged(CatalogFilters filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  void _onApplyFilters() {
    // Применяем фильтры - загружаем первую страницу с фильтрами
    // Используем специальный флаг для фильтрации без полной перезагрузки UI
    context.read<CatalogBloc>().add(CatalogLoad(
      url: 'https://yummyanime.tv/catalog-y5/',
      filters: _currentFilters.hasActiveFilters ? _currentFilters : null,
      isFiltering: true, // Флаг для индикации фильтрации
    ));
  }

  void _onResetFilters() {
    setState(() {
      _currentFilters = CatalogFilters.empty();
    });
    context.read<CatalogBloc>().add(const CatalogLoad(
      url: 'https://yummyanime.tv/catalog-y5/',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = CatalogSection._isDesktop(context);
        final horizontalPadding = isDesktop
            ? constraints.maxWidth * 0.08  // 8% for desktop
            : constraints.maxWidth * 0.04; // 4% for mobile
        return BlocBuilder<CatalogBloc, CatalogState>(
          builder: (context, state) {
            Widget content;
        if (state is CatalogInitial) {
          // Загружаем данные каталога при первом заходе
          context.read<CatalogBloc>().add(const CatalogLoad(
            url: 'https://yummyanime.tv/catalog-y5/',
          ));
          content = const SizedBox();
        } else if (state is CatalogLoading) {
          content = _buildLoadingSection();
        } else if (state is CatalogFiltering) {
          // Filtering state - show stored carousel and filters, loading for list only
          final children = <Widget>[];

          // Секция карусели (из сохраненных данных)
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Секция фильтров (из сохраненных данных)
          children.add(CatalogFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Секция списка аниме с индикацией загрузки
          children.add(_buildCatalogListSection(state.currentData, isDesktop));
          children.add(const Center(child: CircularProgressIndicator()));

          content = SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: isDesktop ? 24 : 16, // Top padding for breathing room
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        } else if (state is CatalogLoaded) {
          final children = <Widget>[];

          // Store carousel and filters data when first loaded or when not filtering
          if (state.data.carousel.isNotEmpty && (_carouselData.isEmpty || !_currentFilters.hasActiveFilters)) {
            _carouselData = state.data.carousel;
          }
          if (_availableFilters.types.isEmpty || !_currentFilters.hasActiveFilters) {
            _availableFilters = state.data.availableFilters as CatalogFilters;
          }

          // Секция карусели (если есть данные) - always use stored data
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Секция фильтров - always use stored data
          children.add(CatalogFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Секция списка аниме - use current data for list and pagination
          children.add(_buildCatalogListSection(state.data, isDesktop));

          content = SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: isDesktop ? 24 : 16, // Top padding for breathing room
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        } else if (state is CatalogError) {
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
                      context.read<CatalogBloc>().add(const CatalogLoad(
                        url: 'https://yummyanime.tv/catalog-y5/',
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
          children.add(CatalogFiltersWidget(
            availableFilters: CatalogFilters.empty(), // Empty filters when error
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: isDesktop,
          ));
          children.add(const SizedBox(height: 16));

          // Placeholder content
          children.add(_buildErrorPlaceholder());

          content = SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: isDesktop ? 24 : 16, // Top padding for breathing room
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        } else if (state is CatalogLoadingMore) {
          // Показываем текущие данные с индикацией загрузки
          final children = <Widget>[];

          // Use stored carousel data
          if (_carouselData.isNotEmpty) {
            children.add(_buildCarouselSection(_carouselData, isDesktop));
            children.add(const SizedBox(height: 24));
          }

          // Use stored filters data
          children.add(CatalogFiltersWidget(
            availableFilters: _availableFilters,
            currentFilters: _currentFilters,
            onFiltersChanged: _onFiltersChanged,
            onApplyFilters: _onApplyFilters,
            onResetFilters: _onResetFilters,
            isDesktop: isDesktop,
          ));
          children.add(const SizedBox(height: 16));
          children.add(_buildCatalogListSection(state.currentData, isDesktop));
          children.add(const Center(child: CircularProgressIndicator()));

          content = SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: isDesktop ? 24 : 16, // Top padding for breathing room
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        } else {
          content = const SizedBox();
        }

        // Always use Stack for mobile to prevent scroll position reset
        if (!isDesktop) {
          return Stack(
            children: [
              content,
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: _showScrollToTop ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton(
                    heroTag: 'catalog_scroll_to_top',
                    onPressed: _scrollToTop,
                    child: const Icon(Icons.arrow_upward),
                  ),
                ),
              ),
            ],
          );
        }

        return content;
          },
        );
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

  Widget _buildCatalogListSection(CatalogPageData data, bool isDesktop) {
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
                heroTag: 'catalog_list_${anime.id}_$index',
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
                            heroTag: 'catalog_list_${anime.id}_$index',
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
      title: 'Каталог аниме',
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
                context.read<CatalogBloc>().add(CatalogChangePage(page, filters: filters));
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
            child: AppH2('Каталог'),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return _buildSection(
      title: 'Каталог',
      isDesktop: CatalogSection._isDesktop(context),
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
                'Попробуйте применить фильтры для поиска аниме',
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
}
