import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/anime/domain/entities/anime_detail.dart';
import 'package:a_watch/domain/entities/collection.dart';
import 'package:a_watch/domain/entities/page_result.dart';

abstract class AnimeRepository {
  /// Получить список аниме с пагинацией
  Future<PageResult<Anime>> getAnimeList({
    required String url,
    bool useCache = true,
  });

  /// Получить детальную информацию об аниме
  Future<AnimeDetail> getAnimeDetail({
    required String url,
    bool useCache = true,
  });

  /// Поиск аниме по запросу
  Future<PageResult<Anime>> searchAnime({
    required String query,
    int page = 1,
    bool useCache = true,
  });

  /// Очистить кэш
  Future<void> clearCache();

  Future<List<Collection>> getCollections({
    required String url,
    bool useCache = true,
  });
}
