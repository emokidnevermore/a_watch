import 'package:equatable/equatable.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';

abstract class SeriesState extends Equatable {
  const SeriesState();

  @override
  List<Object> get props => [];
}

class SeriesInitial extends SeriesState {}

class SeriesLoading extends SeriesState {}

class SeriesFiltering extends SeriesState {
  final SeriesPageData currentData;

  const SeriesFiltering(this.currentData);

  @override
  List<Object> get props => [currentData];
}

class SeriesLoaded extends SeriesState {
  final SeriesPageData data;
  final bool isLoadingMore;

  const SeriesLoaded(this.data, {this.isLoadingMore = false});

  @override
  List<Object> get props => [data, isLoadingMore];
}

class SeriesError extends SeriesState {
  final String message;

  const SeriesError(this.message);

  @override
  List<Object> get props => [message];
}

class SeriesLoadingMore extends SeriesState {
  final SeriesPageData currentData;

  const SeriesLoadingMore(this.currentData);

  @override
  List<Object> get props => [currentData];
}
