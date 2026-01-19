import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/features/series/domain/repositories/series_repository.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'package:a_watch/features/series/presentation/bloc/series_event.dart';
import 'package:a_watch/features/series/presentation/bloc/series_state.dart';
import 'package:a_watch/core/logger/logger.dart';

class SeriesBloc extends BaseBloc<SeriesEvent, SeriesState> {
  final SeriesRepository _repository;

  SeriesBloc(this._repository, ILogger logger)
      : super(logger, SeriesInitial()) {
    on<SeriesLoad>(_onSeriesLoad);
    on<SeriesLoadMore>(_onSeriesLoadMore);
    on<SeriesApplyFilters>(_onSeriesApplyFilters);
    on<SeriesResetFilters>(_onSeriesResetFilters);
    on<SeriesChangePage>(_onSeriesChangePage);
    on<SeriesRefresh>(_onSeriesRefresh);
  }

  Future<void> _onSeriesLoad(
    SeriesLoad event,
    Emitter<SeriesState> emit,
  ) async {
    logEvent(event);
    logger.logDebug('BLOC: SeriesLoad event with url=${event.url}, filters=${event.filters}, isFiltering=${event.isFiltering}', 'SeriesBloc');

    // If filtering, emit SeriesFiltering with current data instead of SeriesLoading
    if (event.isFiltering) {
      final currentState = state;
      if (currentState is SeriesLoaded) {
        emit(SeriesFiltering(currentState.data));
      } else {
        emit(SeriesLoading()); // Fallback if no current data
      }
    } else {
      emit(SeriesLoading());
    }

    try {
      final data = await _repository.getSeriesPage(
        url: event.url,
        filters: event.filters,
        useCache: true,
      );
      emit(SeriesLoaded(data));
    } catch (e) {
      emit(SeriesError('Failed to load series: ${e.toString()}'));
    }
  }

  Future<void> _onSeriesLoadMore(
    SeriesLoadMore event,
    Emitter<SeriesState> emit,
  ) async {
    if (event.nextPageUrl == null || event.nextPageUrl!.isEmpty) {
      return;
    }

    final currentState = state;
    if (currentState is SeriesLoaded) {
      emit(SeriesLoadingMore(currentState.data));
    }

    try {
      final newData = await _repository.getSeriesPage(
        url: event.nextPageUrl!,
        filters: event.filters,
        useCache: false, // Для пагинации не используем кеш
      );

      if (currentState is SeriesLoaded) {
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
        emit(SeriesLoaded(mergedData));
      }
    } catch (e) {
      emit(SeriesError('Failed to load more series: ${e.toString()}'));
    }
  }

  Future<void> _onSeriesApplyFilters(
    SeriesApplyFilters event,
    Emitter<SeriesState> emit,
  ) async {
    logEvent(event);
    // Фильтры применяются при следующей загрузке
    // Можно добавить логику для применения фильтров к текущему состоянию
  }

  Future<void> _onSeriesResetFilters(
    SeriesResetFilters event,
    Emitter<SeriesState> emit,
  ) async {
    logEvent(event);
    // Сброс фильтров - можно добавить логику
  }

  Future<void> _onSeriesChangePage(
    SeriesChangePage event,
    Emitter<SeriesState> emit,
  ) async {
    logEvent(event);
    emit(SeriesLoading());

    // Construct URL for the page
    final baseUrl = 'https://yummyanime.tv/series';
    final url = event.page == 1 ? baseUrl : '$baseUrl/page/${event.page}';

    try {
      final data = await _repository.getSeriesPage(
        url: url,
        filters: event.filters,
        useCache: true,
      );
      emit(SeriesLoaded(data));
    } catch (e) {
      emit(SeriesError('Failed to change page: ${e.toString()}'));
    }
  }

  Future<void> _onSeriesRefresh(
    SeriesRefresh event,
    Emitter<SeriesState> emit,
  ) async {
    logEvent(event);
    emit(SeriesLoading());

    try {
      final data = await _repository.getSeriesPage(
        url: event.url,
        filters: event.filters,
        useCache: false, // Принудительное обновление
      );
      emit(SeriesLoaded(data));
    } catch (e) {
      emit(SeriesError('Failed to refresh series: ${e.toString()}'));
    }
  }
}
