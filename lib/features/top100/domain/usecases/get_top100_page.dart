import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';
import 'package:a_watch/features/top100/domain/repositories/top100_repository.dart';

/// Use case for getting top100 page data
class GetTop100PageUseCase {
  final Top100Repository _repository;

  GetTop100PageUseCase(this._repository);

  /// Get top100 page data for specific filter
  Future<Top100PageData> call({
    Top100Filter filter = Top100Filter.all,
    bool useCache = true,
  }) {
    return _repository.getTop100Page(
      filter: filter,
      useCache: useCache,
    );
  }
}
