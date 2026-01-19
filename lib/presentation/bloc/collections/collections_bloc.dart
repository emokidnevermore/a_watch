import 'package:a_watch/domain/usecases/get_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/presentation/bloc/collections/collections_event.dart';
import 'package:a_watch/presentation/bloc/collections/collections_state.dart';
import 'package:a_watch/core/result/result.dart';
import 'package:a_watch/core/logger/logger.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase _getCollectionsUseCase;
  final ILogger logger;

  CollectionsBloc(this._getCollectionsUseCase, this.logger) : super(CollectionsInitial()) {
    on<CollectionsLoad>(_onCollectionsLoad);
  }

  Future<void> _onCollectionsLoad(
    CollectionsLoad event,
    Emitter<CollectionsState> emit,
  ) async {
    emit(CollectionsLoading());
    final result = await _getCollectionsUseCase.execute(
      url: event.url,
      useCache: event.useCache,
    );

    switch (result) {
      case Success(data: final collections):
        emit(CollectionsLoaded(collections));
      case Failure(message: final message, error: _):
        emit(CollectionsError(message));
    }
  }
}
