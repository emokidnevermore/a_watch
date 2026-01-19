import 'dart:convert';
import 'package:html/parser.dart' as parser;
import 'package:a_watch/core/cache/cache_layer.dart';
import 'package:a_watch/core/cache/cache_config.dart';
import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/models/anime_dto.dart';
import 'package:a_watch/data/models/page_result_dto.dart';
import 'package:a_watch/data/parser/parser_worker.dart';
import 'package:a_watch/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/collection.dart';
import 'package:a_watch/domain/entities/page_result.dart';
import 'package:a_watch/domain/repositories/anime_repository.dart';

class AnimeRepositoryImpl implements AnimeRepository {
  final IHttpService _httpService;
  final SelectorsConfig _selectorsConfig;
  final CacheConfig _cacheConfig;

  AnimeRepositoryImpl({
    required IHttpService httpService,
    required SelectorsConfig selectorsConfig,
    required CacheConfig cacheConfig,
  }) : _httpService = httpService,
       _selectorsConfig = selectorsConfig,
       _cacheConfig = cacheConfig;

  @override
  Future<PageResult<Anime>> getAnimeList({
    required String url,
    bool useCache = true,
  }) async {
    final cacheKey = 'anime_list_$url';

    if (useCache) {
      final cached = await CacheLayer.instance.getModel<PageResult<Anime>>(
        cacheKey,
        (json) => _deserializePageResult(
          json,
          (item) => _dtoToAnime(AnimeDto.fromMap(item)),
        ),
      );
      if (cached != null) {
        return cached;
      }
    }

    // Extract path from URL to avoid duplication
    final uri = Uri.parse(url);
    final path = uri.path;
    final response = (path.isEmpty || path == '/')
        ? await _httpService.get('')
        : await _httpService.get(path);

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final html = response.body;
    final selectors = _selectorsConfig.getSelectors('list') ?? {};
    final parseResult = ParserWorker.parseList(html, selectors);

    // Парсим все секции: сериалы, фильмы и подборки
    final allAnimes = <AnimeDto>[];

    // Все элементы (уже распаршены в parseResult.items с типом из секции)
    for (final item in parseResult.items) {
      final status = item['status'] as String?;
      final type = item['type'] as String?; // Берем тип из секции
      String? episodesCount;

      // Извлекаем количество серий из статуса, если это сериал
      if (status != null && type == 'serial') {
        final match = RegExp(r'(\d+)').firstMatch(status);
        if (match != null) {
          episodesCount = match.group(1);
        }
      }

      allAnimes.add(
        AnimeDto(
          id: _extractIdFromUrl(item['link']),
          title: item['title'] ?? '',
          slug: _extractSlugFromUrl(item['link']),
          url: _normalizeUrl(item['link']),
          poster: _normalizeUrl(item['poster']),
          rating: _extractRating(item['rating']),
          year: item['year'],
          genres: [],
          description: null,
          status: status,
          type: type,
          episodesCount: episodesCount,
        ),
      );
    }

    final pageResult = PageResultDto<AnimeDto>(
      items: allAnimes,
      page: 1,
      nextPageUrl: parseResult.nextPageUrl != null
          ? _normalizeUrl(parseResult.nextPageUrl!)
          : null,
      prevPageUrl: parseResult.prevPageUrl != null
          ? _normalizeUrl(parseResult.prevPageUrl!)
          : null,
    );

    final domainResult = PageResult<Anime>(
      items: pageResult.items.map(_dtoToAnime).toList(),
      page: pageResult.page,
      nextPageUrl: pageResult.nextPageUrl,
      prevPageUrl: pageResult.prevPageUrl,
    );

    if (useCache) {
      await CacheLayer.instance.setModel(
        cacheKey,
        pageResult.toJson(),
        _cacheConfig.getTtlForType('anime_list'),
      );
    }

    return domainResult;
  }

  @override
  Future<Anime> getAnimeDetail({
    required String url,
    bool useCache = true,
  }) async {
    final cacheKey = 'anime_detail_$url';

    if (useCache) {
      final cached = await CacheLayer.instance.getModel<Anime>(
        cacheKey,
        (json) => AnimeDto.fromJson(json).toDomain(),
      );
      if (cached != null) {
        return cached;
      }
    }

    // Extract path from URL to avoid duplication
    final uri = Uri.parse(url);
    final path = uri.path;
    final response = (path.isEmpty || path == '/')
        ? await _httpService.get('')
        : await _httpService.get(path);

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final html = response.body;
    final selectors = _selectorsConfig.getSelectors('detail') ?? {};
    final parseResult = ParserWorker.parseDetail(html, selectors);

    if (parseResult.items.isEmpty) {
      throw Exception('No anime data found');
    }

    final item = parseResult.items.first;
    final animeDto = AnimeDto(
      id: _extractIdFromUrl(url),
      title: item['title'] ?? '',
      slug: _extractSlugFromUrl(url),
      url: url,
      poster: _normalizeUrl(item['poster']),
      rating: null,
      year: null,
      genres: List<String>.from(item['genres'] ?? []),
      description: item['description'],
    );

    final domainAnime = _dtoToAnime(animeDto);

    if (useCache) {
      await CacheLayer.instance.setModel(
        cacheKey,
        animeDto.toJson(),
        _cacheConfig.getTtlForType('anime_detail'),
      );
    }

    return domainAnime;
  }

