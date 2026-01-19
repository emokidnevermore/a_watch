import 'package:a_watch/domain/entities/anime.dart';
import 'package:a_watch/domain/repositories/anime_repository.dart';
import 'package:a_watch/core/result/result.dart';

class GetAnimeDetailUseCase {
  final AnimeRepository _repository;

  GetAnimeDetailUseCase(this._repository);

  Future<Result<Anime>> call({
    required String url,
    bool useCache = true,
  }) async {
    try {
      final result = await _repository.getAnimeDetail(url: url, useCache: useCache);
      return Success(result);
    } catch (e) {
      return Failure('Failed to load anime detail: ${e.toString()}');
    }
  }
}
