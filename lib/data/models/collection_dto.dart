import 'dart:convert';

class CollectionDto {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final int itemCount;
  final String url;

  CollectionDto({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.itemCount,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'itemCount': itemCount,
      'url': url,
    };
  }

  factory CollectionDto.fromMap(Map<String, dynamic> map) {
    return CollectionDto(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      itemCount: map['itemCount'] ?? 0,
      url: map['url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CollectionDto.fromJson(String source) => CollectionDto.fromMap(json.decode(source));
}
