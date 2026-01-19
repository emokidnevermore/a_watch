import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:a_watch/features/catalog/domain/entities/catalog_page_data.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:a_watch/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:a_watch/core/logger/logger.dart';

class CatalogBloc extends BaseBloc<CatalogEvent, CatalogState> {
  final CatalogRepository _repository;

  CatalogBloc(this._repository, ILogger logger)
      : super(logger, CatalogInitial()) {
    on<CatalogLoad>(_onCatalogLoad);
    on<CatalogLoadMore>(_onCatalogLoadMore);
    on<CatalogApplyFilters>(_onCatalogApplyFilters);
    on<CatalogResetFilters>(_onCatalogResetFilters);
    on<CatalogChangePage>(_onCatalogChangePage);
    on<CatalogRefresh>(_onCatalogRefresh);
  }

  Future<void> _onCatalogLoad(
    CatalogLoad event,
    Emitter<CatalogState> emit,
  ) async {
    logEvent(event);
    logger.logDebug('BLOC: CatalogLoad event with url=${event.url}, filters=${event.filters}, isFiltering=${event.isFiltering}', 'CatalogBloc');

    // If filtering, emit CatalogFiltering with current data instead of CatalogLoading
    if (event.isFiltering) {
      final currentState = state;
      if (currentState is CatalogLoaded) {
        emit(CatalogFiltering(currentState.data));
      } else {
        emit(CatalogLoading()); // Fallback if no current data
      }
    } else {
      emit(CatalogLoading());
    }

    try {
      final data = await _repository.getCatalogPage(
        url: event.url,
        filters: event.filters,
        useCache: true,
      );
      emit(CatalogLoaded(data));
    } catch (e) {
      emit(CatalogError('Failed to load catalog: ${e.toString()}'));
    }
  }

  Future<void> _onCatalogLoadMore(
    CatalogLoadMore event,
    Emitter<CatalogState> emit,
  ) async {
    if (event.nextPageUrl == null || event.nextPageUrl!.isEmpty) {
      return;
    }

    final currentState = state;
    if (currentState is CatalogLoaded) {
      emit(CatalogLoadingMore(currentState.data));
    }

    try {
      final newData = await _repository.getCatalogPage(
        url: event.nextPageUrl!,
        filters: event.filters,
        useCache: false, // Для пагинации не используем кеш
      );

      if (currentState is CatalogLoaded) {
        // Объединяем данные
        final mergedItems = [...currentState.data.items, ...newData.items];
        final mergedData = CatalogPageData(
          carousel: currentState.data.carousel, // Карусель остается из первой страницы
          items: mergedItems,
          currentPage: newData.currentPage,
          totalPages: newData.totalPages,
          availableFilters: newData.availableFilters,
          nextPageUrl: newData.nextPageUrl,
          prevPageUrl: newData.prevPageUrl,
        );
        emit(CatalogLoaded(mergedData));
      }
    } catch (e) {
      emit(CatalogError('Failed to load more catalog: ${e.toString()}'));
    }
  }

  Future<void> _onCatalogApplyFilters(
    CatalogApplyFilters event,
    Emitter<CatalogState> emit,
  ) async {
    logEvent(event);
    // Фильтры применяются при следующей загрузке
    // Можно добавить логику для применения фильтров к текущему состоянию
  }

  Future<void> _onCatalogResetFilters(
    CatalogResetFilters event,
    Emitter<CatalogState> emit,
  ) async {
    logEvent(event);
    // Сброс фильтров - можно добавить логику
  }

  Future<void> _onCatalogChangePage(
    CatalogChangePage event,
    Emitter<CatalogState> emit,
  ) async {
    logEvent(event);
    emit(CatalogLoading());

    // Construct URL for the page
    final baseUrl = 'https://yummyanime.tv/catalog-y5';
    final url = event.page == 1 ? baseUrl : '$baseUrl/page/${event.page}';

    try {
      final data = await _repository.getCatalogPage(
        url: url,
        filters: event.filters,
        useCache: true,
      );
      emit(CatalogLoaded(data));
    } catch (e) {
      emit(CatalogError('Failed to change page: ${e.toString()}'));
    }
  }

  Future<void> _onCatalogRefresh(
    CatalogRefresh event,
    Emitter<CatalogState> emit,
  ) async {
    logEvent(event);
    emit(CatalogLoading());

    try {
      final data = await _repository.getCatalogPage(
        url: event.url,
        filters: event.filters,
        useCache: false, // Принудительное обновление
      );
      emit(CatalogLoaded(data));
    } catch (e) {
      emit(CatalogError('Failed to refresh catalog: ${e.toString()}'));
    }
  }
}
