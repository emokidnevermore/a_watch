import 'package:html/parser.dart' as parser;
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/iparser.dart';
import 'package:a_watch/domain/entities/collection.dart';

class CollectionsParser implements IParser<List<Collection>> {
  @override
  Future<List<Collection>> parse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
  }) async {
    final document = parser.parse(htmlContent);
    final sections = document.querySelectorAll('.section');
    
    // Ищем секцию с подборками
    final collectionsSection = sections.firstWhere(
      (section) => section.querySelector('h2, h3, .section__title')?.text.trim().contains('Подборки') == true,
      orElse: () => sections[2], // Третья секция (по анализу она подборки)
    );

    // Используем селекторы из конфигурации
    final containerSelector = selectors['container'] ?? '.section__content.grid-items';
    final container = collectionsSection.querySelector(containerSelector);
    if (container == null) return [];

    final itemSelector = selectors['item'] ?? '.coll.grid-item.hover';
    final collItems = container.querySelectorAll(itemSelector);
    final collections = <Collection>[];

    for (final item in collItems) {
      // Используем селекторы из конфигурации
      final link = item.attributes[selectors['link'] ?? 'href'];
      final img = item.querySelector(selectors['image'] ?? 'img[src]')?.attributes['src'];
      final title = item.querySelector(selectors['title'] ?? '.coll__title')?.text.trim();
      final count = item.querySelector(selectors['count'] ?? '.coll__count')?.text.trim();
      final itemCount = int.tryParse(count ?? '0') ?? 0;

      if (title != null && link != null) {
        collections.add(Collection(
          id: _extractIdFromUrl(link),
          title: title,
          description: null,
          imageUrl: _normalizeUrl(img, config.baseUrl),
          itemCount: itemCount,
          url: _normalizeUrl(link, config.baseUrl),
        ));
      }
    }

    return collections;
  }

  @override
  bool canParse(String html) {
    // Проверяем, содержит ли HTML элементы, характерные для коллекций
    return html.contains('section__content grid-items') || 
           html.contains('coll grid-item hover') || 
           html.contains('Подборки');
  }

  @override
  String getDataType() => 'collections';

  // Helper methods
  String _extractIdFromUrl(String? url) {
    if (url == null) return '';
    final match = RegExp(r'/(\d+)-').firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _normalizeUrl(String? url, String baseUrl) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }
}
