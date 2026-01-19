import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SelectorsConfig {
  final String version;
  final String baseUrl;
  final Map<String, Map<String, String>> selectors;

  SelectorsConfig({
    required this.version,
    required this.baseUrl,
    required this.selectors,
  });

  factory SelectorsConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> selectorsJson = json['selectors'] ?? {};
    final Map<String, Map<String, String>> selectorsMap = {};

    selectorsJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        selectorsMap[key] = value.map((k, v) => MapEntry(k, v.toString()));
      }
    });

    return SelectorsConfig(
      version: json['version'] ?? '1.0.0',
      baseUrl: json['baseUrl'] ?? '',
      selectors: selectorsMap,
    );
  }

  Map<String, String>? getSelectors(String type) {
    return selectors[type];
  }

  String? getSelector(String type, String key) {
    final typeSelectors = selectors[type];
    return typeSelectors?[key];
  }

  static Future<SelectorsConfig> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString);
    return SelectorsConfig.fromJson(json);
  }

  static SelectorsConfig loadDefault() {
    return SelectorsConfig(
      version: '1.0.1',
      baseUrl: 'https://yummyanime.tv',
      selectors: {
        'list': {
          'container': '.section__items',
          'item': '.movie-item',
          'link': '.movie-item__link[href]',
          'poster': '.movie-item__img img[src]',
          'title': '.movie-item__title',
          'rating': '.movie-item__rating',
          'year': '.movie-item__meta span',
          'status': '.movie-item__label',
          'section_title': '.section__title',
        },
        'detail': {
          'container': '.fullstory',
          'title': '.inner-page__title h2, .fullstory__title',
          'poster': '.fullstory__poster img[src]',
          'description': '.fullstory__description, .inner-page__desc p',
          'genres': '.fullstory__info a[href*="/genre/"]',
        },

        'pagination': {
          'container': '.pagination, #pagination, .navigation',
          'links': '.pagination a[href], .navigation a[href]',
        },
        'collections': {
          'section_title': '.section__title',
          'container': '.section__content.grid-items',
          'item': '.coll.grid-item.hover',
          'link': 'href',
          'image': 'img[src]',
          'title': '.coll__title',
          'count': '.coll__count',
        },
        'series_page': {
          'carousel': '#owl-top .movie-item',
          'filters': '#filter-wrap',
          'list': '#dle-content .movie-item',
          'pagination': '.pagination',
        },
        'movies_page': {
          'carousel': '#owl-top .movie-item',
          'filters': '#filter-wrap',
          'list': '#dle-content .movie-item',
          'pagination': '.pagination',
        },
        'catalog_page': {
          'carousel': '#owl-top .movie-item',
          'filters': '#filter-wrap',
          'list': '#dle-content .movie-item',
          'pagination': '.pagination',
        },
      },
    );
  }
}
