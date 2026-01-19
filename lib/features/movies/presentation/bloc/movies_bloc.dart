import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/features/movies/domain/repositories/movies_repository.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_event.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_state.dart';
import 'package:a_watch/core/logger/logger.dart';

class MoviesBloc extends BaseBloc<MoviesEvent, MoviesState> {
  final MoviesRepository _repository;

  MoviesBloc(this._repository, ILogger logger)
      : super(logger, MoviesInitial()) {
    on<MoviesLoad>(_onMoviesLoad);
    on<MoviesLoadMore>(_onMoviesLoadMore);
    on<MoviesApplyFilters>(_onMoviesApplyFilters);
    on<MoviesResetFilters>(_onMoviesResetFilters);
    on<MoviesChangePage>(_onMoviesChangePage);
    on<MoviesRefresh>(_onMoviesRefresh);
  }

  Future<void> _onMoviesLoad(
    MoviesLoad event,
    Emitter<MoviesState> emit,
  ) async {
    logEvent(event);
    logger.logDebug('BLOC: MoviesLoad event with url=${event.url}, filters=${event.filters}, isFiltering=${event.isFiltering}, useCache=${event.useCache}', 'MoviesBloc');

    // If filtering, emit MoviesFiltering with current data instead of MoviesLoading
    if (event.isFiltering) {
      final currentState = state;
      if (currentState is MoviesLoaded) {
        emit(MoviesFiltering(currentState.data));
      } else {
        emit(MoviesLoading()); // Fallback if no current data
      }
    } else {
      emit(MoviesLoading());
    }

    try {
      final data = await _repository.getMoviesPage(
        url: event.url,
        filters: event.filters,
        useCache: event.useCache,
      );
      emit(MoviesLoaded(data));
    } catch (e) {
      emit(MoviesError('Failed to load movies: ${e.toString()}'));
    }
  }

  Future<void> _onMoviesLoadMore(
    MoviesLoadMore event,
    Emitter<MoviesState> emit,
  ) async {
    if (event.nextPageUrl == null || event.nextPageUrl!.isEmpty) {
      return;
    }

    final currentState = state;
    if (currentState is MoviesLoaded) {
      emit(MoviesLoadingMore(currentState.data));
    }

    try {
      final newData = await _repository.getMoviesPage(
        url: event.nextPageUrl!,
        filters: event.filters,
        useCache: false, // Для пагинации не используем кеш
      );

      if (currentState is MoviesLoaded) {
        // Объединяем данные
        final mergedItems = [...currentState.data.items, ...newData.items];
        final mergedData = SeriesPageData(
          carousel: currentState.data.carousel, // Карусель остается из первой страницы
          items: mergedItems,
          currentPage: newData.currentPage,
          totalPages: newData.totalPages,
          availableFilters: newData.availableFilters,
          nextPageUrl: newData.nextPageUrl,
          prevPageUrl: newData.prevPageUrl,
        );
        emit(MoviesLoaded(mergedData));
      }
    } catch (e) {
      emit(MoviesError('Failed to load more movies: ${e.toString()}'));
    }
  }

  Future<void> _onMoviesApplyFilters(
    MoviesApplyFilters event,
    Emitter<MoviesState> emit,
  ) async {
    logEvent(event);
    // Фильтры применяются при следующей загрузке
    // Можно добавить логику для применения фильтров к текущему состоянию
  }

  Future<void> _onMoviesResetFilters(
    MoviesResetFilters event,
    Emitter<MoviesState> emit,
  ) async {
    logEvent(event);
    // Сброс фильтров - можно добавить логику
  }

  Future<void> _onMoviesChangePage(
    MoviesChangePage event,
    Emitter<MoviesState> emit,
  ) async {
    logEvent(event);
    emit(MoviesLoading());

    // Construct URL for the page
    final baseUrl = 'https://yummyanime.tv/movies';
    final url = event.page == 1 ? baseUrl : '$baseUrl/page/${event.page}';

    try {
      final data = await _repository.getMoviesPage(
        url: url,
        filters: event.filters,
        useCache: true,
      );
      emit(MoviesLoaded(data));
    } catch (e) {
      emit(MoviesError('Failed to change page: ${e.toString()}'));
    }
  }

  Future<void> _onMoviesRefresh(
    MoviesRefresh event,
    Emitter<MoviesState> emit,
  ) async {
    logEvent(event);
    emit(MoviesLoading());

    try {
      final data = await _repository.getMoviesPage(
        url: event.url,
        filters: event.filters,
        useCache: false, // Принудительное обновление
      );
      emit(MoviesLoaded(data));
    } catch (e) {
      emit(MoviesError('Failed to refresh movies: ${e.toString()}'));
    }
  }
}
