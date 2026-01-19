import 'package:equatable/equatable.dart';

/// Модель фильтров для секции сериалов
class SeriesFilters extends Equatable {
  final Map<String, String> types; // {'1': 'Фильм', '2': 'Сериал', ...}
  final Map<String, String> genres; // {'1': 'Action', '2': 'Comedy', ...}
  final Map<String, String> statuses; // {'1': 'ongoing', '2': 'released', ...}
  final Map<String, String> voices; // {'1': 'AniDUB', '2': 'AniLibria', ...}
  final Map<String, String> licensors; // {'1': 'Crunchyroll', '2': 'Netflix', ...}
  final String sortBy; // 'news_read', 'title', 'year', 'rating', 'vote_num', 'comm_num'
  final int? yearFrom;
  final int? yearTo;
  final double? ratingFrom;
  final double? ratingTo;

  const SeriesFilters({
    this.types = const {},
    this.genres = const {},
    this.statuses = const {},
    this.voices = const {},
    this.licensors = const {},
    this.sortBy = '',
    this.yearFrom,
    this.yearTo,
    this.ratingFrom,
    this.ratingTo,
  });

  SeriesFilters copyWith({
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
    return SeriesFilters(
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

  /// Преобразование в query параметры для URL (GET запросы)
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    // Типы контента - берем ключи (ID) для запроса
    for (final typeKey in types.keys) {
      params['cat[]'] = typeKey;
    }

    // Жанры
    for (final genreKey in genres.keys) {
      params['genre[]'] = genreKey;
    }

    // Статусы
    for (final statusKey in statuses.keys) {
      params['status[]'] = statusKey;
    }

    // Озвучки
    for (final voiceKey in voices.keys) {
      params['voice[]'] = voiceKey;
    }

    // Лицензиаторы
    for (final licensorKey in licensors.keys) {
      params['licensed[]'] = licensorKey;
    }

    // Сортировка
    if (sortBy.isNotEmpty) {
      params['sort'] = sortBy;
    }

    // Год
    if (yearFrom != null || yearTo != null) {
      final yearStr = '${yearFrom ?? ''};${yearTo ?? ''}';
      if (yearStr != ';') {
        params['r.year'] = yearStr;
      }
    }

    // Рейтинг
    if (ratingFrom != null || ratingTo != null) {
      final ratingStr = '${ratingFrom ?? ''};${ratingTo ?? ''}';
      if (ratingStr != ';') {
        params['r.sm_r'] = ratingStr;
      }
    }

    return params;
  }

  /// Преобразование в параметры для POST запроса фильтрации
  Map<String, String> toPostParams({required String url, required String dleHash}) {
    final params = <String, String>{};

    // Категория сериалов - включаем только если выбрана
    if (types.isNotEmpty) {
      params['cat'] = types.keys.first;
    }

    // Сортировка (всегда включаем, даже если пустая)
    params['sort'] = sortBy;

    // Год - всегда включаем диапазон по умолчанию, если не задан явно
    final yearStr = yearFrom != null && yearTo != null
        ? '$yearFrom;$yearTo'
        : '2005;2025'; // Диапазон по умолчанию
    params['r.year'] = yearStr;

    // Рейтинг - всегда включаем диапазон по умолчанию, если не задан явно
    final ratingStr = ratingFrom != null && ratingTo != null
        ? '$ratingFrom;$ratingTo'
        : '0;10'; // Диапазон по умолчанию
    params['r.sm_r'] = ratingStr;

    // URL страницы
    params['url'] = url;

    // DLE хэш
    params['dle_hash'] = dleHash;

    return params;
  }

  /// Создание URL для пагинации с фильтрами
  String buildPaginationUrl(String baseUrl, int page) {
    final params = toQueryParams();
    params['cat'] = '2'; // Добавляем категорию

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final separator = baseUrl.contains('?') ? '&' : '?';
    return '$baseUrl$separator$queryString';
  }

  /// Проверка, есть ли активные фильтры
  bool get hasActiveFilters =>
      types.isNotEmpty ||
      genres.isNotEmpty ||
      statuses.isNotEmpty ||
      voices.isNotEmpty ||
      licensors.isNotEmpty ||
      sortBy.isNotEmpty || // Любая сортировка считается активным фильтром
      yearFrom != null ||
      yearTo != null ||
      ratingFrom != null ||
      ratingTo != null;

  /// Создание пустых фильтров
  factory SeriesFilters.empty() => const SeriesFilters();

  /// Безопасный парсинг int из dynamic
  static int? _safeParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  /// Безопасный парсинг double из dynamic
  static double? _safeParseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Создание из JSON с безопасным парсингом типов
  factory SeriesFilters.fromJson(Map<String, dynamic> json) {
    // Helper to convert list to map or handle existing map
    Map<String, String> listToMap(dynamic value) {
      if (value is Map<String, dynamic>) {
        return Map<String, String>.from(value);
      } else if (value is List) {
        // Convert old list format to map with keys as values
        return Map<String, String>.fromEntries(
          value.map((item) => MapEntry(item.toString(), item.toString()))
        );
      }
      return {};
    }

    return SeriesFilters(
      types: listToMap(json['types']),
      genres: listToMap(json['genres']),
      statuses: listToMap(json['statuses']),
      voices: listToMap(json['voices']),
      licensors: listToMap(json['licensors']),
      sortBy: json['sortBy'] as String? ?? '',
      yearFrom: _safeParseInt(json['yearFrom']),
      yearTo: _safeParseInt(json['yearTo']),
      ratingFrom: _safeParseDouble(json['ratingFrom']),
      ratingTo: _safeParseDouble(json['ratingTo']),
    );
  }

  @override
  List<Object?> get props => [
        types,
        genres,
        statuses,
        voices,
        licensors,
        sortBy,
        yearFrom,
        yearTo,
        ratingFrom,
        ratingTo,
      ];
}
