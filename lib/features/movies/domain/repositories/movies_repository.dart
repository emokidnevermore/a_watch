import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';

abstract class MoviesRepository {
  /// Получить страницу фильмов с фильтрами
  Future<SeriesPageData> getMoviesPage({
    required String url,
    SeriesFilters? filters,
    bool useCache = true,
  });

  /// Загрузить больше фильмов (пагинация)
  Future<SeriesPageData> loadMoreMovies({
    required String nextPageUrl,
    SeriesFilters? filters,
  });

  /// Очистить кэш
  Future<void> clearCache();
}
