import 'dart:convert';
import 'package:a_watch/core/cache/cache_layer.dart';
import 'package:a_watch/core/cache/cache_config.dart';
import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/catalog_page_parser.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';
import 'package:a_watch/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final IHttpService _httpService;
  final SelectorsConfig _selectorsConfig;
  final CacheConfig _cacheConfig;
  final ILogger _logger;

  CatalogRepositoryImpl({
    required IHttpService httpService,
    required SelectorsConfig selectorsConfig,
    required CacheConfig cacheConfig,
    required ILogger logger,
  }) : _httpService = httpService,
       _selectorsConfig = selectorsConfig,
       _cacheConfig = cacheConfig,
       _logger = logger {
    _logger.logInfo('CatalogRepositoryImpl CONSTRUCTOR called', 'CatalogRepository');
  }

  @override
  Future<CatalogPageData> getCatalogPage({
    required String url,
    CatalogFilters? filters,
    bool useCache = true,
  }) async {
    _logger.logDebug('REPOSITORY: getCatalogPage called with url: $url, hasActiveFilters: ${filters?.hasActiveFilters}', 'CatalogRepository');
    _logger.logInfo('getCatalogPage called with url: $url, hasActiveFilters: ${filters?.hasActiveFilters}, filters: ${filters?.toJson()}', 'CatalogRepository');

    // Создаем ключ кеша с учетом фильтров
    final filtersKey = filters?.hasActiveFilters == true
        ? '_${filters!.toQueryParams().toString()}'
        : '';
    final cacheKey = 'catalog_page_${Uri.parse(url).path}$filtersKey';

    if (useCache) {
      final cached = await CacheLayer.instance.getModel<CatalogPageData>(
        cacheKey,
        (jsonString) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          return CatalogPageData.fromJson(json);
        },
      );
      if (cached != null) {
        return cached;
      }
    }

    // Если есть активные фильтры, используем POST запрос для фильтрации
    if (filters != null && filters.types.isNotEmpty) {
      _logger.logInfo('FILTERING: About to call _getFilteredCatalogPage with types=${filters.types}', 'CatalogRepository');
      return _getFilteredCatalogPage(url, filters, cacheKey, useCache);
    } else {
      _logger.logInfo('FILTERING: Skipping filters, hasActiveFilters=${filters?.hasActiveFilters}, types=${filters?.types}, sortBy="${filters?.sortBy}"', 'CatalogRepository');
    }

    // Иначе используем обычный GET запрос
    return _getRegularCatalogPage(url, filters, cacheKey, useCache);
  }

  /// Получение страницы с фильтрами через POST запрос
  Future<CatalogPageData> _getFilteredCatalogPage(
    String url,
    CatalogFilters filters,
    String cacheKey,
    bool useCache,
  ) async {
    _logger.logInfo('FILTERING: _getFilteredCatalogPage ENTERED with types=${filters.types}, sortBy="${filters.sortBy}"', 'CatalogRepository');

    try {
      // Сначала получаем страницу для извлечения актуального DLE хэша
      _logger.logError('FILTERING: Getting regular page for DLE hash extraction', 'CatalogRepository');
      final pageData = await _getRegularCatalogPage(url, null, '${cacheKey}_page', false);
      _logger.logError('FILTERING: Regular page loaded, DLE hash: ${pageData.dleHash}', 'CatalogRepository');

      // Добавляем задержку между запросами
      await Future.delayed(const Duration(seconds: 2));

      // Используем захардкоженный dle_hash
      final dleHash = 'd210566a048a9c9353a82bcc76f0d296cf5d3fda';

      // Извлекаем путь из URL для POST запроса
      final uri = Uri.parse(url);
      final urlPath = uri.path;

      // Формируем тело запроса
      final postParams = filters.toPostParams(url: urlPath, dleHash: dleHash);
      _logger.logError('FILTERING: Generated POST params: $postParams', 'CatalogRepository');

      final dataParams = postParams.entries
          .where((e) => e.key != 'url' && e.key != 'dle_hash')
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value).replaceAll('%3B', '%253B')}')
          .join('&');
      final body = 'data=${Uri.encodeComponent(dataParams)}&url=${Uri.encodeComponent(urlPath)}&dle_hash=$dleHash';

      // URL для AJAX запроса
      final ajaxUrl = 'https://yummyanime.tv/engine/lazydev/dle_filter/ajax.php';
      _logger.logError('FILTERING: AJAX URL: $ajaxUrl', 'CatalogRepository');
      _logger.logError('FILTERING: Request body: $body', 'CatalogRepository');

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

      _logger.logError('FILTERING: Sending filter POST request', 'CatalogRepository');

      final response = await _httpService.post(
        ajaxUrl,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.logError('FILTERING: Parsed JSON response keys: ${jsonResponse.keys}', 'CatalogRepository');

        final error = jsonResponse['error'];
        if (error == null || error == false || error.toString().isEmpty) {
          final parseResult = await _parseAjaxResponse(jsonResponse, _selectorsConfig);
          _logger.logError('FILTERING: Parsing completed, found ${parseResult.items.length} items', 'CatalogRepository');

          if (parseResult.items.isEmpty) {
            _logger.logError('FILTERING: Server returned empty results', 'CatalogRepository');
            throw Exception('Сервер вернул пустые результаты для категории.');
          }

          if (useCache) {
            await CacheLayer.instance.setModel(
              cacheKey,
              _catalogPageDataToJson(parseResult),
              _cacheConfig.getTtlForType('catalog_page'),
            );
          }
          return parseResult;
        } else {
          _logger.logError('FILTERING: Filter request returned error: $error', 'CatalogRepository');
          throw Exception('Server returned error: $error');
        }
      } else {
        _logger.logError('FILTERING: Filter request failed with status: ${response.statusCode}', 'CatalogRepository');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.logError('FILTERING: Exception in _getFilteredCatalogPage: $e', 'CatalogRepository');
      _logger.logError('FILTERING: Stack trace: $stackTrace', 'CatalogRepository');
      rethrow;
    }
  }

  /// Получение обычной страницы через GET запрос
  Future<CatalogPageData> _getRegularCatalogPage(
    String url,
    CatalogFilters? filters,
    String cacheKey,
    bool useCache,
  ) async {
    final uri = Uri.parse(url);
    final queryParams = filters?.toQueryParams() ?? {};

    final fullUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });

    final response = await _httpService.get(fullUri.toString());

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final html = response.body;

    // Парсим с помощью CatalogPageParser
    final selectors = _selectorsConfig.getSelectors('catalog_page') ?? {};
    final parser = CatalogPageParser();

    final parseResult = await parser.parse(
      htmlContent: html,
      selectors: selectors,
      config: _selectorsConfig,
    );

    if (useCache) {
      await CacheLayer.instance.setModel(
        cacheKey,
        _catalogPageDataToJson(parseResult),
        _cacheConfig.getTtlForType('catalog_page'),
      );
    }

    return parseResult;
  }

  @override
  Future<CatalogPageData> loadMoreCatalog({
    required String nextPageUrl,
    CatalogFilters? filters,
  }) async {
    return getCatalogPage(
      url: nextPageUrl,
      filters: filters,
      useCache: false,
    );
  }

  @override
  Future<void> clearCache() async {
    await CacheLayer.instance.clear();
  }

  Map<String, dynamic> _catalogPageDataToJson(CatalogPageData data) {
    return {
      'carousel': data.carousel.map(_animeToJson).toList(),
      'items': data.items.map(_animeToJson).toList(),
      'currentPage': data.currentPage,
      'totalPages': data.totalPages,
      'availableFilters': (data.availableFilters as dynamic).toJson(),
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
  Future<CatalogPageData> _parseAjaxResponse(Map<String, dynamic> jsonResponse, SelectorsConfig config) async {
    _logger.logInfo('Parsing AJAX response with keys: ${jsonResponse.keys}', 'CatalogRepository');

    String? htmlContent;
    if (jsonResponse.containsKey('text') && jsonResponse['text'] != null) {
      final text = jsonResponse['text'];
      if (text is String) {
        htmlContent = text;
      }
    } else if (jsonResponse.containsKey('content') && jsonResponse['content'] != null) {
      final content = jsonResponse['content'];
      if (content is String) {
        htmlContent = content;
      }
    }

    if (htmlContent == null) {
      _logger.logError('htmlContent is null, invalid AJAX response', 'CatalogRepository');
      throw Exception('Invalid AJAX response: missing content field');
    }

    if (htmlContent.trim().isEmpty) {
      _logger.logError('FILTERING: HTML content is empty', 'CatalogRepository');
      return CatalogPageData.empty();
    }

    try {
      final selectors = _selectorsConfig.getSelectors('catalog_page') ?? {};
      final parser = CatalogPageParser(logger: _logger);

      final result = await parser.parseAjaxResponse(
        htmlContent: htmlContent,
        selectors: selectors,
        config: _selectorsConfig,
        baseUrl: 'https://yummyanime.tv',
      );

      _logger.logInfo('AJAX parsing completed, found ${result.items.length} items', 'CatalogRepository');
      return result;
    } catch (e, stackTrace) {
      _logger.logError('FILTERING: Error parsing AJAX response HTML: $e', 'CatalogRepository');
      _logger.logError('FILTERING: Stack trace: $stackTrace', 'CatalogRepository');
      return CatalogPageData.empty();
    }
  }
}
