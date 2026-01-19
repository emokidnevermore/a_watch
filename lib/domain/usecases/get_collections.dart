import 'package:a_watch/domain/entities/collection.dart';
import 'package:a_watch/features/anime/domain/repositories/anime_repository.dart';
import 'package:a_watch/core/result/result.dart';

class GetCollectionsUseCase {
  final AnimeRepository _repository;

  GetCollectionsUseCase(this._repository);

  Future<Result<List<Collection>>> execute({
    required String url,
    bool useCache = true,
  }) async {
    try {
      final result = await _repository.getCollections(url: url, useCache: useCache);
      return Success(result);
    } catch (e) {
      return Failure('Failed to load collections: ${e.toString()}');
    }
  }
}
