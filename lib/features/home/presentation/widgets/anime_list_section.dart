import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_bloc.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_state.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_event.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/presentation/widgets/layout/app_shell.dart';
import 'clickable_section_header.dart';
import 'view_mode.dart';

class AnimeListSection extends StatefulWidget {
  final String title;
  final String type;
  final bool isDesktop;
  final bool loadAll;
  final ViewMode? tapMode;
  final Function(ViewMode?)? onViewModeChanged;
  final Function(String animeUrl)? onAnimeSelected;

  const AnimeListSection({
    super.key,
    required this.title,
    required this.type,
    required this.isDesktop,
    this.loadAll = false,
    this.tapMode,
    this.onViewModeChanged,
    this.onAnimeSelected,
  });

  @override
  State<AnimeListSection> createState() => _AnimeListSectionState();
}

class _AnimeListSectionState extends State<AnimeListSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<AnimeListBloc, AnimeListState>(
      builder: (context, state) {
        if (state is AnimeListInitial) {
          context.read<AnimeListBloc>().add(const AnimeListLoad(
            url: 'https://yummyanime.tv/index-2',
            useCache: false,
          ));
          return _buildLoadingSection();
        } else if (state is AnimeListLoading) {
          return _buildLoadingSection();
        } else if (state is AnimeListLoaded) {
          final animes = widget.loadAll
              ? state.pageResult.items.where((anime) => anime.type == widget.type).toList()
              : state.pageResult.items.where((anime) => anime.type == widget.type).toList();

          return _buildSection(
            title: widget.title,
            isDesktop: widget.isDesktop,
            onTitleTap: widget.tapMode != null ? () {
              widget.onViewModeChanged?.call(widget.tapMode);
            } : null,
            child: widget.isDesktop
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.loadAll ? 8 : 6,
                      childAspectRatio: 2 / 3.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: animes.length,
                    itemBuilder: (context, index) {
                      final anime = animes[index];
                      return AnimeCard(
                        anime: anime,
                        variant: CardVariant.detailed,
                        heroTag: 'anime_${anime.id}_$index',
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
                : SizedBox(
                    height: widget.loadAll ? 240 : 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: animes.length,
                      itemBuilder: (context, index) {
                        final anime = animes[index];
                        return Container(
                          margin: EdgeInsets.only(
                            left: 16,
                            right: index == animes.length - 1 ? 16 : 0,
                          ),
                          width: 140, // Fixed width for horizontal scrolling
                          child: AnimeCard(
                            anime: anime,
                            variant: CardVariant.detailed,
                            heroTag: 'anime_${anime.id}_$index',
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
                      },
                    ),
                  ),
          );
        } else if (state is AnimeListError) {
          return _buildErrorSection(state.message);
        }
        return const SizedBox();
      },
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
          onTitleTap != null
              ? ClickableSectionHeader(
                  title: title,
                  onTap: onTitleTap,
                  isDesktop: isDesktop,
                )
              : AppH2(title),
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
          AppH2(widget.title),
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
          AppH2(widget.title),
          const SizedBox(height: 8),
          Center(child: AppBodyMedium('Error: $message')),
        ],
      ),
    );
  }
}
