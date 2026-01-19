import 'package:html/parser.dart' as parser;
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/iparser.dart';
import 'package:a_watch/data/models/anime_dto.dart';
import 'package:a_watch/data/models/page_result_dto.dart';

class AnimeListParser implements IParser<PageResultDto<AnimeDto>> {
  @override
  Future<PageResultDto<AnimeDto>> parse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
  }) async {
    final document = parser.parse(htmlContent);
    final errors = <String>[];

    // Ищем все секции с аниме
    final sections = document.querySelectorAll('.section');
    final result = <AnimeDto>[];

    for (final section in sections) {
      // Пропускаем секции без заголовка или с заголовком "Подборки"
      final header = section.querySelector('h2, h3, .section__title')?.text.trim();
      if (header == null || header.contains('Подборки')) {
        continue;
      }

      // Определяем тип секции по заголовку
      final sectionType = header.contains('Сериалы') 
          ? 'serial' 
          : header.contains('Фильмы') ? 'movie' : 'unknown';

      // Используем селекторы из конфигурации
      final containerSelector = selectors['container'] ?? '.section__items';
      final container = section.querySelector(containerSelector);
      
      if (container == null) {
        errors.add('Container not found in section: $containerSelector');
        continue;
      }

      final itemSelector = selectors['item'] ?? '.movie-item';
      final items = container.querySelectorAll(itemSelector);

      for (final item in items) {
        try {
          // Используем селекторы из конфигурации
          final linkSelector = selectors['link'] ?? '.movie-item__link[href]';
          final posterSelector = selectors['poster'] ?? '.movie-item__img img[src]';
          final titleSelector = selectors['title'] ?? '.movie-item__title';
          final ratingSelector = selectors['rating'] ?? '.movie-item__rating';
          final yearSelector = selectors['year'] ?? '.movie-item__meta span';
          final statusSelector = selectors['status'] ?? '.movie-item__label';

          final linkElement = item.querySelector(linkSelector);
          final posterElement = item.querySelector(posterSelector);
          final titleElement = item.querySelector(titleSelector);
          final ratingElement = item.querySelector(ratingSelector);
          final yearElement = item.querySelector(yearSelector);
          final statusElement = item.querySelector(statusSelector);

          final link = linkElement?.attributes['href'];
          final poster = posterElement?.attributes['src'];
          final title = titleElement?.text.trim();
          final rating = ratingElement?.text.trim();
          final year = yearElement?.text.trim();
          final status = statusElement?.text.trim();

          if (link != null && title != null) {
            // Извлекаем количество серий из статуса, если это сериал
            String? episodesCount;
            if (status != null && sectionType == 'serial') {
              final match = RegExp(r'(\d+)').firstMatch(status);
              if (match != null) {
                episodesCount = match.group(1);
              }
            }

            result.add(AnimeDto(
              id: _extractIdFromUrl(link),
              title: title,
              slug: _extractSlugFromUrl(link),
              url: _normalizeUrl(link, config.baseUrl),
              poster: _normalizeUrl(poster, config.baseUrl),
              rating: _extractRating(rating),
              year: year,
              genres: [],
              description: null,
              status: status,
              type: sectionType,
              episodesCount: episodesCount,
            ));
          }
        } catch (e) {
          errors.add('Error parsing item: $e');
        }
      }
    }

    // Parse pagination (берем из последней секции)
    final paginationSelector = selectors['pagination'] ?? '.pagination, #pagination, .navigation';
    final paginationContainer = document.querySelector(paginationSelector);

    String? nextPageUrl;
    String? prevPageUrl;

    if (paginationContainer != null) {
      final paginationLinks = paginationContainer.querySelectorAll('a[href]');
      for (final link in paginationLinks) {
        final href = link.attributes['href'];
        final text = link.text.trim();

        if (href != null) {
          if (text.contains('»') || text.contains('Next') || text.contains('>')) {
            nextPageUrl = _normalizeUrl(href, config.baseUrl);
          } else if (text.contains('«') || text.contains('Prev') || text.contains('<')) {
            prevPageUrl = _normalizeUrl(href, config.baseUrl);
          }
        }
      }
    }

    return PageResultDto<AnimeDto>(
      items: result,
      page: 1,
      nextPageUrl: nextPageUrl,
      prevPageUrl: prevPageUrl,
    );
  }

  @override
  bool canParse(String html) {
    // Проверяем, содержит ли HTML элементы, характерные для списка аниме
    return html.contains('section__items') || 
           html.contains('movie-item') || 
           html.contains('section__title');
  }

  @override
  String getDataType() => 'anime_list';

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
    // Извлекаем рейтинг из строки вроде "★ 7.3"
    final match = RegExp(r'([\d.]+)').firstMatch(ratingText);
    return match?.group(1);
  }
}
