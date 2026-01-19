import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';

abstract class SeriesRepository {
  /// Получить страницу сериалов с фильтрами
  Future<SeriesPageData> getSeriesPage({
    required String url,
    SeriesFilters? filters,
    bool useCache = true,
  });

  /// Загрузить больше сериалов (пагинация)
  Future<SeriesPageData> loadMoreSeries({
    required String nextPageUrl,
    SeriesFilters? filters,
  });

  /// Очистить кэш
  Future<void> clearCache();
}
