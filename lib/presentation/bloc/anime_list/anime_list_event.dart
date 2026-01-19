import 'package:equatable/equatable.dart';

abstract class AnimeListEvent extends Equatable {
  const AnimeListEvent();

  @override
  List<Object> get props => [];
}

class AnimeListLoad extends AnimeListEvent {
  final String url;
  final bool useCache;
  final bool forceRefresh;

  const AnimeListLoad({
    required this.url,
    this.useCache = true,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [url, useCache, forceRefresh];
}

class AnimeListLoadMore extends AnimeListEvent {
  final String? nextPageUrl;

  const AnimeListLoadMore(this.nextPageUrl);

  @override
  List<Object> get props => [nextPageUrl ?? ''];
}

class AnimeListRefresh extends AnimeListEvent {
  final String url;

  const AnimeListRefresh(this.url);

  @override
  List<Object> get props => [url];
}

class AnimeListSearch extends AnimeListEvent {
  final String query;

  const AnimeListSearch(this.query);

  @override
  List<Object> get props => [query];
}
