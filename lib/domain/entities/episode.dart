import 'package:equatable/equatable.dart';

class Episode extends Equatable {
  final String id;
  final String title;
  final int episodeNumber;
  final String url;

  const Episode({
    required this.id,
    required this.title,
    required this.episodeNumber,
    required this.url,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        episodeNumber,
        url,
      ];

  Episode copyWith({
    String? id,
    String? title,
    int? episodeNumber,
    String? url,
  }) {
    return Episode(
      id: id ?? this.id,
      title: title ?? this.title,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      url: url ?? this.url,
    );
  }
}
