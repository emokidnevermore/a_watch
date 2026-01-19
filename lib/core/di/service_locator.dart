import 'package:get_it/get_it.dart';
import 'package:a_watch/core/cache/cache_layer.dart';
import 'package:a_watch/core/cache/cache_config.dart';
import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/core/http/http_service_factory.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/iparser.dart';
import 'package:a_watch/data/parser/parser_factory.dart';
import 'package:a_watch/features/anime/data/repositories/anime_repository_impl.dart';
import 'package:a_watch/features/series/data/repositories/series_repository_impl.dart';
import 'package:a_watch/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:a_watch/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:a_watch/features/top100/data/repositories/top100_repository_impl.dart';
import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/features/anime/domain/repositories/anime_repository.dart';
import 'package:a_watch/features/series/domain/repositories/series_repository.dart';
import 'package:a_watch/features/movies/domain/repositories/movies_repository.dart';
import 'package:a_watch/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:a_watch/features/top100/domain/repositories/top100_repository.dart';
import 'package:a_watch/features/anime/domain/usecases/get_anime_list.dart';
import 'package:a_watch/features/anime/domain/usecases/get_anime_detail.dart';
import 'package:a_watch/features/anime/domain/usecases/switch_episode.dart';
import 'package:a_watch/features/anime/domain/usecases/switch_translation.dart';
import 'package:a_watch/features/anime/domain/usecases/load_player_content.dart';
import 'package:a_watch/features/series/domain/usecases/get_series_list.dart';
import 'package:a_watch/features/movies/domain/usecases/get_movies_list.dart';
import 'package:a_watch/features/catalog/domain/usecases/get_catalog_page.dart';
import 'package:a_watch/features/top100/domain/usecases/get_top100_page.dart';
import 'package:a_watch/domain/usecases/get_collections.dart';
import 'package:a_watch/domain/usecases/viewing_state_service.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_bloc.dart';
import 'package:a_watch/features/series/presentation/bloc/series_bloc.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_bloc.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_bloc.dart';
import 'package:a_watch/features/anime/presentation/bloc/anime_detail/anime_detail_bloc.dart';
import 'package:a_watch/presentation/bloc/collections/collections_bloc.dart';

