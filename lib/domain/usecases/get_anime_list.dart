import 'package:a_watch/domain/entities/anime.dart';
import 'package:a_watch/domain/entities/page_result.dart';
import 'package:a_watch/domain/repositories/anime_repository.dart';
import 'package:a_watch/core/result/result.dart';

class GetAnimeListUseCase {
  final AnimeRepository _repository;

  GetAnimeListUseCase(this._repository);

  Future<Result<PageResult<Anime>>> call({
    required String url,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    try {
      final result = await _repository.getAnimeList(
        url: url, 
        useCache: useCache && !forceRefresh,
      );
      return Success(result);
    } catch (e) {
      return Failure('Failed to load anime list: ${e.toString()}');
    }
  }
}
