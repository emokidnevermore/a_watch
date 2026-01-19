import 'dart:convert';
import 'package:a_watch/core/cache/cache_layer.dart';
import 'package:a_watch/core/cache/cache_config.dart';
import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/series_page_parser.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/features/series/domain/repositories/series_repository.dart';

class SeriesRepositoryImpl implements SeriesRepository {
  final IHttpService _httpService;
  final SelectorsConfig _selectorsConfig;
  final CacheConfig _cacheConfig;
  final ILogger _logger;

  SeriesRepositoryImpl({
    required IHttpService httpService,
    required SelectorsConfig selectorsConfig,
    required CacheConfig cacheConfig,
    required ILogger logger,
  }) : _httpService = httpService,
       _selectorsConfig = selectorsConfig,
       _cacheConfig = cacheConfig,
       _logger = logger {
    _logger.logInfo('SeriesRepositoryImpl CONSTRUCTOR called', 'SeriesRepository');
  }

  @override
  Future<SeriesPageData> getSeriesPage({
    required String url,
    SeriesFilters? filters,
    bool useCache = true,
  }) async {
    _logger.logDebug('REPOSITORY: getSeriesPage called with url: $url, hasActiveFilters: ${filters?.hasActiveFilters}', 'SeriesRepository');
    _logger.logInfo('getSeriesPage called with url: $url, hasActiveFilters: ${filters?.hasActiveFilters}, filters: ${filters?.toJson()}', 'SeriesRepository');

    // Создаем ключ кеша с учетом фильтров
    final filtersKey = filters?.hasActiveFilters == true
        ? '_${filters!.toQueryParams().toString()}'
        : '';
    final cacheKey = 'series_page_${Uri.parse(url).path}$filtersKey';

    if (useCache) {
      final cached = await CacheLayer.instance.getModel<SeriesPageData>(
        cacheKey,
        (jsonString) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          return SeriesPageData.fromJson(json);
        },
      );
      if (cached != null) {
        return cached;
      }
    }

    // Если есть активные фильтры, используем POST запрос для фильтрации
    if (filters != null && filters.types.isNotEmpty) {
      _logger.logInfo('FILTERING: About to call _getFilteredSeriesPage with types=${filters.types}', 'SeriesRepository');
      _logger.logInfo('FILTERING: hasActiveFilters=${filters.hasActiveFilters}, types=${filters.types}, genres=${filters.genres}, sortBy="${filters.sortBy}"', 'SeriesRepository');
      return _getFilteredSeriesPage(url, filters, cacheKey, useCache);
    } else {
      _logger.logInfo('FILTERING: Skipping filters, hasActiveFilters=${filters?.hasActiveFilters}, types=${filters?.types}, sortBy="${filters?.sortBy}"', 'SeriesRepository');
    }

