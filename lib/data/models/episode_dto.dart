import 'dart:convert';

class EpisodeDto {
  final String id;
  final String title;
  final int episodeNumber;
  final String url;

  EpisodeDto({
    required this.id,
    required this.title,
    required this.episodeNumber,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'episodeNumber': episodeNumber,
      'url': url,
    };
  }

  factory EpisodeDto.fromMap(Map<String, dynamic> map) {
    return EpisodeDto(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      episodeNumber: map['episodeNumber'] ?? 0,
      url: map['url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory EpisodeDto.fromJson(String source) => EpisodeDto.fromMap(json.decode(source));
}
