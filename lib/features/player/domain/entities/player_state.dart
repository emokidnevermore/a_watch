class PlayerState {
  final String currentUrl;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  // ... other player state fields

  const PlayerState({
    required this.currentUrl,
    required this.isPlaying,
    required this.position,
    required this.duration,
  });
}
