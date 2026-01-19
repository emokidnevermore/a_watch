import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'video_player_shimmer.dart';
import 'fullscreen_player_page.dart';

import 'package:a_watch/data/extractor/kodik_extractor.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_bloc.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_event.dart';
import 'package:a_watch/features/player/presentation/bloc/video_player_state.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Map<String, String> qualities;
  final Function(String) onQualityChanged;
  final List<KodikSkipTiming> skipTimings;
  final VoidCallback? onNext;
  final String translationId;

  const VideoPlayerWidget({
    super.key,
    required this.qualities,
    required this.onQualityChanged,
    this.skipTimings = const [],
    this.onNext,
    required this.translationId,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  KodikSkipTiming? _currentSkipTiming;
  bool _showNextButton = false;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    log('[VideoPlayerWidget] initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<VideoPlayerBloc>();

    // Set up position listener for skip timings
    _positionSubscription?.cancel();
    _positionSubscription = bloc.player.stream.position.listen((pos) {
      final duration = bloc.player.state.duration;

      KodikSkipTiming? activeSkip;
      for (final skip in widget.skipTimings) {
        if (pos >= skip.start && pos <= skip.end) {
          activeSkip = skip;
          break;
        }
      }

      final showNext =
          widget.onNext != null &&
          duration != Duration.zero &&
          (duration - pos).inSeconds < 120;

      if (activeSkip != _currentSkipTiming || showNext != _showNextButton) {
        if (mounted) {
          setState(() {
            _currentSkipTiming = activeSkip;
            _showNextButton = showNext;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        log('[VideoPlayerWidget] Build called, state: ${state.runtimeType}');
        final bloc = context.read<VideoPlayerBloc>();

      // Show shimmer while loading or not initialized
      if (state is VideoPlayerInitial ||
          state is VideoPlayerLoading ||
          (state is VideoPlayerReady && !(state.playerState.isInitialized))) {
        return const VideoPlayerShimmer();
      }

        // Show error state
        if (state is VideoPlayerError) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка воспроизведения',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.space) {
                // Toggle between play and pause based on current state
                if (state is VideoPlayerPlaying) {
                  bloc.add(const Pause());
                } else {
                  bloc.add(const Play());
                }
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                bloc.add(Seek(bloc.player.state.position + const Duration(seconds: 10)));
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                bloc.add(Seek(bloc.player.state.position - const Duration(seconds: 10)));
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Video(
                    controller: VideoController(bloc.player),
                    controls: NoVideoControls,
                  ),
                  // Custom Controls Overlay
                  _buildCustomControls(context, bloc, state),
                  // Custom Overlays
                  if (_currentSkipTiming != null)
                    Positioned(
                      bottom: 120,
                      left: 20,
                      child: _buildGlassButton(
                        onPressed: () => bloc.add(Seek(_currentSkipTiming!.end)),
                        label: 'Пропустить ${_currentSkipTiming!.type == 'opening' ? 'опенинг' : 'эндинг'}',
                        icon: Icons.skip_next,
                      ),
                    ),
                  if (_showNextButton)
                    Positioned(
                      bottom: 120,
                      right: 20,
                      child: _buildGlassButton(
                        onPressed: widget.onNext!,
                        label: 'Следующая серия',
                        icon: Icons.fast_forward,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomControls(BuildContext context, VideoPlayerBloc bloc, VideoPlayerState state) {
    final playerState = (state is VideoPlayerReady) ? state.playerState :
                       (state is VideoPlayerPlaying) ? state.playerState :
                       (state is VideoPlayerPaused) ? state.playerState : null;

    if (playerState == null) return const SizedBox.shrink();

    return StreamBuilder(
      stream: bloc.player.stream.position,
      builder: (context, snapshot) {
        final position = bloc.player.state.position;
        final duration = bloc.player.state.duration;
        final primaryColor = Theme.of(context).primaryColor;

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seek Bar
                SliderTheme(
                  data: SliderThemeData(
                    thumbColor: primaryColor,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    overlayColor: primaryColor.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      bloc.add(Seek(Duration(seconds: value.toInt())));
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Controls Row
                Row(
                  children: [
                    // Play/Pause
                    IconButton(
                      onPressed: () {
                        // Since player is already initialized, just toggle play/pause
                        if (state is VideoPlayerPlaying) {
                          bloc.add(const Pause());
                        } else {
                          bloc.add(const Play());
                        }
                      },
                      icon: StreamBuilder(
                        stream: bloc.player.stream.playing,
                        builder: (context, snapshot) {
                          final playing = bloc.player.state.playing;
                          return Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    ),
                    // Position Indicator
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    // Quality Button
                    IconButton(
                      onPressed: () => _showQualityDialog(context, bloc),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                    // Full Screen Button
                    IconButton(
                      onPressed: () async {
                        // Enter full screen mode
                        bloc.add(const ToggleFullScreen());
                        // Push full screen page with fade transition
                        await Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => BlocProvider.value(
                              value: bloc,
                              child: FullscreenPlayerPage(
                                qualities: widget.qualities,
                                onQualityChanged: widget.onQualityChanged,
                                skipTimings: widget.skipTimings,
                                onNext: widget.onNext,
                                translationId: widget.translationId,
                              ),
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 200),
                            reverseTransitionDuration: const Duration(milliseconds: 200),
                          ),
                        );
                        // Exit full screen mode when returning
                        bloc.add(const ToggleFullScreen());
                      },
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQualityDialog(BuildContext context, VideoPlayerBloc bloc) {
    final currentState = context.read<VideoPlayerBloc>().state;
    final currentQuality = (currentState is VideoPlayerReady) ? currentState.playerState.currentQuality :
                          (currentState is VideoPlayerPlaying) ? currentState.playerState.currentQuality :
                          (currentState is VideoPlayerPaused) ? currentState.playerState.currentQuality : null;

    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Качество видео',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.qualities.entries.map((e) {
              return ListTile(
                title: Text(
                  '${e.key}p',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: currentQuality == e.key
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  widget.onQualityChanged(e.key);
                },
              );
            }).toList(),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Качество видео',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...widget.qualities.entries.map(
              (e) => ListTile(
                title: Text(
                  '${e.key}p',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: currentQuality == e.key
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  widget.onQualityChanged(e.key);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      final hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }




}
