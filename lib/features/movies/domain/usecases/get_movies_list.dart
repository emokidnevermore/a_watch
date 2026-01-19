import 'package:a_watch/features/movies/domain/repositories/movies_repository.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/domain/entities/series_filters.dart';

class GetMoviesListUseCase {
  final MoviesRepository _repository;

  GetMoviesListUseCase(this._repository);

  Future<SeriesPageData> call({
    required String url,
    SeriesFilters? filters,
    bool useCache = true,
  }) {
    return _repository.getMoviesPage(
      url: url,
      filters: filters,
      useCache: useCache,
    );
  }
}
