import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';

/// Репозиторий для работы с каталогом аниме
abstract class CatalogRepository {
  /// Получение страницы каталога
  Future<CatalogPageData> getCatalogPage({
    required String url,
    CatalogFilters? filters,
    bool useCache = true,
  });

  /// Загрузка следующей страницы каталога
  Future<CatalogPageData> loadMoreCatalog({
    required String nextPageUrl,
    CatalogFilters? filters,
  });

  /// Очистка кеша
  Future<void> clearCache();
}
