import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/domain/entities/viewing_state.dart';

class ViewingStateService {
  ViewingState? _currentState;

  void initializeFromKodikContent(KodikContent content, String animeId) {
    _currentState = ViewingState.fromKodikContent(content, animeId);
  }

  void updateTranslation(String mediaId, String mediaHash, String translationId) {
    if (_currentState == null) return;
    _currentState = _currentState!.copyWith(
      currentTranslationId: translationId,
      currentMediaId: mediaId,
      currentMediaHash: mediaHash,
    );
  }

  void updateEpisode(String season, String episode) {
    if (_currentState == null) return;
    _currentState = _currentState!.copyWith(
      currentSeason: season,
      currentEpisode: episode,
    );
  }

  ViewingState? getCurrentState() => _currentState;
  bool hasStateChanged() => _currentState != null;
  void reset() => _currentState = null;
}
