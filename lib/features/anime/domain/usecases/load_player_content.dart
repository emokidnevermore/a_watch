import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/domain/usecases/viewing_state_service.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/result/result.dart';

class LoadPlayerContentParams {
  final String animeUrl;

  const LoadPlayerContentParams({
    required this.animeUrl,
  });
}

class LoadPlayerContentResult {
  final KodikContent kodikContent;
  final Map<String, List<KodikStream>> kodikStreams;
  final String currentVideoUrl;
  final String selectedQuality;

  const LoadPlayerContentResult({
    required this.kodikContent,
    required this.kodikStreams,
    required this.currentVideoUrl,
    required this.selectedQuality,
  });
}

class LoadPlayerContentUseCase {
  final KodikExtractor _kodikExtractor;
  final ViewingStateService _viewingStateService;
  final ILogger _logger;

  LoadPlayerContentUseCase(
    this._kodikExtractor,
    this._viewingStateService,
    this._logger,
  );

  Future<Result<LoadPlayerContentResult>> call(LoadPlayerContentParams params) async {
    try {
      _logger.logInfo('Starting loadPlayerContent for ${params.animeUrl}');

      final animeId = params.animeUrl.split('/').last.split('.').first;
      final content = await _kodikExtractor.extractContent(params.animeUrl);

      // Initialize viewing state
      _viewingStateService.initializeFromKodikContent(content, animeId);

      String quality;
      String currentVideoUrl;
      if (content.streams.isNotEmpty) {
        quality = content.streams.keys.contains('720') ? '720' : content.streams.keys.first;
        String url = content.streams[quality]!.first.url;
        if (url.startsWith('//')) {
          url = 'https:$url';
        } else if (!url.startsWith('http') && url.contains('.')) {
          url = 'https://$url';
        }
        currentVideoUrl = url;
      } else {
        quality = '720';
        currentVideoUrl = '';
      }

      return Success(LoadPlayerContentResult(
        kodikContent: content,
        kodikStreams: content.streams,
        currentVideoUrl: currentVideoUrl,
        selectedQuality: quality,
      ));
    } catch (e, stack) {
      _logger.logError('Error loading player content', 'PlayerContent', e, stack);
      return Failure('Failed to load player content: ${e.toString()}');
    }
  }
}
