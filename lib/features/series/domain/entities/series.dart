import 'package:equatable/equatable.dart';

class Series extends Equatable {
  final String id;
  final String title;
  final String poster;
  final String year;
  final List<String> genres;
  final String url;
  // other series fields can be added here

  const Series({
    required this.id,
    required this.title,
    required this.poster,
    required this.year,
    required this.genres,
    required this.url,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        poster,
        year,
        genres,
        url,
      ];

  Series copyWith({
    String? id,
    String? title,
    String? poster,
    String? year,
    List<String>? genres,
    String? url,
  }) {
    return Series(
      id: id ?? this.id,
      title: title ?? this.title,
      poster: poster ?? this.poster,
      year: year ?? this.year,
      genres: genres ?? this.genres,
      url: url ?? this.url,
    );
  }

  /// Создание из JSON
  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      year: json['year'] as String? ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster': poster,
      'year': year,
      'genres': genres,
      'url': url,
    };
  }
}
