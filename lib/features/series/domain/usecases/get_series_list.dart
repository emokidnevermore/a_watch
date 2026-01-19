import 'package:a_watch/features/series/domain/repositories/series_repository.dart';
import 'package:a_watch/domain/entities/series_page_data.dart';
import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/core/result/result.dart';

class GetSeriesListUseCase {
  final SeriesRepository _repository;

  GetSeriesListUseCase(this._repository);

  Future<Result<SeriesPageData>> call({
    required String url,
    SeriesFilters? filters,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    try {
      final result = await _repository.getSeriesPage(
        url: url,
        filters: filters,
        useCache: useCache && !forceRefresh,
      );
      return Success(result);
    } catch (e) {
      return Failure('Failed to load series list: ${e.toString()}');
    }
  }
}