  @override
  Future<PageResult<Anime>> searchAnime({
    required String query,
    int page = 1,
    bool useCache = true,
  }) async {
    final searchUrl =
        '$_baseUrl/index.php?do=search&subaction=search&story=$query&page=$page';
    return getAnimeList(url: searchUrl, useCache: useCache);
  }

  @override
  Future<void> clearCache() async {
    await CacheLayer.instance.clear();
  }

  @override
  Future<List<Collection>> getCollections({
    required String url,
    bool useCache = true,
  }) async {
    final cacheKey = 'collections_$url';

    if (useCache) {
      final cached = await CacheLayer.instance.getModel<List<Collection>>(
        cacheKey,
        (json) => _deserializeCollections(json),
      );
      if (cached != null) {
        return cached;
      }
    }

    // Extract path from URL to avoid duplication
    final uri = Uri.parse(url);
    final path = uri.path;
    final response = (path.isEmpty || path == '/')
        ? await _httpService.get('')
        : await _httpService.get(path);

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final html = response.body;
    final collections = _parseCollections(html);

    if (useCache) {
      await CacheLayer.instance.setModel(
        cacheKey,
        json.encode(collections.map((c) => _collectionToMap(c)).toList()),
        _cacheConfig.getTtlForType('collections'),
      );
    }

    return collections;
  }

  // Helper methods
  String get _baseUrl => _selectorsConfig.baseUrl;

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

  String? _extractRating(String? ratingText) {
    if (ratingText == null) return null;
    // Извлекаем рейтинг из строки вроде "★ 7.3"
    final match = RegExp(r'([\d.]+)').firstMatch(ratingText);
    return match?.group(1);
  }

  String _normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return '$_baseUrl$url';
    return '$_baseUrl/$url'; // Если URL не начинается с '/', добавляем baseUrl
  }

  Anime _dtoToAnime(AnimeDto dto) {
    return Anime(
      id: dto.id,
      title: dto.title,
      slug: dto.slug,
      url: dto.url,
      poster: dto.poster,
      rating: dto.rating,
      year: dto.year,
      genres: dto.genres,
      description: dto.description,
      status: dto.status,
      type: dto.type,
      episodesCount: dto.episodesCount,
    );
  }

  // Collections helper methods
  List<Collection> _deserializeCollections(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((item) => _mapToCollection(item)).toList();
  }

  Collection _mapToCollection(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      itemCount: map['itemCount'] ?? 0,
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> _collectionToMap(Collection collection) {
    return {
      'id': collection.id,
      'title': collection.title,
      'description': collection.description,
      'imageUrl': collection.imageUrl,
      'itemCount': collection.itemCount,
      'url': collection.url,
    };
  }

  List<Collection> _parseCollections(String html) {
    final document = parser.parse(html);
    final sections = document.querySelectorAll('.section');

    // Ищем секцию с подборками
    final collectionsSection = sections.firstWhere(
      (section) =>
          section
              .querySelector('h2, h3, .section__title')
              ?.text
              .trim()
              .contains('Подборки') ==
          true,
      orElse: () => sections[2], // Третья секция (по анализу она подборки)
    );

    // Используем селекторы из конфигурации
    final selectors = _selectorsConfig.getSelectors('collections') ?? {};
    final containerSelector =
        selectors['container'] ?? '.section__content.grid-items';
    final container = collectionsSection.querySelector(containerSelector);
    if (container == null) return [];

    final itemSelector = selectors['item'] ?? '.coll.grid-item.hover';
    final collItems = container.querySelectorAll(itemSelector);
    final collections = <Collection>[];

    for (final item in collItems) {
      // Используем селекторы из конфигурации
      final link = item.attributes[selectors['link'] ?? 'href'];
      final img = item
          .querySelector(selectors['image'] ?? 'img[src]')
          ?.attributes['src'];
      final title = item
          .querySelector(selectors['title'] ?? '.coll__title')
          ?.text
          .trim();
      final count = item
          .querySelector(selectors['count'] ?? '.coll__count')
          ?.text
          .trim();
      final itemCount = int.tryParse(count ?? '0') ?? 0;

      if (title != null && link != null) {
        collections.add(
          Collection(
            id: _extractIdFromUrl(link),
            title: title,
            description: null,
            imageUrl: _normalizeUrl(img), // Нормализуем URL изображения
            itemCount: itemCount,
            url: _normalizeUrl(link),
          ),
        );
      }
    }

    return collections;
  }
}

extension AnimeDtoExtension on AnimeDto {
  Anime toDomain() {
    return Anime(
      id: id,
      title: title,
      slug: slug,
      url: url,
      poster: poster,
      rating: rating,
      year: year,
      genres: genres,
      description: description,
      status: status,
      type: type,
      episodesCount: episodesCount,
    );
  }
}

PageResult<T> _deserializePageResult<T>(
  String json,
  T Function(dynamic) fromJson,
) {
  final map = jsonDecode(json) as Map<String, dynamic>;
  final itemsList = map['items'] as List<dynamic>;
  final items = itemsList.map((item) => fromJson(item)).toList();

  return PageResult<T>(
    items: items,
    page: map['page'] ?? 1,
    nextPageUrl: map['nextPageUrl'],
    prevPageUrl: map['prevPageUrl'],
  );
}
