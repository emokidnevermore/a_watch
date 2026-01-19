import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';
import 'package:a_watch/features/catalog/domain/repositories/catalog_repository.dart';

/// Use case для получения страницы каталога
class GetCatalogPageUseCase {
  final CatalogRepository _repository;

  GetCatalogPageUseCase(this._repository);

  /// Получить страницу каталога
  Future<CatalogPageData> call({
    required String url,
    CatalogFilters? filters,
    bool useCache = true,
  }) {
    return _repository.getCatalogPage(
      url: url,
      filters: filters,
      useCache: useCache,
    );
  }

  /// Загрузить следующую страницу каталога
  Future<CatalogPageData> loadMore({
    required String nextPageUrl,
    CatalogFilters? filters,
  }) {
    return _repository.loadMoreCatalog(
      nextPageUrl: nextPageUrl,
      filters: filters,
    );
  }

  /// Очистить кеш
  Future<void> clearCache() {
    return _repository.clearCache();
  }
}
