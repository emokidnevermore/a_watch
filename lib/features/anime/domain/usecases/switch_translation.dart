import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/domain/usecases/viewing_state_service.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/result/result.dart';

class SwitchTranslationParams {
  final String mediaId;
  final String mediaHash;
  final KodikContent kodikContent;
  final String? selectedQuality;

  const SwitchTranslationParams({
    required this.mediaId,
    required this.mediaHash,
    required this.kodikContent,
    this.selectedQuality,
  });
}

class SwitchTranslationResult {
  final KodikContent kodikContent;
  final Map<String, List<KodikStream>> kodikStreams;
  final String currentVideoUrl;
  final String selectedQuality;

  const SwitchTranslationResult({
    required this.kodikContent,
    required this.kodikStreams,
    required this.currentVideoUrl,
    required this.selectedQuality,
  });
}

class SwitchTranslationUseCase {
  final KodikExtractor _kodikExtractor;
  final ViewingStateService _viewingStateService;
  final ILogger _logger;

  SwitchTranslationUseCase(
    this._kodikExtractor,
    this._viewingStateService,
    this._logger,
  );

  Future<Result<SwitchTranslationResult>> call(SwitchTranslationParams params) async {
    try {
      _logger.logInfo('Switching to translation ${params.mediaId}:${params.mediaHash}', 'TranslationSwitch');

      final kodikContent = params.kodikContent;

      // Get current episode info
      final active = kodikContent.fileList['active'] as Map<String, dynamic>?;
      final currentSeason = active?['season']?.toString() ?? '1';
      final currentEpisode = active?['episode_num']?.toString() ?? '1';

      // Construct new iframe URL for the translation
      final baseUri = Uri.parse('https://kodik.cc/serial/${params.mediaId}/${params.mediaHash}/720p');
      final iframeParams = <String, String>{
        'd': 'yummyanime.tv',
        'd_sign': kodikContent.urlParams['d_sign'] ?? '',
        'pd': 'kodik.cc',
        'pd_sign': kodikContent.urlParams['pd_sign'] ?? '',
        'ref': 'https://yummyanime.tv/',
        'ref_sign': kodikContent.urlParams['ref_sign'] ?? '',
        'advert_debug': 'true',
        'min_age': '16',
        'first_url': 'false',
        'season': currentSeason,
        'episode': currentEpisode,
      };
      final iframeUrl = baseUri.replace(queryParameters: iframeParams).toString();

      _logger.logInfo('Loading content from: $iframeUrl');

      // Load content for the new translation
      final content = await _kodikExtractor.extractContentFromIframe(iframeUrl);

      // Update viewing state
      _viewingStateService.updateTranslation(
        params.mediaId,
        params.mediaHash,
        content.fileList['active']?['translation']?.toString() ?? '0',
      );

      // Sync active fileList
      content.fileList['active']['season'] = currentSeason;
      content.fileList['active']['episode_num'] = currentEpisode;

      // Determine quality
      String quality;
      if (params.selectedQuality != null && content.streams.keys.contains(params.selectedQuality)) {
        quality = params.selectedQuality!;
      } else if (content.streams.keys.contains('720')) {
        quality = '720';
      } else {
        quality = content.streams.keys.first;
      }

      String url = content.streams[quality]!.first.url;
      if (url.startsWith('//')) {
        url = 'https:$url';
      } else if (!url.startsWith('http') && url.contains('.')) {
        url = 'https://$url';
      }
      final currentVideoUrl = url;

      _logger.logInfo('New streams quality: ${content.streams.keys}');

      return Success(SwitchTranslationResult(
        kodikContent: content,
        kodikStreams: content.streams,
        currentVideoUrl: currentVideoUrl,
        selectedQuality: quality,
      ));
    } catch (e, stack) {
      _logger.logError('Error changing translation', 'TranslationSwitch', e, stack);
      return Failure('Failed to switch translation: ${e.toString()}');
    }
  }
}
