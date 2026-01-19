import 'dart:convert';
import 'dart:developer';
import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/core/di/service_locator.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;

class KodikSkipTiming {
  final Duration start;
  final Duration end;
  final String type; // 'opening' or 'ending'

  KodikSkipTiming({required this.start, required this.end, required this.type});
}

class KodikContent {
  final Map<String, dynamic> ftorData;
  final Map<String, List<KodikStream>> streams;
  final Map<String, dynamic> fileList;
  final String? type;
  final String? iframeUrl;
  final Map<String, dynamic> urlParams;
  final List<KodikSkipTiming> skipTimings;
  final String? videoInfoHash;
  final String? videoInfoId;

  KodikContent({
    required this.ftorData,
    required this.streams,
    required this.fileList,
    required this.urlParams,
    required this.skipTimings,
    this.type,
    this.iframeUrl,
    this.videoInfoHash,
    this.videoInfoId,
  });
}

class KodikStream {
  final String url;
  final String type;

  KodikStream({required this.url, required this.type});
}

class KodikExtractor {
  final IHttpService _httpService;

  KodikExtractor() : _httpService = getIt<IHttpService>();

  Future<KodikContent> extractContent(String animeUrl) async {
    log('[Kodik] Starting extraction for $animeUrl');

    final idMatch = RegExp(r'/(\d+)-').firstMatch(animeUrl);
    if (idMatch == null) {
      throw Exception('Could not extract anime ID from URL: $animeUrl');
    }
    final animeId = idMatch.group(1)!;

    final controllerUrl =
        'https://yummyanime.tv/engine/ajax/controller.php?mod=kodik-player&url=1&action=iframe&id=$animeId';

    log('[Kodik] Fetching iframe URL from $controllerUrl');
    final controllerResponse = await _httpService.get(
      controllerUrl,
      headers: {
        'Referer': 'https://yummyanime.tv/engine/ajax/controller.php?mod=xfp',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    if (controllerResponse.statusCode != 200) {
      throw Exception(
        'Failed to get iframe URL: ${controllerResponse.statusCode}',
      );
    }

    final controllerData = jsonDecode(controllerResponse.body);
    if (controllerData['success'] != true) {
      throw Exception(
        'Controller returned failure: ${controllerResponse.body}',
      );
    }

    final iframeUrl = controllerData['data'] as String;
    log('[Kodik] Iframe URL: $iframeUrl');

    final iframeResponse = await _httpService.get(
      iframeUrl,
      headers: {'Referer': 'https://yummyanime.tv/'},
    );

    if (iframeResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch iframe content: ${iframeResponse.statusCode}',
      );
    }

    final htmlBody = iframeResponse.body;
    final document = html.parse(htmlBody);
    final scripts = document.querySelectorAll('script');

    String? urlParamsStr;
    String? hash;
    String? id;
    String? type;

    String? skipButtonStr;

    for (final script in scripts) {
      final text = script.text;
      if (text.contains('var urlParams')) {
        final match = RegExp(
          r"var urlParams\s*=\s*['"
                  '"' r"](.+?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) urlParamsStr = match.group(1);
      }
      if (text.contains('videoInfo.hash')) {
        final match = RegExp(
          r"videoInfo\.hash\s*=\s*['"
                  '"' r"](.*?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) hash = match.group(1);
      }
      if (text.contains('videoInfo.id')) {
        final match = RegExp(
          r"videoInfo\.id\s*=\s*['"
                  '"' r"](.*?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) id = match.group(1);
      }

      log('[Kodik] Extracted variables: Type=$type, ID=$id, Hash=$hash');

      if (text.contains('videoInfo.type')) {
        final match = RegExp(
          r"videoInfo\.type\s*=\s*['"
                  '"' r"](.*?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) type = match.group(1);
      }
      if (text.contains('playerSettings.skipButton')) {
        final match = RegExp(
          r'playerSettings\.skipButton\s*=\s*parseSkipButton\(\s*["'
                  "'" r'](.*?)["' "'" r']',
        ).firstMatch(text);
        if (match != null) skipButtonStr = match.group(1);
      }
    }

    if (urlParamsStr == null || hash == null || id == null || type == null) {
      log(
        '[Kodik] Failed to find: Params=$urlParamsStr, Hash=$hash, ID=$id, Type=$type',
      );
      throw Exception('Could not extract required variables from iframe HTML');
    }

    log('[Kodik] Extracted variables: Type=$type, ID=$id, Hash=$hash');
    final urlParams = jsonDecode(urlParamsStr);

    final fileList = _parseFileList(document, type, id, hash);

    final ftorData = await fetchFtorLinks(
      iframeUrl: iframeUrl,
      type: type,
      hash: hash,
      id: id,
      urlParams: urlParams,
    );

    // Check if ftor returned a new hash, if so get new iframe and fetch again
    final newHash = ftorData['hash'] as String?;
    if (newHash != null && newHash != hash) {
      log('[Kodik] New hash from ftor: $newHash, getting new iframe');
      final uri = Uri.parse(iframeUrl);
      final pathSegments = List<String>.from(uri.pathSegments);
      if (pathSegments.length >= 3) {
        pathSegments[2] = newHash;
      }
      final newIframeUrl = uri.replace(pathSegments: pathSegments).toString();

      final newIframeResponse = await _httpService.get(
        newIframeUrl,
        headers: {'Referer': 'https://yummyanime.tv/'},
      );

      if (newIframeResponse.statusCode == 200) {
        final newHtmlBody = newIframeResponse.body;
        final newDocument = html.parse(newHtmlBody);
        final newScripts = newDocument.querySelectorAll('script');

        String? newSkipButtonStr;
        for (final script in newScripts) {
          final text = script.text;
          if (text.contains('playerSettings.skipButton')) {
            final match = RegExp(
              r'playerSettings\.skipButton\s*=\s*parseSkipButton\(\s*["'
                      "'" r'](.*?)["' "'" r']',
            ).firstMatch(text);
            if (match != null) newSkipButtonStr = match.group(1);
          }
        }

        final ftorData2 = await fetchFtorLinks(
          iframeUrl: newIframeUrl,
          type: type,
          hash: newHash,
          id: id,
          urlParams: urlParams,
        );

        final encodedLinks2 = ftorData2['links'] as Map<String, dynamic>;
        final decodedStreams2 = decodeStreams(encodedLinks2);

        return KodikContent(
          ftorData: ftorData2,
          streams: decodedStreams2,
          fileList: _parseFileList(newDocument, type, id, newHash),
          urlParams: urlParams,
          skipTimings: _parseSkipTimings(newSkipButtonStr ?? skipButtonStr),
          type: type,
          iframeUrl: newIframeUrl,
        );
      }
    }

    final encodedLinks = ftorData['links'] as Map<String, dynamic>;
    final decodedStreams = decodeStreams(encodedLinks);

    log('[Kodik] Successfully extracted ${decodedStreams.length} qualities');

    return KodikContent(
      ftorData: ftorData,
      streams: decodedStreams,
      fileList: fileList,
      urlParams: urlParams,
      skipTimings: _parseSkipTimings(skipButtonStr),
      type: type,
      iframeUrl: iframeUrl,
      videoInfoHash: hash,
      videoInfoId: id,
    );
  }

  Future<KodikContent> extractContentFromIframe(String iframeUrl) async {
    final uri = Uri.parse(iframeUrl);
    final mediaId = uri.queryParameters['media_id'];
    final mediaHash = uri.queryParameters['media_hash'];

    final iframeResponse = await _httpService.get(
      iframeUrl,
      headers: {'Referer': 'https://yummyanime.tv/'},
    );

    if (iframeResponse.statusCode != 200) {
      throw Exception(
        'Failed to fetch iframe content: ${iframeResponse.statusCode}',
      );
    }

    final htmlBody = iframeResponse.body;
    final document = html.parse(htmlBody);
    final scripts = document.querySelectorAll('script');

    String? urlParamsStr;
    String? hash;
    String? id;
    String? type;

    String? skipButtonStr;

    for (final script in scripts) {
      final text = script.text;
      if (text.contains('var urlParams')) {
        final match = RegExp(
          r"var urlParams\s*=\s*['"
                  '"' r"](.+?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) urlParamsStr = match.group(1);
      }
      if (text.contains('var serialHash')) {
        final match = RegExp(r"var serialHash\s*=\s*['" '"' r"](.*?)['" '"' r"];").firstMatch(text);
        if (match != null) {
          log('[Kodik] serialHash: ${match.group(1)}');
          hash = match.group(1);
        }
      }
      if (text.contains('videoInfo.hash')) {
        final match = RegExp(
          r"videoInfo\.hash\s*=\s*['"
                  '"' r"](.*?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) {
          log('[Kodik] videoInfo.hash: ${match.group(1)}');
          hash = match.group(1);
        }
      }
      if (text.contains('videoInfo.id')) {
        final match = RegExp(
          r"videoInfo\.id\s*=\s*['"
                  '"' r"](.*?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) id = match.group(1);
      }
      if (text.contains('videoInfo.type')) {
        final match = RegExp(
          r"videoInfo\.type\s*=\s*['"
                  '"' r"](.*?)['" '"' r"];",
        ).firstMatch(text);
        if (match != null) type = match.group(1);
      }
      if (text.contains('playerSettings.skipButton')) {
        final match = RegExp(
          r'playerSettings\.skipButton\s*=\s*parseSkipButton\(\s*["'
                  "'" r'](.*?)["' "'" r']',
        ).firstMatch(text);
        if (match != null) skipButtonStr = match.group(1);
      }
    }

    if (urlParamsStr == null || hash == null || id == null || type == null) {
      throw Exception('Could not extract required variables from iframe HTML');
    }

    log('[Kodik] Parsed from iframe: hash=$hash, id=$id, type=$type');
    final urlParams = jsonDecode(urlParamsStr);
    // Add media_id and media_hash to urlParams if not present
    urlParams['media_id'] = mediaId;
    urlParams['media_hash'] = mediaHash;



    final fileList = _parseFileList(document, type, id, hash, mediaId);

    final ftorData = await fetchFtorLinks(
      iframeUrl: iframeUrl,
      type: type,
      hash: hash,
      id: id,
      urlParams: urlParams,
    );

    final encodedLinks = ftorData['links'] as Map<String, dynamic>;
    final decodedStreams = decodeStreams(encodedLinks);

    return KodikContent(
      ftorData: ftorData,
      streams: decodedStreams,
      fileList: fileList,
      urlParams: urlParams,
      skipTimings: _parseSkipTimings(skipButtonStr),
      type: type,
      iframeUrl: iframeUrl,
    );
  }

  List<KodikSkipTiming> _parseSkipTimings(String? skipStr) {
    if (skipStr == null || skipStr.isEmpty) return [];
    final parts = skipStr.split(',');
    final result = <KodikSkipTiming>[];
    for (int i = 0; i < parts.length; i++) {
      final range = parts[i].trim().split('-');
      if (range.length != 2) continue;

      final start = _parseDuration(range[0]);
      final end = _parseDuration(range[1]);
      result.add(
        KodikSkipTiming(
          start: start,
          end: end,
          type: i == 0 ? 'opening' : 'ending',
        ),
      );
    }
    return result;
  }

  Duration _parseDuration(String s) {
    if (s == '0' || s == '00') return Duration.zero;
    final parts = s.split(':').map(int.parse).toList();
    if (parts.length == 1) {
      return Duration(seconds: parts[0]);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: parts[1]);
    } else if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    }
    return Duration.zero;
  }

  Future<Map<String, List<KodikStream>>> extractStreamsByEpisodeId({
    required String episodeId,
    required String episodeHash,
    required String type,
    required String iframeUrl,
    required Map<String, dynamic> urlParams,
  }) async {
    final ftorData = await fetchFtorLinks(
      iframeUrl: iframeUrl,
      type: type,
      hash: episodeHash,
      id: episodeId,
      urlParams: urlParams,
    );

    final encodedLinks = ftorData['links'] as Map<String, dynamic>;
    return decodeStreams(encodedLinks);
  }

  Future<Map<String, dynamic>> fetchFtorLinks({
    required String iframeUrl,
    required String type,
    required String hash,
    required String id,
    required Map<String, dynamic> urlParams,
  }) async {
    final ftorUrl = 'https://kodik.cc/ftor';

    // Decode parameters because they are often encoded in the script tag's JSON
    // And http.post will encode them again, leading to double encoding.
    String decode(dynamic val) {
      if (val == null) return '';
      final str = val.toString();
      try {
        return Uri.decodeComponent(str);
      } catch (_) {
        return str;
      }
    }

    final ftorPayload = {
      'd': decode(urlParams['d']),
      'd_sign': urlParams['d_sign']?.toString() ?? '',
      'pd': decode(urlParams['pd']),
      'pd_sign': urlParams['pd_sign']?.toString() ?? '',
      'ref': decode(urlParams['ref']),
      'ref_sign': urlParams['ref_sign']?.toString() ?? '',
      'bad_user': 'false',
      'cdn_is_working': 'true',
      'type': type,
      'hash': hash,
      'id': id,
      'info': '{}',
    };

    log('[Kodik] POST /ftor payload: $ftorPayload');

    final ftorResponse = await _httpService.post(
      ftorUrl,
      headers: {
        'Referer': iframeUrl,
        'Origin': 'https://kodik.cc',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: ftorPayload,
    );

    if (ftorResponse.statusCode != 200) {
      log(
        '[Kodik] /ftor Error ${ftorResponse.statusCode}: ${ftorResponse.body}',
      );
      throw Exception('Failed to fetch ftor links: ${ftorResponse.statusCode}');
    }

    return jsonDecode(ftorResponse.body);
  }

  Map<String, dynamic> _parseFileList(
    dom.Document document,
    String? type,
    String activeId,
    String activeHash,
    [String? mediaId]
  ) {
    if (type != 'serial' && type != 'seria') return {'type': 'video'};

    final Map<String, dynamic> all = {};

    // 1. Try to find all seasons and episodes in .series-options (Modern Kodik)
    final seasonContainers = document.querySelectorAll(
      '.series-options div[class^="season-"]',
    );

    if (seasonContainers.isNotEmpty) {
      log(
        '[Kodik] Found ${seasonContainers.length} seasons in .series-options',
      );
      for (final container in seasonContainers) {
        final className = container.attributes['class'] ?? '';
        final seasonNum = className.split('-').last;
        final episodes = container.querySelectorAll('option');

        final Map<String, dynamic> episodeMap = {};
        for (final ep in episodes) {
          final epNum = ep.attributes['value'] ?? '1';
          episodeMap[epNum] = {
            'id': ep.attributes['data-id'],
            'hash': ep.attributes['data-hash'],
          };
        }
        all[seasonNum] = episodeMap;
      }
    } else {
      // 2. Fallback: Parse current season from the dropdowns
      log('[Kodik] Fallback: Parsing current season from serial-series-box');
      final currentSeasonSelection = document.querySelector(
        '.serial-seasons-box select option[selected]',
      );
      final currentSeason = currentSeasonSelection?.attributes['value'] ?? '1';
      final episodes = document.querySelectorAll(
        '.serial-series-box select option',
      );

      final Map<String, dynamic> episodeMap = {};
      for (final ep in episodes) {
        final epNum = ep.attributes['value'] ?? '1';
        episodeMap[epNum] = {
          'id': ep.attributes['data-id'],
          'hash': ep.attributes['data-hash'],
        };
      }
      all[currentSeason] = episodeMap;
    }
    // 3. Parse available translations
    final translations = <Map<String, String>>[];
    final transOptions = document.querySelectorAll(
      '.serial-translations-box select option',
    );
    for (final opt in transOptions) {
      final mediaId = opt.attributes['data-media-id'];
      final mediaHash = opt.attributes['data-media-hash'];
      translations.add({
        'id': opt.attributes['value'] ?? '0',
        'title': opt.attributes['data-title'] ?? opt.text.trim(),
        'mediaId': mediaId ?? '',
        'mediaHash': mediaHash ?? '',
      });
      log(
        '[Kodik] Found translation: ${opt.text.trim()}, MediaID=$mediaId, MediaHash=$mediaHash',
      );
    }

    // 4. Robust active detection: Try to find which season/episode number matches the activeId
    String? foundSeason;
    String? foundEpisodeNum;
    all.forEach((s, episodes) {
      (episodes as Map<String, dynamic>).forEach((e, data) {
        if (data['id']?.toString() == activeId.toString()) {
          foundSeason = s;
          foundEpisodeNum = e;
        }
      });
    });

    final activeSeason =
        foundSeason ??
        document
            .querySelector('.serial-seasons-box select option[selected]')
            ?.attributes['value'] ??
        '1';
    final activeEpisode =
        foundEpisodeNum ??
        document
            .querySelector('.serial-series-box select option[selected]')
            ?.attributes['value'] ??
        '1';
    String activeTranslation =
        document
            .querySelector('.serial-translations-box select option[selected]')
            ?.attributes['value'] ??
        '0';

    // If mediaId is provided, find the translation with matching mediaId
    if (mediaId != null && mediaId.isNotEmpty) {
      for (final t in translations) {
        if (t['mediaId'] == mediaId) {
          activeTranslation = t['id']!;
          break;
        }
      }
    }

    return {
      'type': 'serial',
      'active': {
        'season': activeSeason,
        'episode_id': activeId, // Consistent with naming
        'episode_num': activeEpisode,
        'translation': activeTranslation,
      },
      'all': all,
      'translations': translations,
    };
  }

  Future<KodikContent> getStreamsForTranslationAndEpisode({
    required String iframeUrl,
    required String mediaId,
    required String mediaHash,
    required String episodeId,
    required String episodeHash,
    required Map<String, dynamic> urlParams,
  }) async {
    log('[Kodik] getStreamsForTranslationAndEpisode: mediaId=$mediaId, episodeId=$episodeId');

    // Строим iframe URL с новой озвучкой и серией
    final uri = Uri.parse(iframeUrl);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams['media_id'] = mediaId;
    newParams['media_hash'] = mediaHash;
    newParams['episode'] = episodeId; // Используем episodeId как параметр

    final newIframeUrl = uri.replace(queryParameters: newParams).toString();
    log('[Kodik] Built iframe URL for translation+episode: $newIframeUrl');

    return extractContentFromIframe(newIframeUrl);
  }

  Future<KodikContent> getStreamsForEpisode({
    required String iframeUrl,
    required String episodeId,
    required String episodeHash,
    required String mediaId,
    required String mediaHash,
    required Map<String, dynamic> urlParams,
  }) async {
    log('[Kodik] getStreamsForEpisode: episodeId=$episodeId, mediaId=$mediaId');

    // Аналогично, но для переключения серии в текущей озвучке
    final uri = Uri.parse(iframeUrl);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams['media_id'] = mediaId;
    newParams['media_hash'] = mediaHash;
    newParams['episode'] = episodeId;

    final newIframeUrl = uri.replace(queryParameters: newParams).toString();
    log('[Kodik] Built iframe URL for episode: $newIframeUrl');

    return extractContentFromIframe(newIframeUrl);
  }

  Map<String, List<KodikStream>> decodeStreams(
    Map<String, dynamic> encodedLinks,
  ) {
    final decodedStreams = <String, List<KodikStream>>{};
    for (final quality in encodedLinks.keys) {
      final variants = encodedLinks[quality] as List<dynamic>;
      decodedStreams[quality] = variants.map((v) {
        final src = v['src'] as String;
        final type = v['type'] as String;
        return KodikStream(url: _decodeLink(src), type: type);
      }).toList();
    }
    return decodedStreams;
  }

  static int _cachedShift = 8;

  String _decodeLink(String encoded) {
    if (encoded.isEmpty) return encoded;

    // Try cached shift first
    final cachedResult = _tryShift(encoded, _cachedShift);
    if (cachedResult != null) return cachedResult;

    // Fallback: try all shifts 1-25 (standard Caesar)
    for (int shift = 1; shift <= 25; shift++) {
      if (shift == _cachedShift) continue;
      final result = _tryShift(encoded, shift);
      if (result != null) {
        _cachedShift = shift;
        log('[Kodik] New shift found and cached: $shift', name: 'Kodik');
        return result;
      }
    }

    log(
      '[Kodik] CRITICAL: Failed to decode link with alphabetic Caesar: ${encoded.substring(0, encoded.length > 30 ? 30 : encoded.length)}...',
      name: 'Kodik',
    );
    return encoded;
  }

  String? _tryShift(String encoded, int shift) {
    final sb = StringBuffer();
    for (int i = 0; i < encoded.length; i++) {
      int c = encoded.codeUnitAt(i);
      // Alphabetic only Caesar Shift (Left Shift)
      if (c >= 65 && c <= 90) {
        // A-Z
        sb.write(String.fromCharCode(((c - 65 + 26 - shift) % 26) + 65));
      } else if (c >= 97 && c <= 122) {
        // a-z
        sb.write(String.fromCharCode(((c - 97 + 26 - shift) % 26) + 97));
      } else {
        sb.write(String.fromCharCode(c));
      }
    }

    String shifted = sb.toString();

    // Add Base64 padding if necessary
    final padding = (4 - (shifted.length % 4)) % 4;
    if (padding > 0) {
      shifted += "=" * padding;
    }

    try {
      final bytes = base64.decode(shifted);
      final decoded = utf8.decode(bytes, allowMalformed: true);
      // Valid Kodik link usually starts with // or http and contains .m3u8 or similar extensions
      if ((decoded.contains('http') || decoded.startsWith('//')) &&
          (decoded.contains('.m3u8') ||
              decoded.contains('.mp4') ||
              decoded.contains('.m3u'))) {
        return decoded;
      }
    } catch (_) {
      // Not valid Base64 or UTF-8
    }

    return null;
  }
}
