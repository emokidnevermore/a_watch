import 'package:equatable/equatable.dart';
import 'package:a_watch/domain/entities/player_state.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object?> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial();
}

class VideoPlayerLoading extends VideoPlayerState {
  final PlayerState? previousState;

  const VideoPlayerLoading(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class VideoPlayerReady extends VideoPlayerState {
  final PlayerState playerState;

  const VideoPlayerReady(this.playerState);

  @override
  List<Object?> get props => [playerState];
}

class VideoPlayerPlaying extends VideoPlayerState {
  final PlayerState playerState;

  const VideoPlayerPlaying(this.playerState);

  @override
  List<Object?> get props => [playerState];
}

class VideoPlayerPaused extends VideoPlayerState {
  final PlayerState playerState;

  const VideoPlayerPaused(this.playerState);

  @override
  List<Object?> get props => [playerState];
}

class VideoPlayerError extends VideoPlayerState {
  final String error;
  final PlayerState? previousState;

  const VideoPlayerError(this.error, this.previousState);

  @override
  List<Object?> get props => [error, previousState];
}
