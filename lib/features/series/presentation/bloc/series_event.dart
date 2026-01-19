import 'package:equatable/equatable.dart';
import 'package:a_watch/domain/entities/series_filters.dart';

abstract class SeriesEvent extends Equatable {
  const SeriesEvent();

  @override
  List<Object> get props => [];
}

class SeriesLoad extends SeriesEvent {
  final String url;
  final SeriesFilters? filters;
  final int page;
  final bool isFiltering;

  const SeriesLoad({
    required this.url,
    this.filters,
    this.page = 1,
    this.isFiltering = false,
  });

  @override
  List<Object> get props => [url, filters ?? SeriesFilters.empty(), page, isFiltering];
}

class SeriesLoadMore extends SeriesEvent {
  final String? nextPageUrl;
  final SeriesFilters? filters;

  const SeriesLoadMore(this.nextPageUrl, {this.filters});

  @override
  List<Object> get props => [nextPageUrl ?? '', filters ?? SeriesFilters.empty()];
}

class SeriesApplyFilters extends SeriesEvent {
  final SeriesFilters filters;

  const SeriesApplyFilters(this.filters);

  @override
  List<Object> get props => [filters];
}

class SeriesResetFilters extends SeriesEvent {
  const SeriesResetFilters();
}

class SeriesChangePage extends SeriesEvent {
  final int page;
  final SeriesFilters? filters;

  const SeriesChangePage(this.page, {this.filters});

  @override
  List<Object> get props => [page, filters ?? SeriesFilters.empty()];
}

class SeriesRefresh extends SeriesEvent {
  final String url;
  final SeriesFilters? filters;

  const SeriesRefresh(this.url, {this.filters});

  @override
  List<Object> get props => [url, filters ?? SeriesFilters.empty()];
}
