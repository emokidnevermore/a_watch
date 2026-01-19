import 'dart:convert';

class PageResultDto<T> {
  final List<T> items;
  final int page;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PageResultDto({
    required this.items,
    required this.page,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items,
      'page': page,
      'nextPageUrl': nextPageUrl,
      'prevPageUrl': prevPageUrl,
    };
  }

  factory PageResultDto.fromMap(Map<String, dynamic> map, T Function(dynamic) fromMap) {
    final itemsList = map['items'] as List<dynamic>;
    final items = itemsList.map((item) => fromMap(item)).toList();

    return PageResultDto<T>(
      items: items,
      page: map['page'] ?? 1,
      nextPageUrl: map['nextPageUrl'],
      prevPageUrl: map['prevPageUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PageResultDto.fromJson(String source, T Function(dynamic) fromMap) {
    final map = json.decode(source) as Map<String, dynamic>;
    return PageResultDto.fromMap(map, fromMap);
  }
}
