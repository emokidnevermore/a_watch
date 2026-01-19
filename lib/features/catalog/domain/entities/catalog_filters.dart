import 'package:a_watch/domain/entities/series_filters.dart';

/// Модель фильтров для секции каталога
/// Наследуется от SeriesFilters поскольку фильтры идентичны
class CatalogFilters extends SeriesFilters {
  const CatalogFilters({
    super.types = const {},
    super.genres = const {},
    super.statuses = const {},
    super.voices = const {},
    super.licensors = const {},
    super.sortBy = '',
    super.yearFrom,
    super.yearTo,
    super.ratingFrom,
    super.ratingTo,
  });

  @override
  CatalogFilters copyWith({
    Map<String, String>? types,
    Map<String, String>? genres,
    Map<String, String>? statuses,
    Map<String, String>? voices,
    Map<String, String>? licensors,
    String? sortBy,
    int? yearFrom,
    int? yearTo,
    double? ratingFrom,
    double? ratingTo,
  }) {
    return CatalogFilters(
      types: types ?? this.types,
      genres: genres ?? this.genres,
      statuses: statuses ?? this.statuses,
      voices: voices ?? this.voices,
      licensors: licensors ?? this.licensors,
      sortBy: sortBy ?? this.sortBy,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      ratingFrom: ratingFrom ?? this.ratingFrom,
      ratingTo: ratingTo ?? this.ratingTo,
    );
  }

  /// Создание пустых фильтров
  factory CatalogFilters.empty() => const CatalogFilters();

  /// Создание из JSON
  factory CatalogFilters.fromJson(Map<String, dynamic> json) {
    return CatalogFilters(
      types: SeriesFilters.fromJson(json).types,
      genres: SeriesFilters.fromJson(json).genres,
      statuses: SeriesFilters.fromJson(json).statuses,
      voices: SeriesFilters.fromJson(json).voices,
      licensors: SeriesFilters.fromJson(json).licensors,
      sortBy: SeriesFilters.fromJson(json).sortBy,
      yearFrom: SeriesFilters.fromJson(json).yearFrom,
      yearTo: SeriesFilters.fromJson(json).yearTo,
      ratingFrom: SeriesFilters.fromJson(json).ratingFrom,
      ratingTo: SeriesFilters.fromJson(json).ratingTo,
    );
  }

  /// Преобразование в JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'types': types,
      'genres': genres,
      'statuses': statuses,
      'voices': voices,
      'licensors': licensors,
      'sortBy': sortBy,
      'yearFrom': yearFrom,
      'yearTo': yearTo,
      'ratingFrom': ratingFrom,
      'ratingTo': ratingTo,
    };
  }
}
