import 'package:a_watch/features/anime/domain/entities/anime.dart';

/// Data model for top100 page
class Top100PageData {
  final List<Anime> items;
  final Top100Filter currentFilter;

  const Top100PageData({
    required this.items,
    required this.currentFilter,
  });

  factory Top100PageData.empty() => const Top100PageData(
        items: [],
        currentFilter: Top100Filter.all,
      );

  Top100PageData copyWith({
    List<Anime>? items,
    Top100Filter? currentFilter,
  }) {
    return Top100PageData(
      items: items ?? this.items,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  factory Top100PageData.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
        ?.map((item) => Anime.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    final filterId = json['currentFilter'] as int? ?? Top100Filter.all.id;
    final currentFilter = Top100Filter.fromId(filterId);

    return Top100PageData(
      items: items,
      currentFilter: currentFilter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((anime) => anime.toJson()).toList(),
      'currentFilter': currentFilter.id,
    };
  }
}

/// Filter options for top100 page
enum Top100Filter {
  all('Все аниме', 4),
  series('Сериалы', 5),
  movies('Фильмы', 6);

  const Top100Filter(this.displayName, this.id);

  final String displayName;
  final int id;

  static Top100Filter fromId(int id) {
    return Top100Filter.values.firstWhere(
      (filter) => filter.id == id,
      orElse: () => Top100Filter.all,
    );
  }
}
