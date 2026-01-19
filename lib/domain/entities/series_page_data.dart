import 'package:equatable/equatable.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/series_filters.dart';

/// Безопасный парсинг int из dynamic
int? _safeParseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Модель данных для страницы сериалов
class SeriesPageData extends Equatable {
  final List<Anime> carousel; // Популярные сериалы (карусель)
  final List<Anime> items; // Список сериалов
  final int currentPage;
  final int totalPages;
  final SeriesFilters availableFilters; // Доступные опции фильтров
  final String? nextPageUrl;
  final String? prevPageUrl;
  final String? dleHash; // DLE хэш для AJAX запросов

  const SeriesPageData({
    this.carousel = const [],
    this.items = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    required this.availableFilters,
    this.nextPageUrl,
    this.prevPageUrl,
    this.dleHash,
  });

  /// Общее количество элементов
  int get totalItems => items.length;

  /// Есть ли следующая страница
  bool get hasNextPage => nextPageUrl != null && currentPage < totalPages;

  /// Есть ли предыдущая страница
  bool get hasPrevPage => prevPageUrl != null && currentPage > 1;

  /// Пустые данные
  factory SeriesPageData.empty() => SeriesPageData(
        availableFilters: SeriesFilters.empty(),
      );

  /// Создание из JSON с безопасным парсингом типов
  factory SeriesPageData.fromJson(Map<String, dynamic> json) {
    return SeriesPageData(
      carousel: (json['carousel'] as List<dynamic>?)
          ?.map((item) => Anime.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => Anime.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      currentPage: _safeParseInt(json['currentPage']) ?? 1,
      totalPages: _safeParseInt(json['totalPages']) ?? 1,
      availableFilters: SeriesFilters.fromJson(json['availableFilters'] as Map<String, dynamic>? ?? {}),
      nextPageUrl: json['nextPageUrl'] as String?,
      prevPageUrl: json['prevPageUrl'] as String?,
      dleHash: json['dleHash'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        carousel,
        items,
        currentPage,
        totalPages,
        availableFilters,
        nextPageUrl,
        prevPageUrl,
        dleHash,
      ];
}
