import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/core/di/service_locator.dart';
import 'package:a_watch/core/result/result.dart';
import 'package:a_watch/data/parser/anime_detail_parser.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/anime/domain/entities/anime_detail.dart';
import 'package:a_watch/domain/entities/viewing_state.dart';
import 'package:a_watch/domain/usecases/viewing_state_service.dart';
import 'package:a_watch/features/anime/domain/usecases/switch_episode.dart';
import 'package:a_watch/features/anime/domain/usecases/switch_translation.dart';
import 'package:a_watch/features/anime/domain/usecases/load_player_content.dart';
import 'package:a_watch/presentation/widgets/anime_detail/anime_detail_header.dart';
import 'package:a_watch/presentation/widgets/anime_detail/franchise_carousel.dart';
import 'package:a_watch/presentation/widgets/anime_detail/related_carousel.dart';
import 'package:a_watch/core/cache/recent_anime_cache.dart';
import 'package:a_watch/core/http/http_service.dart';
import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/features/player/presentation/widgets/video_player_widget.dart';
import 'package:a_watch/features/player/presentation/widgets/video_player_shimmer.dart';
import 'package:a_watch/presentation/widgets/anime_detail/seasonal_navigator.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_bloc.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_event.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_state.dart';
import 'package:a_watch/core/logger/logger.dart';

/// Widget for displaying anime details in the recent tab
class AnimeDetailWidget extends StatefulWidget {
  final String? animeUrl;

  const AnimeDetailWidget({
    super.key,
    this.animeUrl,
  });

  @override
  State<AnimeDetailWidget> createState() => _AnimeDetailWidgetState();
}