    // Иначе используем обычный GET запрос
    return _getRegularSeriesPage(url, filters, cacheKey, useCache);
  }

  /// Получение страницы с фильтрами через POST запрос
  Future<SeriesPageData> _getFilteredSeriesPage(
    String url,
    SeriesFilters filters,
    String cacheKey,
    bool useCache,
  ) async {
    _logger.logInfo('FILTERING: _getFilteredSeriesPage ENTERED with types=${filters.types}, sortBy="${filters.sortBy}"', 'SeriesRepository');
    _logger.logError('FILTERING: _getFilteredSeriesPage called with types=${filters.types}, sortBy="${filters.sortBy}"', 'SeriesRepository');

    try {
      // Сначала получаем страницу для извлечения актуального DLE хэша
      _logger.logError('FILTERING: Getting regular page for DLE hash extraction', 'SeriesRepository');
      final pageData = await _getRegularSeriesPage(url, null, '${cacheKey}_page', false);
      _logger.logError('FILTERING: Regular page loaded, DLE hash: ${pageData.dleHash}', 'SeriesRepository');

      // Добавляем задержку между запросами
      await Future.delayed(const Duration(seconds: 2));

      // Используем захардкоженный dle_hash
      final dleHash = 'd210566a048a9c9353a82bcc76f0d296cf5d3fda';

      // Извлекаем путь из URL для POST запроса
      final uri = Uri.parse(url);
      final urlPath = uri.path; // Например: /series-y10/

      // Формируем тело запроса в формате рабочего примера
      final postParams = filters.toPostParams(url: urlPath, dleHash: dleHash);
      _logger.logError('FILTERING: Generated POST params: $postParams', 'SeriesRepository');
      _logger.logError('FILTERING: Filters types keys: ${filters.types.keys.toList()}', 'SeriesRepository');
      _logger.logError('FILTERING: Filters types values: ${filters.types.values.toList()}', 'SeriesRepository');

      // Точное соответствие формату браузера: двойное кодирование только для ; в значениях
      final dataParams = postParams.entries
          .where((e) => e.key != 'url' && e.key != 'dle_hash')
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value).replaceAll('%3B', '%253B')}')
          .join('&');
      final body = 'data=${Uri.encodeComponent(dataParams)}&url=${Uri.encodeComponent(urlPath)}&dle_hash=$dleHash';

      // URL для AJAX запроса
      final ajaxUrl = 'https://yummyanime.tv/engine/lazydev/dle_filter/ajax.php';
      _logger.logError('FILTERING: AJAX URL: $ajaxUrl', 'SeriesRepository');
      _logger.logError('FILTERING: Request body: $body', 'SeriesRepository');

      // Заголовки для POST запроса
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Referer': url,
        'x-requested-with': 'XMLHttpRequest',
        'origin': 'https://yummyanime.tv',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'priority': 'u=1, i',
      };

      _logger.logError('FILTERING: Sending filter POST request with extracted dle_hash: $dleHash', 'SeriesRepository');
      _logger.logError('FILTERING: Final request body: $body', 'SeriesRepository');
      _logger.logError('FILTERING: Request headers: $headers', 'SeriesRepository');

      final response = await _httpService.post(
        ajaxUrl,
        headers: headers,
        body: body,
      );

      // Логируем полный ответ для отладки
      _logger.logError('FILTERING: Filter POST response status: ${response.statusCode}', 'SeriesRepository');
      _logger.logError('FILTERING: Filter POST response body length: ${response.body.length}', 'SeriesRepository');
      _logger.logError('FILTERING: Filter POST response headers: ${response.headers}', 'SeriesRepository');
      _logger.logError('FILTERING: ===== FULL REQUEST BODY =====', 'SeriesRepository');
      _logger.logError('FILTERING: $body', 'SeriesRepository');
      _logger.logError('FILTERING: ===== END REQUEST BODY =====', 'SeriesRepository');

      // Проверяем успешность запроса
      if (response.statusCode == 200) {
        _logger.logError('FILTERING: ===== FULL RESPONSE BODY =====', 'SeriesRepository');
        _logger.logError('FILTERING: ${response.body}', 'SeriesRepository');
        _logger.logError('FILTERING: ===== END RESPONSE BODY =====', 'SeriesRepository');

        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.logError('FILTERING: Parsed JSON response keys: ${jsonResponse.keys}', 'SeriesRepository');

        final error = jsonResponse['error'];
        _logger.logError('FILTERING: Error field value: $error (type: ${error?.runtimeType})', 'SeriesRepository');

        if (error == null || error == false || error.toString().isEmpty) {
          _logger.logError('FILTERING: Filter request successful, proceeding to parse response', 'SeriesRepository');
          // Парсим ответ
          final parseResult = await _parseAjaxResponse(jsonResponse, _selectorsConfig);
          _logger.logError('FILTERING: Parsing completed, found ${parseResult.items.length} items', 'SeriesRepository');
          _logger.logError('FILTERING: First few items titles: ${parseResult.items.take(3).map((item) => item.title).toList()}', 'SeriesRepository');

          // ВАЛИДАЦИЯ: Проверяем что сервер вернул результаты для запрошенной категории
          final requestedCategoryKey = filters.types.keys.first;
          _logger.logError('FILTERING: Requested category key: $requestedCategoryKey', 'SeriesRepository');

          if (parseResult.items.isEmpty) {
            _logger.logError('FILTERING: Server returned empty results - this might indicate category fallback', 'SeriesRepository');
            throw Exception('Сервер вернул пустые результаты для категории "$requestedCategoryKey". Возможно, категория не поддерживается или произошла ошибка на сервере.');
          }

          // Дополнительная проверка: если сервер делает fallback, показать предупреждение
          _logger.logError('FILTERING: Validation passed - returning results', 'SeriesRepository');

          if (useCache) {
            await CacheLayer.instance.setModel(
              cacheKey,
              _seriesPageDataToJson(parseResult),
              _cacheConfig.getTtlForType('series_page'),
            );
          }
          return parseResult;
        } else {
          _logger.logError('FILTERING: Filter request returned error: $error', 'SeriesRepository');
          _logger.logError('FILTERING: Full error response: $jsonResponse', 'SeriesRepository');
          throw Exception('Server returned error: $error. Full response: $jsonResponse');
        }
      } else {
        _logger.logError('FILTERING: Filter request failed with status: ${response.statusCode}', 'SeriesRepository');
        _logger.logError('FILTERING: Response body: ${response.body}', 'SeriesRepository');
        throw Exception('HTTP Error: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      _logger.logError('FILTERING: Exception in _getFilteredSeriesPage: $e', 'SeriesRepository');
      _logger.logError('FILTERING: Stack trace: $stackTrace', 'SeriesRepository');
      rethrow;
    }
  }

  /// Получение обычной страницы через GET запрос
  Future<SeriesPageData> _getRegularSeriesPage(
    String url,
    SeriesFilters? filters,
    String cacheKey,
    bool useCache,
  ) async {
    // Получаем HTML
    final uri = Uri.parse(url);
    final queryParams = filters?.toQueryParams() ?? {};

    // Строим URL с фильтрами
    final fullUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });

    final response = await _httpService.get(fullUri.toString());

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final html = response.body;

    // Парсим с помощью SeriesPageParser
    final selectors = _selectorsConfig.getSelectors('series_page') ?? {};
    final parser = SeriesPageParser();

    final parseResult = await parser.parse(
      htmlContent: html,
      selectors: selectors,
      config: _selectorsConfig,
    );

    if (useCache) {
      await CacheLayer.instance.setModel(
        cacheKey,
        _seriesPageDataToJson(parseResult),
        _cacheConfig.getTtlForType('series_page'),
      );
    }

    return parseResult;
  }

  @override
  Future<SeriesPageData> loadMoreSeries({
    required String nextPageUrl,
    SeriesFilters? filters,
  }) async {
    return getSeriesPage(
      url: nextPageUrl,
      filters: filters,
      useCache: false, // Для пагинации не используем кеш
    );
  }

  @override
  Future<void> clearCache() async {
    // Очищаем весь кеш
    await CacheLayer.instance.clear();
  }

  Map<String, dynamic> _seriesPageDataToJson(SeriesPageData data) {
    return {
      'carousel': data.carousel.map(_animeToJson).toList(),
      'items': data.items.map(_animeToJson).toList(),
      'currentPage': data.currentPage,
      'totalPages': data.totalPages,
      'availableFilters': data.availableFilters.toJson(),
      'nextPageUrl': data.nextPageUrl,
      'prevPageUrl': data.prevPageUrl,
      'dleHash': data.dleHash,
    };
  }

  dynamic _animeToJson(Anime anime) {
    return {
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
    };
  }

  /// Вспомогательный класс для формата тела запроса
  Future<SeriesPageData> _parseAjaxResponse(Map<String, dynamic> jsonResponse, SelectorsConfig config) async {
    _logger.logInfo('Parsing AJAX response with keys: ${jsonResponse.keys}', 'SeriesRepository');

    // Определяем поле с HTML контентом (text или content)
    String? htmlContent;
    if (jsonResponse.containsKey('text') && jsonResponse['text'] != null) {
      final text = jsonResponse['text'];
      if (text is String) {
        htmlContent = text;
        _logger.logInfo('Using "text" field, length: ${htmlContent.length}', 'SeriesRepository');
      }
    } else if (jsonResponse.containsKey('content') && jsonResponse['content'] != null) {
      final content = jsonResponse['content'];
      if (content is String) {
        htmlContent = content;
        _logger.logInfo('Using "content" field, length: ${htmlContent.length}', 'SeriesRepository');
      }
    }

    if (htmlContent == null) {
      _logger.logError('htmlContent is null, invalid AJAX response', 'SeriesRepository');
      throw Exception('Invalid AJAX response: missing or null content/text field. Full response: $jsonResponse');
    }

    // Проверяем, не пустой ли контент
    if (htmlContent.trim().isEmpty) {
      _logger.logError('FILTERING: HTML content is empty, returning empty result', 'SeriesRepository');
      return SeriesPageData.empty();
    }

    _logger.logInfo('HTML content starts with: ${htmlContent.substring(0, htmlContent.length < 100 ? htmlContent.length : 100)}...', 'SeriesRepository');

    try {
      // Парсим HTML контент
      final selectors = _selectorsConfig.getSelectors('series_page') ?? {};
      final parser = SeriesPageParser(logger: _logger);

      final result = await parser.parseAjaxResponse(
        htmlContent: htmlContent,
        selectors: selectors,
        config: _selectorsConfig,
        baseUrl: 'https://yummyanime.tv',
      );

      _logger.logInfo('AJAX parsing completed, found ${result.items.length} items', 'SeriesRepository');
      return result;
    } catch (e, stackTrace) {
      _logger.logError('FILTERING: Error parsing AJAX response HTML: $e', 'SeriesRepository');
      _logger.logError('FILTERING: Stack trace: $stackTrace', 'SeriesRepository');
      _logger.logError('FILTERING: HTML content that failed to parse: ${htmlContent.substring(0, htmlContent.length < 500 ? htmlContent.length : 500)}', 'SeriesRepository');

      // Если парсинг не удался, возвращаем пустой результат вместо падения
      _logger.logError('FILTERING: Returning empty result due to parsing error', 'SeriesRepository');
      return SeriesPageData.empty();
    }
  }
}

// Расширение для SeriesFilters
extension SeriesFiltersJson on SeriesFilters {
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

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static SeriesFilters fromJson(Map<String, dynamic> json) {
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
      yearFrom: _parseInt(json['yearFrom']),
      yearTo: _parseInt(json['yearTo']),
      ratingFrom: _parseDouble(json['ratingFrom']),
      ratingTo: _parseDouble(json['ratingTo']),
    );
  }
}
