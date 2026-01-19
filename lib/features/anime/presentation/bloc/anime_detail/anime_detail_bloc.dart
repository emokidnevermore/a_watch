import 'package:a_watch/features/anime/domain/usecases/get_anime_detail.dart';
import 'package:a_watch/features/anime/presentation/bloc/anime_detail/anime_detail_event.dart';
import 'package:a_watch/features/anime/presentation/bloc/anime_detail/anime_detail_state.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/result/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimeDetailBloc extends BaseBloc<AnimeDetailEvent, AnimeDetailState> {
  final GetAnimeDetailUseCase _getAnimeDetailUseCase;

  AnimeDetailBloc(this._getAnimeDetailUseCase, ILogger logger)
      : super(logger, AnimeDetailInitial()) {
    on<LoadAnimeDetail>(_onLoadAnimeDetail);
  }

  Future<void> _onLoadAnimeDetail(
    LoadAnimeDetail event,
    Emitter<AnimeDetailState> emit,
  ) async {
    logEvent(event);
    emit(AnimeDetailLoading());

    final result = await _getAnimeDetailUseCase(
      url: event.animeUrl,
      useCache: true,
    );

    switch (result) {
      case Success(data: final animeDetail):
        emit(AnimeDetailLoaded(animeDetail));
      case Failure(message: final message, error: _):
        emit(AnimeDetailError(message));
    }
  }
}
