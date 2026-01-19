enum PlayerStatus { notInitialized, loading, ready, playing, paused, error }

class PlayerState {
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final String? currentQuality;
  final String? errorMessage;
  final bool isInitialized;
  final bool isFullScreen;

  const PlayerState({
    required this.status,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentQuality,
    this.errorMessage,
    this.isInitialized = false,
    this.isFullScreen = false,
  });

  factory PlayerState.initial() => const PlayerState(
    status: PlayerStatus.notInitialized,
    isInitialized: false,
  );

  PlayerState copyWith({
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    String? currentQuality,
    String? errorMessage,
    bool? isInitialized,
    bool? isFullScreen,
  }) => PlayerState(
    status: status ?? this.status,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    currentQuality: currentQuality ?? this.currentQuality,
    errorMessage: errorMessage ?? this.errorMessage,
    isInitialized: isInitialized ?? this.isInitialized,
    isFullScreen: isFullScreen ?? this.isFullScreen,
  );

  bool get isPlaying => status == PlayerStatus.playing;
  bool get isReady => status == PlayerStatus.ready || isPlaying || status == PlayerStatus.paused;
  bool get canPlay => isReady || isInitialized;
  bool get hasError => status == PlayerStatus.error;

  @override
  String toString() {
    return 'PlayerState(status: $status, position: $position, duration: $duration, quality: $currentQuality, initialized: $isInitialized, fullScreen: $isFullScreen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerState &&
           other.status == status &&
           other.position == position &&
           other.duration == duration &&
           other.currentQuality == currentQuality &&
           other.errorMessage == errorMessage &&
           other.isInitialized == isInitialized &&
           other.isFullScreen == isFullScreen;
  }

  @override
  int get hashCode {
    return status.hashCode ^
           position.hashCode ^
           duration.hashCode ^
           currentQuality.hashCode ^
           errorMessage.hashCode ^
           isInitialized.hashCode ^
           isFullScreen.hashCode;
  }
}
