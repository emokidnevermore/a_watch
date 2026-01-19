import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/data/config/selectors_config.dart';
import 'package:a_watch/data/parser/top100_page_parser.dart';
import 'package:a_watch/features/top100/domain/entities/top100_page_data.dart';
import 'package:a_watch/features/top100/domain/repositories/top100_repository.dart';

class Top100RepositoryImpl implements Top100Repository {
  final IHttpService _httpService;
  final SelectorsConfig _selectorsConfig;
  final ILogger _logger;

  Top100RepositoryImpl({
    required IHttpService httpService,
    required SelectorsConfig selectorsConfig,
    required ILogger logger,
  }) : _httpService = httpService,
       _selectorsConfig = selectorsConfig,
       _logger = logger {
    _logger.logInfo('Top100RepositoryImpl CONSTRUCTOR called', 'Top100Repository');
  }

  @override
  Future<Top100PageData> getTop100Page({
    Top100Filter filter = Top100Filter.all,
    bool useCache = true,
  }) async {
    _logger.logDebug('REPOSITORY: getTop100Page called with filter: ${filter.displayName}', 'Top100Repository');

    // Use AJAX endpoint for filtering (no caching since content is dynamic)
    final ajaxUrl = 'https://yummyanime.tv/engine/ajax/controller.php?mod=custom';

    // Prepare POST data
    final postData = {
      'mod': 'custom',
      'id': filter.id.toString(),
    };

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Referer': 'https://yummyanime.tv/top_100-y18/',
      'x-requested-with': 'XMLHttpRequest',
      'origin': 'https://yummyanime.tv',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'priority': 'u=1, i',
    };

    final response = await _httpService.post(
      ajaxUrl,
      headers: headers,
      body: postData,
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    final html = response.body;

    // Parse with Top100PageParser
    final selectors = _selectorsConfig.getSelectors('top100_page') ?? {};
    final parser = Top100PageParser(logger: _logger);

    final parseResult = await parser.parseAjaxResponse(
      htmlContent: html,
      selectors: selectors,
      config: _selectorsConfig,
      baseUrl: 'https://yummyanime.tv',
    );

    // Override the current filter to match what we requested
    final result = parseResult.copyWith(currentFilter: filter);

    return result;
  }
}
