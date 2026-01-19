import 'package:equatable/equatable.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class MoviesInitial extends MoviesState {}

/// Загрузка данных
class MoviesLoading extends MoviesState {}

/// Фильтрация данных (промежуточное состояние)
class MoviesFiltering extends MoviesState {
  final SeriesPageData currentData;

  const MoviesFiltering(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

/// Данные загружены успешно
class MoviesLoaded extends MoviesState {
  final SeriesPageData data;

  const MoviesLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Загрузка дополнительных данных (пагинация)
class MoviesLoadingMore extends MoviesState {
  final SeriesPageData currentData;

  const MoviesLoadingMore(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

/// Ошибка загрузки
class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
