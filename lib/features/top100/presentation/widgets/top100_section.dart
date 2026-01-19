import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_bloc.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_state.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_event.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/presentation/widgets/layout/app_shell.dart';

class Top100Section extends StatefulWidget {
  final Function(String animeUrl)? onAnimeSelected;

  const Top100Section({
    super.key,
    this.onAnimeSelected,
  });

  static bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024; // Same breakpoint as DesignTokens
  }

  @override
  State<Top100Section> createState() => _Top100SectionState();
}

class _Top100SectionState extends State<Top100Section> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Scroll controller will be initialized when context is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDesktop = Top100Section._isDesktop(context);
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
    final isDesktop = Top100Section._isDesktop(context);
    if (!isDesktop) {
      final show = _scrollController.offset > 200;
      if (_showScrollToTop != show) {
        setState(() {
          _showScrollToTop = show;
        });
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

  void _onFilterChanged(Top100Filter filter) {
    context.read<Top100Bloc>().add(Top100ChangeFilter(filter));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth * 0.08; // 8% padding like other sections
        return BlocBuilder<Top100Bloc, Top100State>(
          builder: (context, state) {
            Widget content;
            if (state is Top100Initial) {
              // Load initial data
              context.read<Top100Bloc>().add(const Top100Load());
              content = const SizedBox();
            } else if (state is Top100Loading) {
              content = _buildLoadingSection();
            } else if (state is Top100Loaded) {
              final isDesktop = Top100Section._isDesktop(context);
              content = isDesktop
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: 24, // Top padding for breathing room
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterSection(state.data.currentFilter),
                            const SizedBox(height: 24),
                            _buildTop100ListSection(state.data, isDesktop),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        top: 16, // Smaller top padding for mobile
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection(state.data.currentFilter),
                          const SizedBox(height: 16),
                          _buildTop100ListSection(state.data, isDesktop),
                        ],
                      ),
                    );
            } else if (state is Top100Error) {
              content = _buildErrorSection(state.message);
            } else {
              content = const SizedBox();
            }

            // Always use Stack for mobile to prevent scroll position reset
            final isDesktop = Top100Section._isDesktop(context);
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
                        heroTag: 'top100_scroll_to_top',
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

  Widget _buildFilterSection(Top100Filter currentFilter) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppH2('ТОП-100 лучших аниме'),
          ),
          const SizedBox(height: 12),
          _buildFilterButtons(currentFilter),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(Top100Filter currentFilter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: Top100Filter.values.map((filter) {
          final isSelected = currentFilter == filter;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () => _onFilterChanged(filter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  foregroundColor: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  filter.displayName,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTop100ListSection(Top100PageData data, bool isDesktop) {
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
                heroTag: 'top100_list_${anime.id}_$index',
                onTap: () {
                  final appShellState = AppShell.of(context);
                  if (appShellState != null) {
                    appShellState.showAnimeInRecentTab(anime.url);
                  } else {
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
                            heroTag: 'top100_list_${anime.id}_$index',
                            onTap: () {
                              final appShellState = AppShell.of(context);
                              if (appShellState != null) {
                                appShellState.showAnimeInRecentTab(anime.url);
                              } else {
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

    return listWidget;
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppH2('ТОП-100'),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
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
            child: AppH2('ТОП-100'),
          ),
          const SizedBox(height: 12),
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
                    'Ошибка загрузки: $message',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<Top100Bloc>().add(const Top100Load());
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
        ],
      ),
    );
  }
}
