import 'dart:convert';

class AnimeDto {
  final String id;
  final String title;
  final String slug;
  final String url;
  final String poster;
  final String? rating;
  final String? year;
  final List<String> genres;
  final String? description;
  final String? status; // ongoing, released
  final String? type; // serial, movie
  final String? episodesCount;

  AnimeDto({
    required this.id,
    required this.title,
    required this.slug,
    required this.url,
    required this.poster,
    this.rating,
    this.year,
    required this.genres,
    this.description,
    this.status,
    this.type,
    this.episodesCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'url': url,
      'poster': poster,
      'rating': rating,
      'year': year,
      'genres': genres,
      'description': description,
      'status': status,
      'type': type,
      'episodesCount': episodesCount,
    };
  }

  factory AnimeDto.fromMap(Map<String, dynamic> map) {
    return AnimeDto(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
      url: map['url'] ?? '',
      poster: map['poster'] ?? '',
      rating: map['rating'],
      year: map['year'],
      genres: List<String>.from(map['genres'] ?? []),
      description: map['description'],
      status: map['status'],
      type: map['type'],
      episodesCount: map['episodesCount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AnimeDto.fromJson(String source) => AnimeDto.fromMap(json.decode(source));
}
