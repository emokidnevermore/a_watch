import 'dart:developer';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

import '../../features/anime/domain/entities/anime.dart';
import '../../features/anime/domain/entities/anime_detail.dart';
import 'iparser.dart';
import '../../data/config/selectors_config.dart';

class AnimeDetailParser implements IParser<AnimeDetail> {
  @override
  Future<AnimeDetail> parse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
  }) async {
    final url = selectors['url'] ?? '';
    final document = html.parse(htmlContent);
    
    // Basic info
    final title = _extractTitle(document);
    final originalTitle = _extractOriginalTitle(document);
    final posterUrl = _extractPosterUrl(document);
    final year = _extractYear(document);
    final duration = _extractDuration(document);
    final director = _extractDirector(document);
    final rating = _extractRating(document);
    final ratingCount = _extractRatingCount(document);
    final genres = _extractGenres(document);
    final views = _extractViews(document);
    final status = _extractStatus(document);
    final source = _extractSource(document);
    final studio = _extractStudio(document);
    final translations = _extractTranslations(document);
    final description = _extractDescription(document);
    final episodeCount = _extractEpisodeCount(document);
    final ageRating = _extractAgeRating(document);
    final nextEpisodeDate = _extractNextEpisodeDate(document);
    
    // Related content
    final franchise = _extractFranchise(document);
    final related = _extractRelated(document);

    return AnimeDetail(
      title: title,
      originalTitle: originalTitle,
      url: url,
      posterUrl: posterUrl,
      year: year,
      duration: duration,
      director: director,
      rating: rating,
      ratingCount: ratingCount,
      genres: genres,
      views: views,
      status: status,
      source: source,
      studio: studio,
      translations: translations,
      description: description,
      franchise: franchise,
      nextEpisodeDate: nextEpisodeDate,
      related: related,
      episodeCount: episodeCount,
      ageRating: ageRating,
    );
  }

  String _extractTitle(Document document) {
    try {
      final titleElement = document.querySelector('h1[itemprop="name"]');
      if (titleElement != null) {
        return titleElement.text.trim();
      }
      
      final titleMeta = document.querySelector('title');
      if (titleMeta != null) {
        final titleText = titleMeta.text;
        // Extract title from "Title - YummyAnime" format
        final parts = titleText.split(' - ');
        if (parts.isNotEmpty) {
          return parts[0].trim();
        }
      }
    } catch (e) {
      log('Error extracting title: $e');
    }
    return 'Unknown Title';
  }

  String _extractOriginalTitle(Document document) {
    try {
      final subtitle = document.querySelector('.inner-page__subtitle');
      if (subtitle != null) {
        return subtitle.text.trim();
      }
    } catch (e) {
      log('Error extracting original title: $e');
    }
    return '';
  }

  String _extractPosterUrl(Document document) {
    try {
      final posterElement = document.querySelector('.inner-page__img img');
      if (posterElement != null) {
        final src = posterElement.attributes['src'];
        if (src != null) {
          return _normalizeUrl(src);
        }
      }
    } catch (e) {
      log('Error extracting poster URL: $e');
    }
    return '';
  }

  int _extractYear(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Год выхода:')) {
          final yearElement = item.querySelector('a');
          if (yearElement != null) {
            final yearText = yearElement.text.trim();
            return int.parse(yearText);
          }
        }
      }
    } catch (e) {
      log('Error extracting year: $e');
    }
    return DateTime.now().year;
  }

  int? _extractDuration(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Время:')) {
          final durationText = item.text;
          final match = RegExp(r'(\d+)').firstMatch(durationText);
          if (match != null) {
            return int.parse(match.group(1)!);
          }
        }
      }
    } catch (e) {
      log('Error extracting duration: $e');
    }
    return null;
  }

  String? _extractDirector(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Режиссер:')) {
          final directorElement = item.querySelector('span[itemprop="director"]');
          if (directorElement != null) {
            return directorElement.text.trim();
          }
        }
      }
    } catch (e) {
      log('Error extracting director: $e');
    }
    return null;
  }

  double _extractRating(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Рейтинг аниме:')) {
          final ratingElement = item.querySelector('span[itemprop="ratingValue"]');
          if (ratingElement != null) {
            final ratingText = ratingElement.text.trim();
            return double.parse(ratingText);
          }
        }
      }
    } catch (e) {
      log('Error extracting rating: $e');
    }
    return 0.0;
  }

  int _extractRatingCount(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Рейтинг аниме:')) {
          final ratingCountElement = item.querySelector('span[itemprop="ratingCount"]');
          if (ratingCountElement != null) {
            final countText = ratingCountElement.text.trim();
            return int.parse(countText);
          }
        }
      }
    } catch (e) {
      log('Error extracting rating count: $e');
    }
    return 0;
  }

  List<String> _extractGenres(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Жанр:')) {
          final genreElements = item.querySelectorAll('a');
          return genreElements.map((el) => el.text.trim()).toList();
        }
      }
    } catch (e) {
      log('Error extracting genres: $e');
      return [];
    }
    return [];
  }

  int _extractViews(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Просмотров:')) {
          final viewsText = item.text;
          final match = RegExp(r'(\d[\d\s]*)').firstMatch(viewsText);
          if (match != null) {
            return int.parse(match.group(1)!.replaceAll(' ', ''));
          }
        }
      }
    } catch (e) {
      log('Error extracting views: $e');
    }
    return 0;
  }

  String _extractStatus(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Статус:')) {
          final statusElement = item.querySelector('.status');
          if (statusElement != null) {
            return statusElement.text.trim();
          }
        }
      }
    } catch (e) {
      log('Error extracting status: $e');
    }
    return 'Unknown';
  }

  String _extractSource(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Первоисточник:')) {
          final sourceText = item.text;
          final parts = sourceText.split(':');
          if (parts.length > 1) {
            return parts[1].trim();
          }
        }
      }
    } catch (e) {
      log('Error extracting source: $e');
    }
    return 'Unknown';
  }

  String _extractStudio(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Студия:')) {
          final studioElement = item.querySelector('a');
          if (studioElement != null) {
            return studioElement.text.trim();
          }
        }
      }
    } catch (e) {
      log('Error extracting studio: $e');
    }
    return 'Unknown';
  }

  List<String> _extractTranslations(Document document) {
    try {
      final listItems = document.querySelectorAll('.inner-page__list li');
      for (final item in listItems) {
        if (item.text.contains('Озвучка от:')) {
          final translationElements = item.querySelectorAll('a');
          return translationElements.map((el) => el.text.trim()).toList();
        }
      }
    } catch (e) {
      log('Error extracting translations: $e');
      return [];
    }
    return [];
  }

  String _extractDescription(Document document) {
    try {
      final descriptionElement = document.querySelector('.inner-page__desc .text');
      if (descriptionElement != null) {
        return descriptionElement.text.trim();
      }
    } catch (e) {
      log('Error extracting description: $e');
    }
    return '';
  }

  int? _extractEpisodeCount(Document document) {
    try {
      final episodeElement = document.querySelector('.movie-item__label');
      if (episodeElement != null) {
        final episodeText = episodeElement.text.trim();
        final match = RegExp(r'(\d+)').firstMatch(episodeText);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }
    } catch (e) {
      log('Error extracting episode count: $e');
    }
    return null;
  }

  String? _extractAgeRating(Document document) {
    try {
      final ageElement = document.querySelector('.movie-item__age');
      if (ageElement != null) {
        return ageElement.text.trim();
      }
    } catch (e) {
      log('Error extracting age rating: $e');
    }
    return null;
  }

  DateTime? _extractNextEpisodeDate(Document document) {
    try {
      final countdownElement = document.querySelector('.countdown');
      if (countdownElement != null) {
        final dateAttr = countdownElement.attributes['data-date'];
        if (dateAttr != null) {
          return DateTime.parse(dateAttr);
        }
      }
    } catch (e) {
      log('Error extracting next episode date: $e');
    }
    return null;
  }

  List<Anime> _extractFranchise(Document document) {
    try {
      final franchiseItems = document.querySelectorAll('#owl-franchize .movie-item');
      return franchiseItems.map((item) => _parseAnimeFromItem(item)).toList();
    } catch (e) {
      log('Error extracting franchise: $e');
      return [];
    }
  }

  List<Anime> _extractRelated(Document document) {
    try {
      final relatedItems = document.querySelectorAll('#owl-rels .movie-item');
      return relatedItems.map((item) => _parseAnimeFromItem(item)).toList();
    } catch (e) {
      log('Error extracting related: $e');
      return [];
    }
  }

  Anime _parseAnimeFromItem(Element item) {
    try {
      final link = item.querySelector('a');
      final titleElement = item.querySelector('.movie-item__title');
      final posterElement = item.querySelector('img');
      final yearElement = item.querySelector('.movie-item__label');

      final title = titleElement?.text.trim() ?? 'Unknown';
      final url = link?.attributes['href'] ?? '';
      final poster = _normalizeUrl(posterElement?.attributes['src'] ?? '');
      final year = yearElement?.text.trim() ?? '';

      // Generate slug from title
      final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(' ', '-');

      return Anime(
        id: url.split('/').last.split('.').first,
        title: title,
        slug: slug,
        url: _normalizeUrl(url),
        poster: poster,
        year: year,
        genres: [],
      );
    } catch (e) {
      log('Error parsing anime item: $e');
      return Anime(
        id: '',
        title: 'Unknown',
        slug: '',
        url: '',
        poster: '',
        genres: [],
      );
    }
  }

  String _normalizeUrl(String url) {
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('/')) {
      return 'https://yummyanime.tv$url';
    }
    return url;
  }

  @override
  bool canParse(String html) {
    // Check if this HTML contains anime detail page elements
    return html.contains('inner-page__main') && 
           html.contains('inner-page__title') &&
           html.contains('inner-page__list');
  }

  @override
  String getDataType() {
    return 'anime_detail';
  }
}