class _AnimeDetailWidgetState extends State<AnimeDetailWidget>
    with AutomaticKeepAliveClientMixin {
  AnimeDetail? _animeDetail;
  Anime? _recentAnime;
  bool _isLoading = true;
  String? _error;
  final _cache = RecentAnimeCache();
  late StreamSubscription<List<Anime>> _streamSubscription;
  bool _isUpdatingFromSelf = false;

  // Player state
  late final ViewingStateService _viewingStateService;
  ViewingState? _currentViewingState;
  KodikContent? _kodikContent;
  Map<String, List<KodikStream>>? _kodikStreams;
  String? _currentVideoUrl;
  String? _selectedQuality;
  bool _isPlayerLoading = false;

  // BLoC instance - created once
  late VideoPlayerBloc _videoPlayerBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _viewingStateService = ViewingStateService();
    _videoPlayerBloc = VideoPlayerBloc(getIt<ILogger>()); // Create BLoC once
    _isPlayerLoading = true; // Показываем шиммер сразу при входе

    // If animeUrl is provided, load that specific anime
    if (widget.animeUrl != null) {
      _loadAnimeDetail(widget.animeUrl!);
    } else {
      _loadRecentAnime();
    }

    _listenToCacheChanges();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _videoPlayerBloc.close(); // Dispose BLoC
    super.dispose();
  }

  Future<void> _loadRecentAnime() async {
    try {
      final animes = await _cache.getRecentAnimes();
      final recentAnime = animes.isNotEmpty ? animes.first : null;

      if (recentAnime != null) {
        final cachedDetail = await _cache.getRecentAnimeDetail();

        // Проверяем, нужно ли обновить данные (примерно каждый час)
        // Используем простой подход: обновляем данные если прошло достаточно времени
        // или если кэш пустой
        final shouldForceRefresh = cachedDetail == null ||
            (DateTime.now().hour % 2 == 0 && cachedDetail.url == recentAnime.url); // Обновляем каждый четный час

        if (cachedDetail != null &&
            cachedDetail.url == recentAnime.url &&
            !shouldForceRefresh) {
          // Используем кэш, если данные относительно свежие
          if (mounted) {
            setState(() {
            _animeDetail = cachedDetail;
            _recentAnime = recentAnime;
            _isLoading = false;
            _error = null;
          });
          }
          _loadPlayerContent(recentAnime.url);
          return;
        }

        // Force refresh для получения актуальных данных (новые серии, озвучки и т.д.)
        await _loadAnimeDetail(recentAnime.url);
      } else {
        if (mounted) {
          setState(() {
          _isLoading = false;
          _error = null;
          _animeDetail = null;
          _recentAnime = null;
        });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      }
    }
  }

  Future<void> _loadAnimeDetail(String animeUrl) async {
    if (mounted) {
      setState(() {
      _isLoading = true;
      _error = null;
    });
    }

    try {
      final httpClient = HttpService(baseUrl: '');
      final response = await httpClient.get(animeUrl);
      httpClient.close();

      final html = response.body;
      final config = SelectorsConfig.loadDefault();
      final parser = AnimeDetailParser();
      final result = await parser.parse(
        htmlContent: html,
        selectors: {'url': animeUrl},
        config: config,
      );

      if (mounted) {
        setState(() {
        _animeDetail = result;
        _isLoading = false;
      });
      }

      _loadPlayerContent(animeUrl);

      await _cache.saveRecentAnimeDetail(result);

      final anime = Anime(
        id: animeUrl.split('/').last.split('.').first,
        title: result.title,
        slug: result.title
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
            .replaceAll(' ', '-'),
        url: animeUrl,
        poster: result.posterUrl,
        year: result.year.toString(),
        genres: result.genres,
      );

      if (_recentAnime == null || _recentAnime!.url != anime.url) {
        _isUpdatingFromSelf = true;
        _cache.saveRecentAnime(anime);
        _isUpdatingFromSelf = false;
      }

      if (mounted) {
        setState(() {
        _recentAnime = anime;
      });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      }
    }
  }

  void _listenToCacheChanges() {
    _streamSubscription = _cache.recentAnimesStream.listen((animes) async {
      if (_isUpdatingFromSelf) return;
      final recentAnime = animes.isNotEmpty ? animes.first : null;
      if (recentAnime?.url != _recentAnime?.url) {
        if (recentAnime != null) {
          await _loadAnimeDetail(recentAnime.url);
        } else {
          if (mounted) {
            setState(() {
            _animeDetail = null;
            _recentAnime = null;
            _isLoading = false;
            _error = null;
          });
          }
        }
      }
    });
  }

  Future<void> _refreshData() async {
    if (_recentAnime == null) return;

    // Refresh anime details and player content
    await Future.wait([
      _loadAnimeDetail(_recentAnime!.url),
      _loadPlayerContent(_recentAnime!.url),
    ]);
  }

  Future<void> _loadPlayerContent(String animeUrl) async {
    if (mounted) setState(() => _isPlayerLoading = true);
    try {
      final result = await getIt<LoadPlayerContentUseCase>().call(
        LoadPlayerContentParams(animeUrl: animeUrl),
      );

      if (result.isSuccess) {
        final data = result.data!;
        if (mounted) {
          setState(() {
          _kodikContent = data.kodikContent;
          _kodikStreams = data.kodikStreams;
          _currentVideoUrl = data.currentVideoUrl;
          _selectedQuality = data.selectedQuality;
          _currentViewingState = _viewingStateService.getCurrentState();
          _isPlayerLoading = false;
        });
        }
      } else {
        if (mounted) setState(() => _isPlayerLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isPlayerLoading = false);
    }
  }

  Future<void> _onEpisodeSelected(String epId, String epHash) async {
    if (_kodikContent == null) return;

    // Check if player is currently playing for auto-play logic
    final bloc = _videoPlayerBloc;
    final currentState = bloc.state;
    final wasPlaying = currentState is VideoPlayerPlaying;

    if (mounted) setState(() => _isPlayerLoading = true);
    try {
      final result = await getIt<SwitchEpisodeUseCase>().call(
        SwitchEpisodeParams(
          epId: epId,
          epHash: epHash,
          kodikContent: _kodikContent!,
          selectedQuality: _selectedQuality,
        ),
      );

      if (result.isSuccess) {
        final data = result.data!;
        if (mounted) {
          setState(() {
            _kodikContent = data.kodikContent;
            _kodikStreams = data.kodikStreams;
            _currentVideoUrl = data.currentVideoUrl;
            _selectedQuality = data.selectedQuality;
            _currentViewingState = _viewingStateService.getCurrentState();
            _isPlayerLoading = false;
          });

          // Auto-play if player was playing before the switch
          if (wasPlaying) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _videoPlayerBloc.add(PreparePlayer(
                videoUrl: _currentVideoUrl!,
                headers: {'Referer': _kodikContent?.iframeUrl ?? 'https://kodik.cc/'},
                qualities: _kodikStreams!.map((k, v) => MapEntry(k, v.first.url)),
                initialQuality: _selectedQuality,
              ));
              // Send Play event after PreparePlayer to start auto-playing
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _videoPlayerBloc.add(const Play());
              });
            });
          }
        }
      } else {
        if (mounted) setState(() => _isPlayerLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isPlayerLoading = false);
    }
  }

  void _onNextEpisode() {
    if (_kodikContent == null) return;
    final all = _kodikContent!.fileList['all'] as Map<String, dynamic>? ?? {};

    // Find current season and episode keys
    String? currentSeason;
    String? currentEpKey;

    final active = _kodikContent!.fileList['active'] as Map<String, dynamic>?;
    if (active != null) {
      currentSeason = active['season']?.toString();
      currentEpKey =
          active['episode_num']?.toString() ?? active['episode']?.toString();
    }

    if (currentSeason == null || currentEpKey == null) return;

    final seasonEps = all[currentSeason] as Map<String, dynamic>? ?? {};
    final epKeys = seasonEps.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final currentIndex = epKeys.indexOf(currentEpKey);
    if (currentIndex != -1 && currentIndex < epKeys.length - 1) {
      // Next episode in same season
      final nextEpKey = epKeys[currentIndex + 1];
      final nextEpData = seasonEps[nextEpKey];
      _onEpisodeSelected(
        nextEpData['id'].toString(),
        nextEpData['hash'].toString(),
      );
    } else {
      // Try next season
      final seasons = all.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      final seasonIndex = seasons.indexOf(currentSeason);
      if (seasonIndex != -1 && seasonIndex < seasons.length - 1) {
        final nextSeason = seasons[seasonIndex + 1];
        final nextSeasonEps = all[nextSeason] as Map<String, dynamic>? ?? {};
        final nextEpKey =
            (nextSeasonEps.keys.toList()
                  ..sort((a, b) => int.parse(a).compareTo(int.parse(b))))
                .first;
        final nextEpData = nextSeasonEps[nextEpKey];
        _onEpisodeSelected(
          nextEpData['id'].toString(),
          nextEpData['hash'].toString(),
        );
      }
    }
  }

  Future<void> _onTranslationSelected(String mediaId, String mediaHash) async {
    if (_kodikContent == null) return;

    // Check if player is currently playing for auto-play logic
    final bloc = _videoPlayerBloc;
    final currentState = bloc.state;
    final wasPlaying = currentState is VideoPlayerPlaying;

    if (mounted) setState(() => _isPlayerLoading = true);
    try {
      final result = await getIt<SwitchTranslationUseCase>().call(
        SwitchTranslationParams(
          mediaId: mediaId,
          mediaHash: mediaHash,
          kodikContent: _kodikContent!,
          selectedQuality: _selectedQuality,
        ),
      );

      if (result.isSuccess) {
        final data = result.data!;
        if (mounted) {
          setState(() {
            _kodikContent = data.kodikContent;
            _kodikStreams = data.kodikStreams;
            _currentVideoUrl = data.currentVideoUrl;
            _selectedQuality = data.selectedQuality;
            _currentViewingState = _viewingStateService.getCurrentState();
            _isPlayerLoading = false;
          });

          // Auto-play if player was playing before the switch
          if (wasPlaying) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _videoPlayerBloc.add(PreparePlayer(
                videoUrl: _currentVideoUrl!,
                headers: {'Referer': _kodikContent?.iframeUrl ?? 'https://kodik.cc/'},
                qualities: _kodikStreams!.map((k, v) => MapEntry(k, v.first.url)),
                initialQuality: _selectedQuality,
              ));
              // Send Play event after PreparePlayer to start auto-playing
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _videoPlayerBloc.add(const Play());
              });
            });
          }
        }
      } else {
        if (mounted) setState(() => _isPlayerLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isPlayerLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Ошибка: $_error'));
    if (_animeDetail == null) {
      return const Center(child: Text('Выберите аниме'));
    }

    return BlocProvider.value(
      value: _videoPlayerBloc,
      child: Builder(
        builder: (context) {
          // Видео виджет - с поддержкой BLoC
          final videoWidget = _currentVideoUrl != null &&
                  _kodikStreams != null &&
                  _selectedQuality != null &&
                  !_isPlayerLoading
              ? Builder(
                  builder: (context) {
                    log('[AnimeDetailWidget] Creating VideoPlayerWidget');
                    // Автоматически подготовить плеер при создании
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final bloc = context.read<VideoPlayerBloc>();
                      log('[AnimeDetailWidget] Auto-sending PreparePlayer event');
                      bloc.add(PreparePlayer(
                        videoUrl: _currentVideoUrl!,
                        headers: {'Referer': _kodikContent?.iframeUrl ?? 'https://kodik.cc/'},
                        qualities: _kodikStreams!.map(
                          (k, v) => MapEntry(k, v.first.url),
                        ),
                        initialQuality: _selectedQuality,
                      ));
                    });

                    return VideoPlayerWidget(
                      qualities: _kodikStreams!.map(
                        (k, v) => MapEntry(k, v.first.url),
                      ),
                      onQualityChanged: (quality) {
                        setState(() => _selectedQuality = quality);
                      },
                      skipTimings: _kodikContent?.skipTimings ?? [],
                      onNext: () => _onNextEpisode(),
                      translationId: _kodikContent?.fileList['active']?['translation'] ?? '0',
                    );
                  },
                )
              : Builder(
                  builder: (context) {
                    log('[AnimeDetailWidget] Showing VideoPlayerShimmer');
                    return const VideoPlayerShimmer();
                  },
                );

          // Обычный режим
          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth * 0.08;
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                      left: horizontalPadding,
                      right: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Видео - всегда показываем контейнер
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: videoWidget,
                        ),

                        const SizedBox(height: 16),

                        if (_kodikContent != null)
                          SeasonalNavigator(
                            fileList: _kodikContent!.fileList,
                            onEpisodeSelected: _onEpisodeSelected,
                          onTranslationSelected: (mediaId, mediaHash) async {
                            await _onTranslationSelected(mediaId, mediaHash);
                          },
                            currentViewingState: _currentViewingState,
                          ),

                        const SizedBox(height: 16),

                        // Material Design 3 divider to separate player area from content
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),

                        const SizedBox(height: 16),
                        AnimeDetailHeader(animeDetail: _animeDetail!),
                        const SizedBox(height: 12),

                        _buildDescription(),
                        const SizedBox(height: 16),
                        if (_animeDetail!.franchise.isNotEmpty)
                          FranchiseCarousel(
                            title: 'Порядок просмотра',
                            animeList: _animeDetail!.franchise,
                            onAnimeTap: (anime) {
                              // Если кликнули на то же аниме, которое уже открыто - ничего не делать
                              if (anime.url == _recentAnime?.url) return;

                              final animeEntity = Anime(
                                id: anime.url.split('/').last.split('.').first,
                                title: anime.title,
                                slug: anime.title
                                    .toLowerCase()
                                    .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
                                    .replaceAll(' ', '-'),
                                url: anime.url,
                                poster: anime.poster,
                                year: '',
                                genres: [],
                              );
                              _cache.saveRecentAnime(animeEntity);
                            },
                          ),
                        const SizedBox(height: 8),
                        if (_animeDetail!.related.isNotEmpty)
                          RelatedCarousel(
                            title: 'Смотрите также',
                            animeList: _animeDetail!.related,
                            onAnimeTap: (anime) {
                              final animeEntity = Anime(
                                id: anime.url.split('/').last.split('.').first,
                                title: anime.title,
                                slug: anime.title
                                    .toLowerCase()
                                    .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
                                    .replaceAll(' ', '-'),
                                url: anime.url,
                                poster: anime.poster,
                                year: '',
                                genres: [],
                              );
                              _cache.saveRecentAnime(animeEntity);
                            },
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Описание',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          _animeDetail!.description,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }


}
