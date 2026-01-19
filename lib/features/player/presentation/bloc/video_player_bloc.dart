import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:window_manager/window_manager.dart';
import 'package:a_watch/domain/entities/player_state.dart';
import 'package:a_watch/presentation/bloc/base_bloc.dart';
import 'video_player_event.dart';
import 'video_player_state.dart';
import 'package:a_watch/core/logger/logger.dart';

class VideoPlayerBloc extends BaseBloc<VideoPlayerEvent, VideoPlayerState> {
  Player? _player;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  // Store prepared player data
  String? _preparedVideoUrl;
  Map<String, String>? _preparedHeaders;
  String? _preparedInitialQuality;

  VideoPlayerBloc(ILogger logger) : super(logger, const VideoPlayerInitial()) {
    on<PreparePlayer>(_onPreparePlayer);
    on<InitializePlayer>(_onInitializePlayer);
    on<Play>(_onPlay);
    on<Pause>(_onPause);
    on<Seek>(_onSeek);
    on<SwitchEpisode>(_onSwitchEpisode);
    on<ChangeQuality>(_onChangeQuality);
    on<UpdatePlayingState>(_onUpdatePlayingState);
    on<PlayerError>(_onPlayerError);
    on<DisposePlayer>(_onDisposePlayer);
    on<ToggleFullScreen>(_onToggleFullScreen);
  }

  Player get player {
    _player ??= Player();
    return _player!;
  }

  Future<void> _onPreparePlayer(
    PreparePlayer event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    // Store prepared data for later use
    _preparedVideoUrl = event.videoUrl;
    _preparedHeaders = event.headers;
    _preparedInitialQuality = event.initialQuality;

    // Automatically initialize the player immediately
    await _onInitializePlayer(
      InitializePlayer(
        videoUrl: '', // Use stored data
        headers: {},
        qualities: {},
        initialQuality: null,
      ),
      emit,
    );
  }

  Future<void> _onInitializePlayer(
    InitializePlayer event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    try {
      emit(const VideoPlayerLoading(null));

      // Use stored data if event parameters are empty
      final videoUrl = event.videoUrl.isNotEmpty ? event.videoUrl : _preparedVideoUrl!;
      final headers = event.headers?.isNotEmpty == true ? event.headers : _preparedHeaders;
      final initialQuality = event.initialQuality ?? _preparedInitialQuality;

      // Initialize media without playing - this sets up the player but doesn't load video yet
      // Headers are passed to the Media constructor
      await player.open(
        Media(videoUrl, httpHeaders: headers),
        play: false,
      );

      // Set up stream subscriptions
      _setupStreamSubscriptions(emit);

      // Create initial player state - player is ready but not initialized with video
      final playerState = PlayerState(
        status: PlayerStatus.ready,
        currentQuality: initialQuality,
        isInitialized: true, // Player is set up, ready for playback
      );

      emit(VideoPlayerReady(playerState));
    } catch (e, stackTrace) {
      logger.logError('Failed to initialize player', null, e, stackTrace);
      emit(VideoPlayerError(e.toString(), null));
    }
  }

  Future<void> _onPlay(
    Play event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    try {
      await player.play();

      final currentState = state;
      if (currentState is VideoPlayerReady) {
        final updatedPlayerState = currentState.playerState.copyWith(
          status: PlayerStatus.playing,
        );
        emit(VideoPlayerPlaying(updatedPlayerState));
      } else if (currentState is VideoPlayerPaused) {
        final updatedPlayerState = currentState.playerState.copyWith(
          status: PlayerStatus.playing,
        );
        emit(VideoPlayerPlaying(updatedPlayerState));
      }
    } catch (e, stackTrace) {
      logger.logError('Failed to play', null, e, stackTrace);
      emit(VideoPlayerError(e.toString(), _getCurrentPlayerState()));
    }
  }

  Future<void> _onPause(
    Pause event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    try {
      await player.pause();

      final currentState = state;
      if (currentState is VideoPlayerPlaying) {
        final updatedPlayerState = currentState.playerState.copyWith(
          status: PlayerStatus.paused,
        );
        emit(VideoPlayerPaused(updatedPlayerState));
      }
    } catch (e, stackTrace) {
      logger.logError('Failed to pause', null, e, stackTrace);
      emit(VideoPlayerError(e.toString(), _getCurrentPlayerState()));
    }
  }

  Future<void> _onSeek(
    Seek event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    try {
      await player.seek(event.position);
    } catch (e, stackTrace) {
      logger.logError('Failed to seek', null, e, stackTrace);
    }
  }

