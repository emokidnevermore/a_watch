import 'package:html/parser.dart' as parser;
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/iparser.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';

/// Parser for top100 page
class Top100PageParser implements IParser<Top100PageData> {
  final ILogger? _logger;

  Top100PageParser({ILogger? logger}) : _logger = logger;

  @override
  Future<Top100PageData> parse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
  }) async {
    final document = parser.parse(htmlContent);
    final errors = <String>[];

    try {
      // Parse current filter from active button
      final currentFilter = _parseCurrentFilter(document);

      // Parse list of anime
      final items = _parseAnimeList(document, config);

      return Top100PageData(
        items: items,
        currentFilter: currentFilter,
      );
    } catch (e) {
      errors.add('Error parsing top100 page: $e');
      return Top100PageData.empty();
    }
  }

  /// Parsing AJAX response for filtered content
  Future<Top100PageData> parseAjaxResponse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
    required String baseUrl,
  }) async {
    final document = parser.parse(htmlContent);
    final errors = <String>[];

    try {
      // For AJAX response, parse only anime list
      final items = _parseAnimeListAjax(document, config);

      // Default to all filter since AJAX doesn't provide filter info
      const currentFilter = Top100Filter.all;

      return Top100PageData(
        items: items,
        currentFilter: currentFilter,
      );
    } catch (e) {
      errors.add('Error parsing AJAX top100 page: $e');
      return Top100PageData.empty();
    }
  }

  @override
  bool canParse(String html) {
    // Check for top100 specific elements
    return html.contains('top_100-y18') ||
           html.contains('ТОП-100 лучших фильмов') ||
           html.contains('data-custommmm-id');
  }

  @override
  String getDataType() => 'top100_page';

  /// Parse current active filter from the page
  Top100Filter _parseCurrentFilter(document) {
    final activeFilter = document.querySelector('.side-block__list .is-active');
    if (activeFilter != null) {
      final dataId = activeFilter.attributes['data-custommmm-id'];
      if (dataId != null) {
        final id = int.tryParse(dataId);
        if (id != null) {
          return Top100Filter.fromId(id);
        }
      }
    }
    return Top100Filter.all;
  }

  /// Parse list of anime from top100 page
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

  /// Parse list of anime for AJAX response
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

  /// Parse single anime item
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

    // Extract episode count from status
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
      type: 'top100',
      episodesCount: episodesCount,
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
}
