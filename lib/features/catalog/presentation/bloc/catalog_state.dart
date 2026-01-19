import 'package:equatable/equatable.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogFiltering extends CatalogState {
  final CatalogPageData currentData;

  const CatalogFiltering(this.currentData);

  @override
  List<Object> get props => [currentData];
}

class CatalogLoaded extends CatalogState {
  final CatalogPageData data;
  final bool isLoadingMore;

  const CatalogLoaded(this.data, {this.isLoadingMore = false});

  @override
  List<Object> get props => [data, isLoadingMore];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object> get props => [message];
}

class CatalogLoadingMore extends CatalogState {
  final CatalogPageData currentData;

  const CatalogLoadingMore(this.currentData);

  @override
  List<Object> get props => [currentData];
}
