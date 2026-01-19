import 'package:equatable/equatable.dart';

abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PreparePlayer extends VideoPlayerEvent {
  final String videoUrl;
  final Map<String, String>? headers;
  final Map<String, String> qualities;
  final String? initialQuality;

  const PreparePlayer({
    required this.videoUrl,
    this.headers,
    required this.qualities,
    this.initialQuality,
  });

  @override
  List<Object?> get props => [videoUrl, headers, qualities, initialQuality];
}

class InitializePlayer extends VideoPlayerEvent {
  final String videoUrl;
  final Map<String, String>? headers;
  final Map<String, String> qualities;
  final String? initialQuality;

  const InitializePlayer({
    required this.videoUrl,
    this.headers,
    required this.qualities,
    this.initialQuality,
  });

  @override
  List<Object?> get props => [videoUrl, headers, qualities, initialQuality];
}

class Play extends VideoPlayerEvent {
  const Play();
}

class Pause extends VideoPlayerEvent {
  const Pause();
}

class Seek extends VideoPlayerEvent {
  final Duration position;

  const Seek(this.position);

  @override
  List<Object?> get props => [position];
}

class SwitchEpisode extends VideoPlayerEvent {
  final String newVideoUrl;
  final Map<String, String>? headers;
  final Map<String, String> qualities;
  final String? quality;
  final bool shouldAutoPlay;

  const SwitchEpisode({
    required this.newVideoUrl,
    this.headers,
    required this.qualities,
    this.quality,
    this.shouldAutoPlay = false,
  });

  @override
  List<Object?> get props => [newVideoUrl, headers, qualities, quality, shouldAutoPlay];
}

class ChangeQuality extends VideoPlayerEvent {
  final String quality;

  const ChangeQuality(this.quality);

  @override
  List<Object?> get props => [quality];
}

class UpdatePosition extends VideoPlayerEvent {
  final Duration position;
  final Duration duration;

  const UpdatePosition(this.position, this.duration);

  @override
  List<Object?> get props => [position, duration];
}

class UpdatePlayingState extends VideoPlayerEvent {
  final bool isPlaying;

  const UpdatePlayingState(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

class PlayerError extends VideoPlayerEvent {
  final String error;

  const PlayerError(this.error);

  @override
  List<Object?> get props => [error];
}

class DisposePlayer extends VideoPlayerEvent {
  const DisposePlayer();
}

class ToggleFullScreen extends VideoPlayerEvent {
  const ToggleFullScreen();
}
