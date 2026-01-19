import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';

/// Модель данных страницы каталога
/// Наследуется от SeriesPageData поскольку структура идентична
class CatalogPageData extends SeriesPageData {
  const CatalogPageData({
    super.carousel = const [],
    super.items = const [],
    super.currentPage = 1,
    super.totalPages = 1,
    required super.availableFilters,
    super.nextPageUrl,
    super.prevPageUrl,
    super.dleHash,
  });

  @override
  CatalogPageData copyWith({
    List<Anime>? carousel,
    List<Anime>? items,
    int? currentPage,
    int? totalPages,
    CatalogFilters? availableFilters,
    String? nextPageUrl,
    String? prevPageUrl,
    String? dleHash,
  }) {
    return CatalogPageData(
      carousel: carousel ?? this.carousel,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      availableFilters: availableFilters ?? this.availableFilters,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      prevPageUrl: prevPageUrl ?? this.prevPageUrl,
      dleHash: dleHash ?? this.dleHash,
    );
  }

  /// Создание пустых данных
  factory CatalogPageData.empty() => CatalogPageData(
        availableFilters: CatalogFilters.empty(),
      );

  /// Создание из JSON
  factory CatalogPageData.fromJson(Map<String, dynamic> json) {
    return CatalogPageData(
      carousel: SeriesPageData.fromJson(json).carousel,
      items: SeriesPageData.fromJson(json).items,
      currentPage: SeriesPageData.fromJson(json).currentPage,
      totalPages: SeriesPageData.fromJson(json).totalPages,
      availableFilters: CatalogFilters.fromJson(json['availableFilters'] as Map<String, dynamic>? ?? {}),
      nextPageUrl: SeriesPageData.fromJson(json).nextPageUrl,
      prevPageUrl: SeriesPageData.fromJson(json).prevPageUrl,
      dleHash: SeriesPageData.fromJson(json).dleHash,
    );
  }

  /// Override hasNextPage to construct URLs manually for catalog
  @override
  bool get hasNextPage => currentPage < totalPages;

  /// Override nextPageUrl to construct URLs manually for catalog
  @override
  String? get nextPageUrl {
    if (!hasNextPage) return null;
    const baseUrl = 'https://yummyanime.tv/catalog-y5';
    return currentPage + 1 == 1 ? baseUrl : '$baseUrl/page/${currentPage + 1}';
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'carousel': carousel.map((anime) => {
        'id': anime.id,
        'title': anime.title,
        'slug': anime.slug,
        'url': anime.url,
        'poster': anime.poster,
        'rating': anime.rating,
        'year': anime.year,
        'genres': anime.genres,
        'description': anime.description,
        'status': anime.status,
        'type': anime.type,
        'episodesCount': anime.episodesCount,
      }).toList(),
      'items': items.map((anime) => {
        'id': anime.id,
        'title': anime.title,
        'slug': anime.slug,
        'url': anime.url,
        'poster': anime.poster,
        'rating': anime.rating,
        'year': anime.year,
        'genres': anime.genres,
        'description': anime.description,
        'status': anime.status,
        'type': anime.type,
        'episodesCount': anime.episodesCount,
      }).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'availableFilters': (availableFilters as dynamic).toJson(),
      'nextPageUrl': nextPageUrl,
      'prevPageUrl': prevPageUrl,
      'dleHash': dleHash,
    };
  }
}
