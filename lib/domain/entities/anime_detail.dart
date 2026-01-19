import 'package:equatable/equatable.dart';

import 'anime.dart';

class AnimeDetail extends Equatable {
  final String title;
  final String originalTitle;
  final String url;
  final String posterUrl;
  final String? coverUrl;
  final int year;
  final int? duration;
  final String? director;
  final double rating;
  final int ratingCount;
  final List<String> genres;
  final int views;
  final String status;
  final String source;
  final String studio;
  final List<String> translations;
  final String description;
  final List<Anime> franchise;
  final DateTime? nextEpisodeDate;
  final List<Anime> related;
  final int? episodeCount;
  final String? ageRating;

  const AnimeDetail({
    required this.title,
    required this.originalTitle,
    required this.url,
    required this.posterUrl,
    this.coverUrl,
    required this.year,
    this.duration,
    this.director,
    required this.rating,
    required this.ratingCount,
    required this.genres,
    required this.views,
    required this.status,
    required this.source,
    required this.studio,
    required this.translations,
    required this.description,
    required this.franchise,
    this.nextEpisodeDate,
    required this.related,
    this.episodeCount,
    this.ageRating,
  });

  @override
  List<Object?> get props => [
        title,
        originalTitle,
        url,
        posterUrl,
        coverUrl,
        year,
        duration,
        director,
        rating,
        ratingCount,
        genres,
        views,
        status,
        source,
        studio,
        translations,
        description,
        franchise,
        nextEpisodeDate,
        related,
        episodeCount,
        ageRating,
      ];

  AnimeDetail copyWith({
    String? title,
    String? originalTitle,
    String? url,
    String? posterUrl,
    String? coverUrl,
    int? year,
    int? duration,
    String? director,
    double? rating,
    int? ratingCount,
    List<String>? genres,
    int? views,
    String? status,
    String? source,
    String? studio,
    List<String>? translations,
    String? description,
    List<Anime>? franchise,
    DateTime? nextEpisodeDate,
    List<Anime>? related,
    int? episodeCount,
    String? ageRating,
  }) {
    return AnimeDetail(
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      url: url ?? this.url,
      posterUrl: posterUrl ?? this.posterUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      director: director ?? this.director,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      genres: genres ?? this.genres,
      views: views ?? this.views,
      status: status ?? this.status,
      source: source ?? this.source,
      studio: studio ?? this.studio,
      translations: translations ?? this.translations,
      description: description ?? this.description,
      franchise: franchise ?? this.franchise,
      nextEpisodeDate: nextEpisodeDate ?? this.nextEpisodeDate,
      related: related ?? this.related,
      episodeCount: episodeCount ?? this.episodeCount,
      ageRating: ageRating ?? this.ageRating,
    );
  }
}