export 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External dependencies
  getIt.registerLazySingleton<ILogger>(() => Logger());
  getIt.registerLazySingleton<CacheConfig>(() => CacheConfig.defaultConfig());
  getIt.registerLazySingleton<CacheLayer>(() => CacheLayer.instance);
  getIt.registerLazySingleton<SelectorsConfig>(
    () => SelectorsConfig.loadDefault(),
  );
  getIt.registerLazySingleton<HttpServiceFactory>(
    () => HttpServiceFactory(getIt<ILogger>()),
  );
  getIt.registerLazySingleton<IHttpService>(
    () => getIt<HttpServiceFactory>().createHttpService(
      baseUrl: getIt<SelectorsConfig>().baseUrl,
      enableLogging: true,
      enableRetry: true,
    ),
  );

  // Parser factory
  getIt.registerLazySingleton<ParserFactory>(() => ParserFactoryImpl());

  // Repositories
  getIt.registerLazySingleton<AnimeRepository>(
    () => AnimeRepositoryImpl(
      httpService: getIt<IHttpService>(),
      selectorsConfig: getIt<SelectorsConfig>(),
      cacheConfig: getIt<CacheConfig>(),
    ),
  );

  getIt.registerLazySingleton<SeriesRepository>(
    () => SeriesRepositoryImpl(
      httpService: getIt<IHttpService>(),
      selectorsConfig: getIt<SelectorsConfig>(),
      cacheConfig: getIt<CacheConfig>(),
      logger: getIt<ILogger>(),
    ),
  );

  getIt.registerLazySingleton<MoviesRepository>(
    () => MoviesRepositoryImpl(
      httpService: getIt<IHttpService>(),
      selectorsConfig: getIt<SelectorsConfig>(),
      cacheConfig: getIt<CacheConfig>(),
      logger: getIt<ILogger>(),
    ),
  );

  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(
      httpService: getIt<IHttpService>(),
      selectorsConfig: getIt<SelectorsConfig>(),
      cacheConfig: getIt<CacheConfig>(),
      logger: getIt<ILogger>(),
    ),
  );

  getIt.registerLazySingleton<Top100Repository>(
    () => Top100RepositoryImpl(
      httpService: getIt<IHttpService>(),
      selectorsConfig: getIt<SelectorsConfig>(),
      logger: getIt<ILogger>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AnimeListBloc>(
    () => AnimeListBloc(getIt<GetAnimeListUseCase>(), getIt<ILogger>()),
  );

  getIt.registerFactory<SeriesBloc>(
    () => SeriesBloc(getIt<SeriesRepository>(), getIt<ILogger>()),
  );
  getIt.registerFactory<MoviesBloc>(
    () => MoviesBloc(getIt<MoviesRepository>(), getIt<ILogger>()),
  );
  getIt.registerFactory<CatalogBloc>(
    () => CatalogBloc(getIt<CatalogRepository>(), getIt<ILogger>()),
  );
  getIt.registerFactory<Top100Bloc>(
    () => Top100Bloc(getIt<GetTop100PageUseCase>(), getIt<ILogger>()),
  );
  getIt.registerFactory<CollectionsBloc>(
    () => CollectionsBloc(getIt<GetCollectionsUseCase>(), getIt<ILogger>()),
  );
  getIt.registerFactory<VideoPlayerBloc>(
    () => VideoPlayerBloc(getIt<ILogger>()),
  );

  // AnimeDetailBloc for managing anime detail state
  getIt.registerFactory<AnimeDetailBloc>(
    () => AnimeDetailBloc(
      getIt<GetAnimeDetailUseCase>(),
      getIt<ILogger>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<ViewingStateService>(() => ViewingStateService());
  getIt.registerLazySingleton<KodikExtractor>(() => KodikExtractor());

  // Use cases
  getIt.registerLazySingleton<GetAnimeListUseCase>(
    () => GetAnimeListUseCase(getIt<AnimeRepository>()),
  );
  getIt.registerLazySingleton<GetAnimeDetailUseCase>(
    () => GetAnimeDetailUseCase(getIt<AnimeRepository>()),
  );

  getIt.registerLazySingleton<GetSeriesListUseCase>(
    () => GetSeriesListUseCase(getIt<SeriesRepository>()),
  );
  getIt.registerLazySingleton<GetMoviesListUseCase>(
    () => GetMoviesListUseCase(getIt<MoviesRepository>()),
  );
  getIt.registerLazySingleton<GetCatalogPageUseCase>(
    () => GetCatalogPageUseCase(getIt<CatalogRepository>()),
  );
  getIt.registerLazySingleton<GetTop100PageUseCase>(
    () => GetTop100PageUseCase(getIt<Top100Repository>()),
  );
  getIt.registerLazySingleton<GetCollectionsUseCase>(
    () => GetCollectionsUseCase(getIt<AnimeRepository>()),
  );
  getIt.registerLazySingleton<SwitchEpisodeUseCase>(
    () => SwitchEpisodeUseCase(
      getIt<KodikExtractor>(),
      getIt<ViewingStateService>(),
      getIt<ILogger>(),
    ),
  );
  getIt.registerLazySingleton<SwitchTranslationUseCase>(
    () => SwitchTranslationUseCase(
      getIt<KodikExtractor>(),
      getIt<ViewingStateService>(),
      getIt<ILogger>(),
    ),
  );
  getIt.registerLazySingleton<LoadPlayerContentUseCase>(
    () => LoadPlayerContentUseCase(
      getIt<KodikExtractor>(),
      getIt<ViewingStateService>(),
      getIt<ILogger>(),
    ),
  );
  // Initialize cache
  await getIt<CacheLayer>().init();
}
