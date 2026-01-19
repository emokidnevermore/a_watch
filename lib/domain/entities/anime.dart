import 'package:equatable/equatable.dart';

class Anime extends Equatable {
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

  const Anime({
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

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        url,
        poster,
        rating,
        year,
        genres,
        description,
        status,
        type,
        episodesCount,
      ];

  Anime copyWith({
    String? id,
    String? title,
    String? slug,
    String? url,
    String? poster,
    String? rating,
    String? year,
    List<String>? genres,
    String? description,
    String? status,
    String? type,
    String? episodesCount,
  }) {
    return Anime(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      url: url ?? this.url,
      poster: poster ?? this.poster,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      genres: genres ?? this.genres,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      episodesCount: episodesCount ?? this.episodesCount,
    );
  }

  /// Создание из JSON
  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      url: json['url'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      rating: json['rating'] as String?,
      year: json['year'] as String?,
      genres: List<String>.from(json['genres'] ?? []),
      description: json['description'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      episodesCount: json['episodesCount'] as String?,
    );
  }
}
