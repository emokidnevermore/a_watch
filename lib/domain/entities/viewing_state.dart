import 'package:a_watch/data/extractor/kodik_extractor.dart';

class ViewingState {
  final String animeId;
  final String currentSeason;
  final String currentEpisode;
  final String currentTranslationId;
  final String currentMediaId;
  final String currentMediaHash;
  final DateTime lastUpdated;

  const ViewingState({
    required this.animeId,
    required this.currentSeason,
    required this.currentEpisode,
    required this.currentTranslationId,
    required this.currentMediaId,
    required this.currentMediaHash,
    required this.lastUpdated,
  });

  factory ViewingState.initial(String animeId) => ViewingState(
    animeId: animeId,
    currentSeason: '1',
    currentEpisode: '1',
    currentTranslationId: '0',
    currentMediaId: '',
    currentMediaHash: '',
    lastUpdated: DateTime.now(),
  );

  factory ViewingState.fromKodikContent(KodikContent content, String animeId) {
    final active = content.fileList['active'] as Map<String, dynamic>?;
    final translations = content.fileList['translations'] as List?;
    final translationId = active?['translation'] ?? '0';

    // Найдем mediaId и mediaHash для активной озвучки
    String mediaId = '';
    String mediaHash = '';
    if (translations != null && translationId != '0') {
      for (final t in translations) {
        if (t['id'].toString() == translationId) {
          mediaId = t['mediaId'] ?? '';
          mediaHash = t['mediaHash'] ?? '';
          break;
        }
      }
    }

    return ViewingState(
      animeId: animeId,
      currentSeason: active?['season'] ?? '1',
      currentEpisode: active?['episode_num'] ?? active?['episode'] ?? '1',
      currentTranslationId: translationId,
      currentMediaId: mediaId,
      currentMediaHash: mediaHash,
      lastUpdated: DateTime.now(),
    );
  }

  ViewingState copyWith({
    String? currentSeason,
    String? currentEpisode,
    String? currentTranslationId,
    String? currentMediaId,
    String? currentMediaHash,
  }) => ViewingState(
    animeId: animeId,
    currentSeason: currentSeason ?? this.currentSeason,
    currentEpisode: currentEpisode ?? this.currentEpisode,
    currentTranslationId: currentTranslationId ?? this.currentTranslationId,
    currentMediaId: currentMediaId ?? this.currentMediaId,
    currentMediaHash: currentMediaHash ?? this.currentMediaHash,
    lastUpdated: DateTime.now(),
  );

  bool hasChanged(ViewingState other) =>
    currentSeason != other.currentSeason ||
    currentEpisode != other.currentEpisode ||
    currentTranslationId != other.currentTranslationId ||
    currentMediaId != other.currentMediaId;

  @override
  String toString() {
    return 'ViewingState(animeId: $animeId, season: $currentSeason, episode: $currentEpisode, translation: $currentTranslationId, mediaId: $currentMediaId)';
  }
}
