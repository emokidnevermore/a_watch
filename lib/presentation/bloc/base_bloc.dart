import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/result/result.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final ILogger logger;

  BaseBloc(this.logger, State initialState) : super(initialState);

  /// Безопасное выполнение асинхронной операции с обработкой ошибок
  /// Используйте Emitter из обработчика событий
  Future<void> safeEmit(
    Emitter<State> emit,
    Future<void> Function() operation,
    State Function() loadingState,
    State Function(dynamic error) errorState,
  ) async {
    try {
      emit(loadingState());
      await operation();
    } catch (e, stackTrace) {
      logger.logError('BLoC operation failed', null, e, stackTrace);
      emit(errorState(e));
    }
  }

  /// Безопасное выполнение асинхронной операции с Result
  /// Используйте Emitter из обработчика событий
  Future<void> safeEmitWithResult<T>(
    Emitter<State> emit,
    Future<Result<T>> Function() operation,
    State Function() loadingState,
    State Function(String message, dynamic error) errorState,
    State Function(T data) successState,
  ) async {
    try {
      emit(loadingState());
      final result = await operation();

      result.when(
        onSuccess: (data) {
          emit(successState(data));
        },
        onFailure: (message, error) {
          logger.logError('BLoC operation failed: $message', null, error);
          emit(errorState(message, error));
        },
      );
    } catch (e, stackTrace) {
      logger.logError('BLoC unexpected error', null, e, stackTrace);
      emit(errorState('Unexpected error occurred', e));
    }
  }

  /// Логирование событий (можно переопределить в middleware)
  void logEvent(Event event) {
    logger.logDebug('Event: ${event.runtimeType}');
  }

  /// Логирование состояний (можно переопределить в middleware)
  void logState(State state) {
    logger.logDebug('State: ${state.runtimeType}');
  }
}
