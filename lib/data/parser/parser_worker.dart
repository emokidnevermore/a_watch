import 'package:html/parser.dart' as parser;

class ParseResult {
  final List<Map<String, dynamic>> items;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final List<String> errors;

  ParseResult({
    required this.items,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.errors,
  });
}

class ParserWorker {
  static ParseResult parseList(String html, Map<String, String> selectors) {
    final document = parser.parse(html);
    final errors = <String>[];

    // Ищем все секции с аниме
    final sections = document.querySelectorAll('.section');
    final result = <Map<String, dynamic>>[];

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

      // Ищем контейнер с элементами
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
            result.add({
              'link': link,
              'poster': poster,
              'title': title,
              'rating': rating,
              'year': year,
              'status': status,
              'type': sectionType, // Добавляем тип из секции
            });
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
            nextPageUrl = href;
          } else if (text.contains('«') || text.contains('Prev') || text.contains('<')) {
            prevPageUrl = href;
          }
        }
      }
    }

    return ParseResult(
      items: result,
      nextPageUrl: nextPageUrl,
      prevPageUrl: prevPageUrl,
      errors: errors,
    );
  }

  static ParseResult parseDetail(String html, Map<String, String> selectors) {
    final document = parser.parse(html);
    final errors = <String>[];

    final containerSelector = selectors['container'] ?? '.fullstory';
    final container = document.querySelector(containerSelector);

    if (container == null) {
      errors.add('Container not found: $containerSelector');
      return ParseResult(items: [], errors: errors);
    }

    final titleSelector = selectors['title'] ?? '.inner-page__title h2, .fullstory__title';
    final posterSelector = selectors['poster'] ?? '.fullstory__poster img[src]';
    final descriptionSelector = selectors['description'] ?? '.fullstory__description, .inner-page__desc p';
    final genresSelector = selectors['genres'] ?? '.fullstory__info a[href*="/genre/"]';

    final titleElement = container.querySelector(titleSelector);
    final posterElement = container.querySelector(posterSelector);
    final descriptionElement = container.querySelector(descriptionSelector);
    final genresElements = container.querySelectorAll(genresSelector);

    final title = titleElement?.text.trim();
    final poster = posterElement?.attributes['src'];
    final description = descriptionElement?.text.trim();
    final genres = genresElements.map((e) => e.text.trim()).toList();

    final result = [
      {
        'title': title,
        'poster': poster,
        'description': description,
        'genres': genres,
      }
    ];

    return ParseResult(items: result, errors: errors);
  }
}
