import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/features/top100/domain/usecases/get_top100_page.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_event.dart';
import 'package:a_watch/features/top100/presentation/bloc/top100_state.dart';
import 'package:a_watch/core/logger/logger.dart';

class Top100Bloc extends BaseBloc<Top100Event, Top100State> {
  final GetTop100PageUseCase _getTop100PageUseCase;

  Top100Bloc(this._getTop100PageUseCase, ILogger logger)
      : super(logger, Top100Initial()) {
    on<Top100Load>(_onTop100Load);
    on<Top100ChangeFilter>(_onTop100ChangeFilter);
    on<Top100Refresh>(_onTop100Refresh);
  }

  Future<void> _onTop100Load(
    Top100Load event,
    Emitter<Top100State> emit,
  ) async {
    logEvent(event);
    logger.logDebug('BLOC: Top100Load event with filter: ${event.filter.displayName}', 'Top100Bloc');

    emit(Top100Loading());

    try {
      final data = await _getTop100PageUseCase.call(
        filter: event.filter,
        useCache: false, // Dynamic content, no caching
      );
      emit(Top100Loaded(data));
    } catch (e) {
      emit(Top100Error('Failed to load top100: ${e.toString()}'));
    }
  }

  Future<void> _onTop100ChangeFilter(
    Top100ChangeFilter event,
    Emitter<Top100State> emit,
  ) async {
    logEvent(event);
    logger.logDebug('BLOC: Top100ChangeFilter event with filter: ${event.filter.displayName}', 'Top100Bloc');

    emit(Top100Loading());

    try {
      final data = await _getTop100PageUseCase.call(
        filter: event.filter,
        useCache: false, // Dynamic content, no caching
      );
      emit(Top100Loaded(data));
    } catch (e) {
      emit(Top100Error('Failed to change filter: ${e.toString()}'));
    }
  }

  Future<void> _onTop100Refresh(
    Top100Refresh event,
    Emitter<Top100State> emit,
  ) async {
    logEvent(event);
    logger.logDebug('BLOC: Top100Refresh event with filter: ${event.filter.displayName}', 'Top100Bloc');

    emit(Top100Loading());

    try {
      final data = await _getTop100PageUseCase.call(
        filter: event.filter,
        useCache: false, // Force refresh
      );
      emit(Top100Loaded(data));
    } catch (e) {
      emit(Top100Error('Failed to refresh top100: ${e.toString()}'));
    }
  }
}