  Future<void> _onSwitchEpisode(
    SwitchEpisode event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    try {
      final previousState = _getCurrentPlayerState();
      emit(VideoPlayerLoading(previousState));

      // Determine if should autoplay based on previous state and event
      final shouldPlay = event.shouldAutoPlay ||
          (previousState?.isPlaying == true);

      // Headers are passed to the Media constructor
      await player.open(
        Media(event.newVideoUrl, httpHeaders: event.headers),
        play: shouldPlay,
      );

      // Create new player state
      final playerState = PlayerState(
        status: shouldPlay ? PlayerStatus.playing : PlayerStatus.ready,
        currentQuality: event.quality ?? previousState?.currentQuality,
        isInitialized: true,
      );

      if (shouldPlay) {
        emit(VideoPlayerPlaying(playerState));
      } else {
        emit(VideoPlayerReady(playerState));
      }
    } catch (e, stackTrace) {
      logger.logError('Failed to switch episode', null, e, stackTrace);
      emit(VideoPlayerError(e.toString(), _getCurrentPlayerState()));
    }
  }

  Future<void> _onChangeQuality(
    ChangeQuality event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    // Quality change will be handled by the widget through episode switch
    // This event is for future use or external quality changes
  }



  void _onUpdatePlayingState(
    UpdatePlayingState event,
    Emitter<VideoPlayerState> emit,
  ) {
    logEvent(event);
    logger.logDebug('[VideoPlayerBloc] UpdatePlayingState: ${event.isPlaying}, current state: ${state.runtimeType}');

    // Only update if we have a valid player state
    final playerState = _getCurrentPlayerState();
    if (playerState != null) {
      if (event.isPlaying) {
        final newState = VideoPlayerPlaying(playerState.copyWith(status: PlayerStatus.playing));
        logger.logDebug('[VideoPlayerBloc] Emitting VideoPlayerPlaying');
        emit(newState);
      } else {
        final newState = VideoPlayerPaused(playerState.copyWith(status: PlayerStatus.paused));
        logger.logDebug('[VideoPlayerBloc] Emitting VideoPlayerPaused');
        emit(newState);
      }
    } else {
      logger.logDebug('[VideoPlayerBloc] No player state available, skipping update');
    }
  }

  void _onPlayerError(
    PlayerError event,
    Emitter<VideoPlayerState> emit,
  ) {
    logEvent(event);
    final previousState = _getCurrentPlayerState();
    emit(VideoPlayerError(event.error, previousState));
  }

  Future<void> _onDisposePlayer(
    DisposePlayer event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    await _cleanup();
  }

  Future<void> _onToggleFullScreen(
    ToggleFullScreen event,
    Emitter<VideoPlayerState> emit,
  ) async {
    logEvent(event);
    try {
      final currentPlayerState = _getCurrentPlayerState();
      if (currentPlayerState == null) return;

      final isCurrentlyFullScreen = currentPlayerState.isFullScreen;

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: toggle orientation and UI mode
        if (isCurrentlyFullScreen) {
          // Exit full screen
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        } else {
          // Enter full screen
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Desktop: toggle window full screen
        await windowManager.setFullScreen(!isCurrentlyFullScreen);
      }

      // Update state - the actual navigation is handled in the widget
      final updatedPlayerState = currentPlayerState.copyWith(
        isFullScreen: !isCurrentlyFullScreen,
      );

      final currentState = state;
      if (currentState is VideoPlayerReady) {
        emit(VideoPlayerReady(updatedPlayerState));
      } else if (currentState is VideoPlayerPlaying) {
        emit(VideoPlayerPlaying(updatedPlayerState));
      } else if (currentState is VideoPlayerPaused) {
        emit(VideoPlayerPaused(updatedPlayerState));
      }
    } catch (e, stackTrace) {
      logger.logError('Failed to toggle full screen', null, e, stackTrace);
    }
  }

  void _setupStreamSubscriptions(Emitter<VideoPlayerState> emit) {
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    _durationSubscription?.cancel();

    _playingSubscription = player.stream.playing.listen((isPlaying) {
      logger.logDebug('[VideoPlayerBloc] Playing stream fired: $isPlaying');
      // Use add() to dispatch events instead of emit() directly
      add(UpdatePlayingState(isPlaying));
    });
  }

  PlayerState? _getCurrentPlayerState() {
    final currentState = state;
    if (currentState is VideoPlayerReady) return currentState.playerState;
    if (currentState is VideoPlayerPlaying) return currentState.playerState;
    if (currentState is VideoPlayerPaused) return currentState.playerState;
    return null;
  }

  Future<void> _cleanup() async {
    await _positionSubscription?.cancel();
    await _playingSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _player?.dispose();
    _player = null;
  }

  @override
  Future<void> close() async {
    await _cleanup();
    return super.close();
  }
}
