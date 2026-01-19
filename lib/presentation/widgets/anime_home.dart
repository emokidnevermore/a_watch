import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_bloc.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_event.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_state.dart';
import 'package:a_watch/presentation/widgets/anime_section.dart';
import 'package:a_watch/presentation/widgets/collections_section.dart';
import 'package:a_watch/core/di/service_locator.dart';
import 'package:a_watch/core/logger/logger.dart';

class AnimeHome extends StatelessWidget {
  final bool isDesktop;

  const AnimeHome({
    super.key,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final animeListBloc = context.watch<AnimeListBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () {
              animeListBloc.add(const AnimeListLoad(
                url: 'https://yummyanime.tv/index-2',
                forceRefresh: true,
              ));
            },
          ),
        ],
      ),
      body: BlocBuilder<AnimeListBloc, AnimeListState>(
        builder: (context, state) {
          if (state is AnimeListInitial) {
            animeListBloc.add(const AnimeListLoad(
              url: 'https://yummyanime.tv/index-2',
              useCache: false, // Загружаем без кэша при инициализации
            ));
            return const Center(child: Text('Loading...'));
          } else if (state is AnimeListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnimeListLoaded) {
            // Разделяем аниме по типам
            final serials = state.pageResult.items
                .where((anime) => anime.type == 'serial')
                .toList();

            final movies = state.pageResult.items
                .where((anime) => anime.type == 'movie')
                .toList();



            return RefreshIndicator(
              onRefresh: () async {
                animeListBloc.add(const AnimeListLoad(
                  url: 'https://yummyanime.tv/index-2',
                  forceRefresh: true,
                ));
                await Future.delayed(const Duration(seconds: 2));
              },
              child: ListView(
                children: [
                  // Сериалы
                  AnimeSection(
                    title: 'Сериалы',
                    animes: serials,
                    onRefresh: () {
                      animeListBloc.add(const AnimeListLoad(
                        url: 'https://yummyanime.tv/index-2',
                        forceRefresh: true,
                      ));
                    },
                    onTitleTap: () {
                      getIt<ILogger>().logInfo('Tapping series title, navigating to /series', 'NAVIGATION');
                      context.go('/series');
                    },
                  ),

                  // Фильмы
                  AnimeSection(
                    title: 'Фильмы',
                    animes: movies,
                    onRefresh: () {
                      animeListBloc.add(const AnimeListLoad(
                        url: 'https://yummyanime.tv/index-2',
                        forceRefresh: true,
                      ));
                    },
                    onTitleTap: () {
                      getIt<ILogger>().logInfo('Tapping movies title, navigating to /movies', 'NAVIGATION');
                      context.go('/movies');
                    },
                  ),

                  // Подборки
                  const CollectionsSection(),
                ],
              ),
            );
          } else if (state is AnimeListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
