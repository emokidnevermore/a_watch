import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/iparser.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';

/// Парсер для страницы каталога
class CatalogPageParser implements IParser<CatalogPageData> {
  final ILogger? _logger;

  CatalogPageParser({ILogger? logger}) : _logger = logger;

  @override
  Future<CatalogPageData> parse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
  }) async {
    final document = parser.parse(htmlContent);
    final errors = <String>[];

    try {
      // Парсинг карусели популярных аниме (если есть)
      final carousel = _parseCarousel(document, config);

      // Парсинг доступных фильтров
      final availableFilters = _parseAvailableFilters(document);

      // Парсинг списка аниме
      final items = _parseAnimeList(document, config);

      // Парсинг пагинации
      final pagination = _parsePagination(document, config);

      // Извлечение DLE хэша
      final dleHash = _extractDleHash(htmlContent);

      return CatalogPageData(
        carousel: carousel,
        items: items,
        currentPage: pagination.currentPage,
        totalPages: pagination.totalPages,
        availableFilters: availableFilters,
        nextPageUrl: pagination.nextPageUrl,
        prevPageUrl: pagination.prevPageUrl,
        dleHash: dleHash,
      );
    } catch (e) {
      errors.add('Error parsing catalog page: $e');
      return CatalogPageData.empty();
    }
  }

  /// Парсинг AJAX ответа с фильтрами
  Future<CatalogPageData> parseAjaxResponse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
    required String baseUrl,
  }) async {
    final document = parser.parse(htmlContent);
    final errors = <String>[];

    try {
      // Для AJAX ответа парсим только список аниме и пагинацию
      final carousel = <Anime>[]; // Пустая карусель для AJAX ответов

      // Парсинг доступных фильтров (пустые для AJAX)
      final availableFilters = CatalogFilters.empty();

      // Парсинг списка аниме
      final items = _parseAnimeListAjax(document, config);

      // Парсинг пагинации
      final pagination = _parsePagination(document, config);

      return CatalogPageData(
        carousel: carousel,
        items: items,
        currentPage: pagination.currentPage,
        totalPages: pagination.totalPages,
        availableFilters: availableFilters,
        nextPageUrl: pagination.nextPageUrl,
        prevPageUrl: pagination.prevPageUrl,
      );
    } catch (e) {
      errors.add('Error parsing AJAX catalog page: $e');
      return CatalogPageData.empty();
    }
  }

  @override
  bool canParse(String html) {
    // Проверяем наличие элементов характерных для страницы каталога
    return html.contains('catalog-y5') ||
           html.contains('#filter-wrap');
  }

  @override
  String getDataType() => 'catalog_page';

  /// Парсинг карусели популярных аниме
  List<Anime> _parseCarousel(document, SelectorsConfig config) {
    final carouselItems = document.querySelectorAll('#owl-top .movie-item');
    final result = <Anime>[];

    for (final item in carouselItems.take(15)) {
      try {
        final anime = _parseAnimeItem(item, config);
        if (anime != null) {
          result.add(anime);
        }
      } catch (e) {
        continue;
      }
    }

    return result;
  }

  /// Парсинг доступных фильтров
  CatalogFilters _parseAvailableFilters(document) {
    final types = <String, String>{};
    final genres = <String, String>{};
    final statuses = <String, String>{};
    final voices = <String, String>{};
    final licensors = <String, String>{};

    // Парсим dropdown элементы
    final allDropdownElements = document.querySelectorAll('.dropdown-option');

    // Группируем по data-group
    final groupedElements = <String, List<dom.Element>>{};
    for (final element in allDropdownElements) {
      final dataGroup = element.attributes['data-group'] ?? 'unknown';
      groupedElements.putIfAbsent(dataGroup, () => []).add(element);
    }

    // Типы контента
    var typeElements = document.querySelectorAll('.dropdown-option[data-group="#"]');
    if (typeElements.isEmpty) {
      typeElements = document.querySelectorAll('.dropdown-option[data-group="category"]');
    }
    if (typeElements.isEmpty) {
      typeElements = document.querySelectorAll('.dropdown-option');
    }

    for (final element in typeElements) {
      final key = element.attributes['data-key'];
      final name = element.text.trim();
      if (key != null && key.isNotEmpty && name.isNotEmpty) {
        types[key] = name;
      }
    }

    // Если не нашли dropdown элементы, пробуем старый способ с select
    if (types.isEmpty) {
      final typeOptions = document.querySelectorAll('#filter-wrap select[name="cat"] option');
      for (final option in typeOptions) {
        final value = option.attributes['value'];
        final text = option.text.trim();
        if (value != null && value.isNotEmpty && text.isNotEmpty) {
          types[value] = text;
        }
      }
    }

    // Жанры
    final genreElements = document.querySelectorAll('.dropdown-option[data-group="genre"]');
    for (final element in genreElements) {
      final key = element.attributes['data-key'];
      final name = element.text.trim();
      if (key != null && key.isNotEmpty && name.isNotEmpty) {
        genres[key] = name;
      }
    }

    if (genres.isEmpty) {
      final genreOptions = document.querySelectorAll('#filter-wrap select[name="genre"] option');
      for (final option in genreOptions) {
        final value = option.attributes['value'];
        final text = option.text.trim();
        if (value != null && value.isNotEmpty && text.isNotEmpty) {
          genres[value] = text;
        }
      }
    }

    // Статусы
    final statusElements = document.querySelectorAll('.dropdown-option[data-group="status"]');
    for (final element in statusElements) {
      final key = element.attributes['data-key'];
      final name = element.text.trim();
      if (key != null && key.isNotEmpty && name.isNotEmpty) {
        statuses[key] = name;
      }
    }

    if (statuses.isEmpty) {
      final statusOptions = document.querySelectorAll('#filter-wrap select[name="status"] option');
      for (final option in statusOptions) {
        final value = option.attributes['value'];
        final text = option.text.trim();
        if (value != null && value.isNotEmpty && text.isNotEmpty) {
          statuses[value] = text;
        }
      }
    }

    // Озвучки
    final voiceElements = document.querySelectorAll('.dropdown-option[data-group="voice"]');
    for (final element in voiceElements) {
      final key = element.attributes['data-key'];
      final name = element.text.trim();
      if (key != null && key.isNotEmpty && name.isNotEmpty) {
        voices[key] = name;
      }
    }

    if (voices.isEmpty) {
      final voiceOptions = document.querySelectorAll('#filter-wrap select[name="voice"] option');
      for (final option in voiceOptions) {
        final value = option.attributes['value'];
        final text = option.text.trim();
        if (value != null && value.isNotEmpty && text.isNotEmpty) {
          voices[value] = text;
        }
      }
    }

    // Лицензиаторы
    final licensorElements = document.querySelectorAll('.dropdown-option[data-group="licensed"]');
    for (final element in licensorElements) {
      final key = element.attributes['data-key'];
      final name = element.text.trim();
      if (key != null && key.isNotEmpty && name.isNotEmpty) {
        licensors[key] = name;
      }
    }

    if (licensors.isEmpty) {
      final licensorOptions = document.querySelectorAll('#filter-wrap select[name="licensed"] option');
      for (final option in licensorOptions) {
        final value = option.attributes['value'];
        final text = option.text.trim();
        if (value != null && value.isNotEmpty && text.isNotEmpty) {
          licensors[value] = text;
        }
      }
    }

    return CatalogFilters(
      types: types,
      genres: genres,
      statuses: statuses,
      voices: voices,
      licensors: licensors,
    );
  }

  /// Парсинг списка аниме
  List<Anime> _parseAnimeList(document, SelectorsConfig config) {
    final listItems = document.querySelectorAll('#dle-content .movie-item');
    final result = <Anime>[];

    for (final item in listItems) {
      try {
        final anime = _parseAnimeItem(item, config);
        if (anime != null) {
          result.add(anime);
        }
      } catch (e) {
        continue;
      }
    }

    return result;
  }

  /// Парсинг списка аниме для AJAX ответа
  List<Anime> _parseAnimeListAjax(document, SelectorsConfig config) {
    final listItems = document.querySelectorAll('.movie-item');
    final result = <Anime>[];

    for (final item in listItems) {
      try {
        final anime = _parseAnimeItem(item, config);
        if (anime != null) {
          result.add(anime);
        }
      } catch (e) {
        continue;
      }
    }

    return result;
  }

  /// Парсинг одного элемента аниме
  Anime? _parseAnimeItem(item, SelectorsConfig config) {
    final linkElement = item.querySelector('.movie-item__link[href]');
    final posterElement = item.querySelector('.movie-item__img img[src]');
    final titleElement = item.querySelector('.movie-item__title');
    final ratingElement = item.querySelector('.movie-item__rating');
    final yearElement = item.querySelector('.movie-item__meta span');
    final statusElement = item.querySelector('.movie-item__label');

    final link = linkElement?.attributes['href'];
    final poster = posterElement?.attributes['src'];
    final title = titleElement?.text.trim();
    final rating = ratingElement?.text.trim();
    final year = yearElement?.text.trim();
    final status = statusElement?.text.trim();

    if (link == null || title == null) {
      return null;
    }

    // Извлекаем количество серий из статуса
    String? episodesCount;
    if (status != null) {
      final match = RegExp(r'(\d+)').firstMatch(status);
      if (match != null) {
        episodesCount = match.group(1);
      }
    }

    return Anime(
      id: _extractIdFromUrl(link),
      title: title,
      slug: _extractSlugFromUrl(link),
      url: _normalizeUrl(link, config.baseUrl),
      poster: _normalizeUrl(poster, config.baseUrl),
      rating: _extractRating(rating),
      year: year,
      genres: [],
      status: status,
      type: 'catalog', // Общий тип для каталога
      episodesCount: episodesCount,
    );
  }

  /// Парсинг пагинации
  _PaginationInfo _parsePagination(document, SelectorsConfig config) {
    final paginationContainer = document.querySelector('.pagination');
    if (paginationContainer == null) {
      return _PaginationInfo.empty();
    }

    final paginationLinks = paginationContainer.querySelectorAll('a[href]');
    String? nextPageUrl;
    String? prevPageUrl;
    int currentPage = 1;
    int totalPages = 1;

    for (final link in paginationLinks) {
      final href = link.attributes['href'];
      final text = link.text.trim();

      if (href != null) {
        if (text.contains('»') || text.contains('Next') || text.contains('>')) {
          nextPageUrl = _normalizeUrl(href, config.baseUrl);
        } else if (text.contains('«') || text.contains('Prev') || text.contains('<')) {
          prevPageUrl = _normalizeUrl(href, config.baseUrl);
        } else {
          final pageNum = int.tryParse(text);
          if (pageNum != null && pageNum > totalPages) {
            totalPages = pageNum;
          }
        }
      }
    }

    final currentPageElement = paginationContainer.querySelector('span:not([class])') ??
                              paginationContainer.querySelector('.pagination__inner span');
    if (currentPageElement != null) {
      currentPage = int.tryParse(currentPageElement.text.trim()) ?? 1;
    }

    return _PaginationInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      nextPageUrl: nextPageUrl,
      prevPageUrl: prevPageUrl,
    );
  }

  // Helper methods
  String _extractIdFromUrl(String? url) {
    if (url == null) return '';
    final match = RegExp(r'/(\d+)-').firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _extractSlugFromUrl(String? url) {
    if (url == null) return '';
    final match = RegExp(r'-(.+?)\.html').firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _normalizeUrl(String? url, String baseUrl) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }

  String? _extractRating(String? ratingText) {
    if (ratingText == null) return null;
    final match = RegExp(r'([\d.]+)').firstMatch(ratingText);
    return match?.group(1);
  }

  /// Извлечение DLE хэша из JavaScript переменной
  String? _extractDleHash(String htmlContent) {
    final match = RegExp(r"var dle_login_hash = '([^']+)'").firstMatch(htmlContent);
    return match?.group(1);
  }
}

/// Вспомогательный класс для информации о пагинации
class _PaginationInfo {
  final int currentPage;
  final int totalPages;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const _PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory _PaginationInfo.empty() => const _PaginationInfo(
        currentPage: 1,
        totalPages: 1,
      );
}
