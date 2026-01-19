import 'package:equatable/equatable.dart';

abstract class AnimeDetailEvent extends Equatable {
  const AnimeDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadAnimeDetail extends AnimeDetailEvent {
  final String animeUrl;

  const LoadAnimeDetail(this.animeUrl);

  @override
  List<Object> get props => [animeUrl];
}
