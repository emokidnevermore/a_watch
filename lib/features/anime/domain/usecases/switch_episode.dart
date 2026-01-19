import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/domain/usecases/viewing_state_service.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/result/result.dart';

class SwitchEpisodeParams {
  final String epId;
  final String epHash;
  final KodikContent kodikContent;
  final String? selectedQuality;

  const SwitchEpisodeParams({
    required this.epId,
    required this.epHash,
    required this.kodikContent,
    this.selectedQuality,
  });
}

class SwitchEpisodeResult {
  final KodikContent kodikContent;
  final Map<String, List<KodikStream>> kodikStreams;
  final String currentVideoUrl;
  final String selectedQuality;

  const SwitchEpisodeResult({
    required this.kodikContent,
    required this.kodikStreams,
    required this.currentVideoUrl,
    required this.selectedQuality,
  });
}

class SwitchEpisodeUseCase {
  final KodikExtractor _kodikExtractor;
  final ViewingStateService _viewingStateService;
  final ILogger _logger;

  SwitchEpisodeUseCase(
    this._kodikExtractor,
    this._viewingStateService,
    this._logger,
  );

  Future<Result<SwitchEpisodeResult>> call(SwitchEpisodeParams params) async {
    try {
      final kodikContent = params.kodikContent;

      final currentState = _viewingStateService.getCurrentState();
      if (currentState?.currentMediaId.isEmpty ?? true) {
        // Fallback method when no translation state exists
        _logger.logInfo('No translation state, using fallback method', 'EpisodeSwitch');

        final iframeUrl = kodikContent.iframeUrl ?? 'https://kodik.cc/';
        final uri = Uri.parse(iframeUrl);
        final newParams = Map<String, String>.from(uri.queryParameters);

        // Get season and episode numbers from fileList
        String? seasonNum;
        String? epNum;
        kodikContent.fileList['all']?.forEach((s, episodes) {
          (episodes as Map<String, dynamic>).forEach((episodeNum, data) {
            if (data['id']?.toString() == params.epId) {
              seasonNum = s;
              epNum = episodeNum;
            }
          });
        });

        if (seasonNum != null) newParams['season'] = seasonNum!;
        newParams['episode'] = epNum ?? '1';

        final nextIframeUrl = uri.replace(queryParameters: newParams).toString();
        final content = await _kodikExtractor.extractContentFromIframe(nextIframeUrl);

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
        final separator = url.contains('?') ? '&' : '?';
        final currentVideoUrl = '$url${separator}t=${DateTime.now().millisecondsSinceEpoch}';

        return Success(SwitchEpisodeResult(
          kodikContent: content,
          kodikStreams: content.streams,
          currentVideoUrl: currentVideoUrl,
          selectedQuality: quality,
        ));
      }

      // Main method with translation state
      final baseUri = Uri.parse('https://kodik.cc/serial/${currentState!.currentMediaId}/${currentState.currentMediaHash}/720p');
      final season = _getSeasonFromEpisodeId(params.epId, kodikContent);
      final episode = _getEpisodeNumFromEpisodeId(params.epId, kodikContent);

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
        'season': season,
        'episode': episode,
      };

      final iframeUrl = baseUri.replace(queryParameters: iframeParams).toString();
      final content = await _kodikExtractor.extractContentFromIframe(iframeUrl);

      // Update viewing state
      _viewingStateService.updateEpisode(season, episode);

      // Sync active fileList
      content.fileList['active']['season'] = season;
      content.fileList['active']['episode_num'] = episode;

      // Determine quality
      String quality;
      if (content.streams.keys.contains(params.selectedQuality)) {
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

      return Success(SwitchEpisodeResult(
        kodikContent: content,
        kodikStreams: content.streams,
        currentVideoUrl: currentVideoUrl,
        selectedQuality: quality,
      ));
    } catch (e, stack) {
      _logger.logError('Error switching episode', 'EpisodeSwitch', e, stack);
      return Failure('Failed to switch episode: ${e.toString()}');
    }
  }

  String _getSeasonFromEpisodeId(String epId, KodikContent kodikContent) {
    final all = kodikContent.fileList['all'] as Map<String, dynamic>?;
    if (all == null) return '1';

    for (final season in all.keys) {
      final episodes = all[season] as Map<String, dynamic>;
      for (final episode in episodes.keys) {
        final data = episodes[episode] as Map<String, dynamic>;
        if (data['id'].toString() == epId) {
          return season;
        }
      }
    }
    return '1';
  }

  String _getEpisodeNumFromEpisodeId(String epId, KodikContent kodikContent) {
    final all = kodikContent.fileList['all'] as Map<String, dynamic>?;
    if (all == null) return '1';

    for (final season in all.keys) {
      final episodes = all[season] as Map<String, dynamic>;
      for (final episode in episodes.keys) {
        final data = episodes[episode] as Map<String, dynamic>;
        if (data['id'].toString() == epId) {
          return episode;
        }
      }
    }
    return '1';
  }
}
