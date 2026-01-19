import 'package:equatable/equatable.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_filters.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object> get props => [];
}

class CatalogLoad extends CatalogEvent {
  final String url;
  final CatalogFilters? filters;
  final int page;
  final bool isFiltering;

  const CatalogLoad({
    required this.url,
    this.filters,
    this.page = 1,
    this.isFiltering = false,
  });

  @override
  List<Object> get props => [url, filters ?? CatalogFilters.empty(), page, isFiltering];
}

class CatalogLoadMore extends CatalogEvent {
  final String? nextPageUrl;
  final CatalogFilters? filters;

  const CatalogLoadMore(this.nextPageUrl, {this.filters});

  @override
  List<Object> get props => [nextPageUrl ?? '', filters ?? CatalogFilters.empty()];
}

class CatalogApplyFilters extends CatalogEvent {
  final CatalogFilters filters;

  const CatalogApplyFilters(this.filters);

  @override
  List<Object> get props => [filters];
}

class CatalogResetFilters extends CatalogEvent {
  const CatalogResetFilters();
}

class CatalogChangePage extends CatalogEvent {
  final int page;
  final CatalogFilters? filters;

  const CatalogChangePage(this.page, {this.filters});

  @override
  List<Object> get props => [page, filters ?? CatalogFilters.empty()];
}

class CatalogRefresh extends CatalogEvent {
  final String url;
  final CatalogFilters? filters;

  const CatalogRefresh(this.url, {this.filters});

  @override
  List<Object> get props => [url, filters ?? CatalogFilters.empty()];
}
