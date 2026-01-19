import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/page_result.dart';
import 'package:a_watch/features/anime/domain/usecases/get_anime_list.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_event.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_state.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/result/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimeListBloc extends BaseBloc<AnimeListEvent, AnimeListState> {
  final GetAnimeListUseCase _getAnimeListUseCase;

  AnimeListBloc(this._getAnimeListUseCase, ILogger logger) 
      : super(logger, AnimeListInitial()) {
    on<AnimeListLoad>(_onAnimeListLoad);
    on<AnimeListLoadMore>(_onAnimeListLoadMore);
    on<AnimeListRefresh>(_onAnimeListRefresh);
    on<AnimeListSearch>(_onAnimeListSearch);
  }

  Future<void> _onAnimeListLoad(
    AnimeListLoad event,
    Emitter<AnimeListState> emit,
  ) async {
    logEvent(event);
    emit(AnimeListLoading());
    
    final result = await _getAnimeListUseCase(
      url: event.url,
      useCache: event.useCache,
      forceRefresh: event.forceRefresh,
    );

    switch (result) {
      case Success(data: final pageResult):
        emit(AnimeListLoaded(pageResult: pageResult));
      case Failure(message: final message, error: _):
        emit(AnimeListError(message));
    }
  }

  Future<void> _onAnimeListLoadMore(
    AnimeListLoadMore event,
    Emitter<AnimeListState> emit,
  ) async {
    if (event.nextPageUrl == null || event.nextPageUrl!.isEmpty) {
      return;
    }

    final currentState = state;
    if (currentState is AnimeListLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final result = await _getAnimeListUseCase(
      url: event.nextPageUrl!,
      useCache: false,
    );

    switch (result) {
      case Success(data: final pageResult):
        if (currentState is AnimeListLoaded) {
          final mergedItems = [...currentState.pageResult.items, ...pageResult.items];
          final mergedPageResult = PageResult<Anime>(
            items: mergedItems,
            page: pageResult.page,
            nextPageUrl: pageResult.nextPageUrl,
            prevPageUrl: pageResult.prevPageUrl,
          );
          emit(AnimeListLoaded(pageResult: mergedPageResult, isLoadingMore: false));
        }
      case Failure(message: final message, error: _):
        logger.logError('Failed to load more anime: $message');
        emit(AnimeListError(message));
    }
  }

  Future<void> _onAnimeListRefresh(
    AnimeListRefresh event,
    Emitter<AnimeListState> emit,
  ) async {
    logEvent(event);
    emit(AnimeListLoading());
    
    final result = await _getAnimeListUseCase(
      url: event.url,
      useCache: false,
    );

    switch (result) {
      case Success(data: final pageResult):
        emit(AnimeListLoaded(pageResult: pageResult));
      case Failure(message: final message, error: _):
        logger.logError('Failed to refresh anime list: $message');
        emit(AnimeListError(message));
    }
  }

  Future<void> _onAnimeListSearch(
    AnimeListSearch event,
    Emitter<AnimeListState> emit,
  ) async {
    logEvent(event);
    emit(AnimeListLoading());
    
    final searchUrl = 'https://yummyanime.tv/index.php?do=search&subaction=search&story=${Uri.encodeComponent(event.query)}';
    final result = await _getAnimeListUseCase(
      url: searchUrl,
      useCache: false,
    );

    switch (result) {
      case Success(data: final pageResult):
        emit(AnimeListLoaded(pageResult: pageResult));
      case Failure(message: final message, error: _):
        logger.logError('Failed to search anime: $message');
        emit(AnimeListError(message));
    }
  }
}

extension AnimeListLoadedExtension on AnimeListLoaded {
  AnimeListLoaded copyWith({
    PageResult<Anime>? pageResult, 
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return AnimeListLoaded(
      pageResult: pageResult ?? this.pageResult,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
