import 'package:equatable/equatable.dart';
import 'package:a_watch/domain/entities/series_filters.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузка фильмов
class MoviesLoad extends MoviesEvent {
  final String url;
  final SeriesFilters? filters;
  final bool isFiltering;
  final bool useCache;

  const MoviesLoad({
    required this.url,
    this.filters,
    this.isFiltering = false,
    this.useCache = true,
  });

  @override
  List<Object?> get props => [url, filters, isFiltering, useCache];
}

/// Загрузка дополнительных фильмов (пагинация)
class MoviesLoadMore extends MoviesEvent {
  final String? nextPageUrl;
  final SeriesFilters? filters;

  const MoviesLoadMore({
    required this.nextPageUrl,
    this.filters,
  });

  @override
  List<Object?> get props => [nextPageUrl, filters];
}

/// Применение фильтров
class MoviesApplyFilters extends MoviesEvent {
  const MoviesApplyFilters();
}

/// Сброс фильтров
class MoviesResetFilters extends MoviesEvent {
  const MoviesResetFilters();
}

/// Изменение страницы
class MoviesChangePage extends MoviesEvent {
  final int page;
  final SeriesFilters? filters;

  const MoviesChangePage({
    required this.page,
    this.filters,
  });

  @override
  List<Object?> get props => [page, filters];
}

/// Обновление данных
class MoviesRefresh extends MoviesEvent {
  final String url;
  final SeriesFilters? filters;

  const MoviesRefresh({
    required this.url,
    this.filters,
  });

  @override
  List<Object?> get props => [url, filters];
}
