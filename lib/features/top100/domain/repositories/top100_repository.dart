import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';

/// Repository interface for top100 data
abstract class Top100Repository {
  /// Get top100 page data for specific filter
  Future<Top100PageData> getTop100Page({
    Top100Filter filter = Top100Filter.all,
    bool useCache = true,
  });
}
