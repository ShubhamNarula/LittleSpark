import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../data/models/rhyme_model.dart';
import '../../../services/tts_service.dart';
import '../rhymes_controller.dart';

class RhymePlayerScreen extends StatefulWidget {
  const RhymePlayerScreen({Key? key}) : super(key: key);

  @override
  State<RhymePlayerScreen> createState() => _RhymePlayerScreenState();
}

class _RhymePlayerScreenState extends State<RhymePlayerScreen> with SingleTickerProviderStateMixin {
  final RhymesController controller = Get.find<RhymesController>();
  late AnimationController _rotationController;
  late Worker _isPlayingWorker;
  RhymeModel? _initialRhyme;
  YoutubePlayerController? _ytController;
  StreamSubscription? _videoStateSubscription;
  StreamSubscription? _videoPositionSubscription;

  // Track position and duration reactively
  final Rx<Duration> _position = Duration.zero.obs;
  final Rx<Duration> _duration = Duration.zero.obs;

  @override
  void initState() {
    super.initState();
    final rhyme = controller.playingRhyme.value;
    final videoId = controller.playingVideoId.value;
    _initialRhyme = rhyme;
    
    // Set up rotation animation for the music disc
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Sync play/pause status to rotation animation
    _isPlayingWorker = ever(controller.isPlaying, (bool playing) {
      if (playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    // Initialize play state to false initially
    controller.isPlaying.value = false;

    if (rhyme != null && videoId.isNotEmpty) {
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: false,
          mute: false,
          origin: 'https://littlespark.app',
        ),
      );
      
      // Subscribe to stream for player state changes (playing, paused, ended) and errors
      _videoStateSubscription = _ytController?.stream.listen((value) {
        if (!mounted) return;
        
        final playerState = value.playerState;
        final ytPlaying = playerState == PlayerState.playing;
        
        debugPrint("[YOUTUBE PLAYER] stream event: state=$playerState, hasError=${value.hasError}, error=${value.error}");

        // Sync playing status to GetX
        if (controller.isPlaying.value != ytPlaying) {
          controller.isPlaying.value = ytPlaying;
        }

        // Sync duration to GetX if it's available
        final dur = value.metaData.duration;
        if (dur != Duration.zero && _duration.value != dur) {
          _duration.value = dur;
        }

        // Handle video error — try the next available video ID
        if (playerState == PlayerState.unknown && value.hasError) {
          debugPrint("[YOUTUBE PLAYER] Error encountered: ${value.error}. Cycling to fallback video.");
          _tryFallbackVideo();
          return;
        }

        // Handle video completion
        if (playerState == PlayerState.ended) {
          if (controller.isLooping.value) {
            _position.value = Duration.zero;
            controller.isPlaying.value = true;
            Future.microtask(() async {
              await _ytController?.seekTo(seconds: 0.0);
              await _ytController?.playVideo();
            });
          } else {
            controller.completeRhyme();
          }
        }
      }, onError: (_) {
        _tryFallbackVideo();
      });

      // Subscribe to videoStateStream to track actual video progress/position
      _videoPositionSubscription = _ytController?.videoStateStream.listen((state) {
        if (!mounted) return;
        _position.value = state.position;

        // Fallback completion check for Web/iframe limitations
        final posSec = state.position.inSeconds;
        final durSec = _duration.value.inSeconds;
        if (durSec > 0 && posSec >= durSec && controller.isPlaying.value) {
          debugPrint("[YOUTUBE PLAYER] Position reached end. Triggering completion fallback.");
          if (controller.isLooping.value) {
            _position.value = Duration.zero;
            Future.microtask(() async {
              await _ytController?.seekTo(seconds: 0.0);
              await _ytController?.playVideo();
            });
          } else {
            controller.completeRhyme();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _isPlayingWorker.dispose();
    _videoStateSubscription?.cancel();
    _videoPositionSubscription?.cancel();
    _ytController?.close();
    super.dispose();
  }

  void _tryFallbackVideo() {
    if (!mounted) return;
    // Tell controller to cycle to next video ID
    controller.tryNextVideo();
    // Re-init the YT controller with the new ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _videoStateSubscription?.cancel();
      _videoPositionSubscription?.cancel();
      _ytController?.close();

      final newVideoId = controller.playingVideoId.value;
      if (newVideoId.isNotEmpty && !controller.isVideoError.value) {
        setState(() {
          _ytController = YoutubePlayerController.fromVideoId(
            videoId: newVideoId,
            autoPlay: true,
            params: const YoutubePlayerParams(
              showControls: true,
              showFullscreenButton: false,
              mute: false,
              origin: 'https://littlespark.app',
            ),
          );
        });
        _resubscribeYtStreams();
      } else {
        setState(() {
          _ytController = null;
        });
      }
    });
  }

  void _resubscribeYtStreams() {
    _videoStateSubscription = _ytController?.stream.listen((value) {
      if (!mounted) return;
      final playerState = value.playerState;
      final ytPlaying = playerState == PlayerState.playing;
      
      debugPrint("[YOUTUBE PLAYER] resubscribed stream event: state=$playerState, hasError=${value.hasError}, error=${value.error}");

      if (controller.isPlaying.value != ytPlaying) {
        controller.isPlaying.value = ytPlaying;
      }
      
      final dur = value.metaData.duration;
      if (dur != Duration.zero && _duration.value != dur) {
        _duration.value = dur;
      }

      if (playerState == PlayerState.ended) {
        if (controller.isLooping.value) {
          _position.value = Duration.zero;
          controller.isPlaying.value = true;
          Future.microtask(() async {
            await _ytController?.seekTo(seconds: 0.0);
            await _ytController?.playVideo();
          });
        } else {
          controller.completeRhyme();
        }
      }
      if (playerState == PlayerState.unknown && value.hasError) {
        debugPrint("[YOUTUBE PLAYER] Resubscribed error encountered: ${value.error}. Cycling to fallback video.");
        _tryFallbackVideo();
      }
    }, onError: (_) => _tryFallbackVideo());

    _videoPositionSubscription = _ytController?.videoStateStream.listen((state) {
      if (!mounted) return;
      _position.value = state.position;

      // Fallback completion check for Web/iframe limitations
      final posSec = state.position.inSeconds;
      final durSec = _duration.value.inSeconds;
      if (durSec > 0 && posSec >= durSec && controller.isPlaying.value) {
        debugPrint("[YOUTUBE PLAYER] Position reached end. Triggering completion fallback.");
        if (controller.isLooping.value) {
          _position.value = Duration.zero;
          Future.microtask(() async {
            await _ytController?.seekTo(seconds: 0.0);
            await _ytController?.playVideo();
          });
        } else {
          controller.completeRhyme();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rhyme = _initialRhyme;
    if (rhyme == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _ytController?.pauseVideo();
        controller.stopAndClosePlayer();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(
          children: [
            // Background Gradient Blends
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bgDark,
                      AppColors.bgMid,
                      const Color(0xFF2E1A47).withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Floating musical note animations in background
            ...List.generate(5, (i) {
              final isMusicNote = i % 2 == 0;
              final symbol = isMusicNote ? "🎵" : "✨";
              return Positioned(
                left: 40.0 + (i * 70.0),
                bottom: 120.0 + (i * 30.0),
                child: Text(
                  symbol,
                  style: TextStyle(fontSize: 24.0, color: Colors.white.withOpacity(0.12)),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .moveY(begin: 120.0, end: -280.0, duration: Duration(seconds: 5 + i), curve: Curves.linear)
                    .fadeOut(duration: Duration(seconds: 5 + i)),
              );
            }),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                  // Top Custom Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticUtil.light();
                            _ytController?.pauseVideo();
                            controller.stopAndClosePlayer();
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22.0),
                        ),
                        Expanded(
                          child: Text(
                            rhyme.title,
                            style: AppTextStyles.bodyLargeBold.copyWith(
                              fontFamily: 'FredokaOne',
                              fontSize: 18.0,
                              color: AppColors.gold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 48.0), // Spacer balancing leading back button
                      ],
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  // Premium YouTube Video Player Container (With Custom Masking)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 480.0),
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.15),
                          blurRadius: 16.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: _ytController != null
                        ? AspectRatio(
                            aspectRatio: 16 / 9,
                            child: YoutubePlayer(
                              controller: _ytController!,
                              builder: (context, player, controller) {
                                return Stack(
                                  children: [
                                    player,
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: CustomPaint(
                                          painter: RoundedCardMaskPainter(
                                            backgroundColor: AppColors.bgDark,
                                            borderColor: AppColors.gold.withOpacity(0.4),
                                            borderWidth: 3.0,
                                            borderRadius: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        : Obx(() {
                          if (controller.isVideoError.value) {
                            // All video IDs exhausted — show friendly fallback
                            return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.bgMid,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🎵', style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Video unavailable',
                                      style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        TtsService.to.speak(rhyme.title);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          '🔊 Listen with Voice',
                                          style: AppTextStyles.bodySmallBold.copyWith(color: AppColors.gold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                              ),
                            ),
                          );
                        }),
                  ),

                  const SizedBox(height: 24.0),

                  // Premium Rotating Music Disc (Replaces Lyrics)
                  _buildMusicDisc(),

                  const SizedBox(height: 16.0),

                  // Interactive Custom Progress Bar
                  _buildProgressBar(),

                  const SizedBox(height: 20.0),

                  // Playback Controls Row
                  _buildControls(),

                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  // Rotating Music Disc Visualizer
  Widget _buildMusicDisc() {
    return Obx(() {
      final playing = controller.isPlaying.value;
      final emoji = _initialRhyme?.emoji ?? "🎵";
      
      return Center(
        child: RotationTransition(
          turns: _rotationController,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF191124),
              border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 4.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(playing ? 0.25 : 0.08),
                  blurRadius: playing ? 28.0 : 12.0,
                  spreadRadius: playing ? 4.0 : 1.0,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grooves of the vinyl record
                ...List.generate(3, (index) {
                  return Container(
                    width: 150.0 - (index * 35.0),
                    height: 150.0 - (index * 35.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
                // Center colorful label
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.lavender, AppColors.coral],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 34.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Video Time Progress Indicator
  Widget _buildProgressBar() {
    return Obx(() {
      final pos = _position.value;
      final dur = _duration.value;
      
      final posSecs = pos.inSeconds.toDouble();
      final durSecs = dur.inSeconds.toDouble();
      final progress = (durSecs > 0) ? (posSecs / durSecs).clamp(0.0, 1.0) : 0.0;

      String formatDuration(Duration d) {
        final minutes = d.inMinutes.toString().padLeft(2, '0');
        final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
        return "$minutes:$seconds";
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 8.0,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(pos),
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white60, fontSize: 13.0),
                ),
                Text(
                  formatDuration(dur),
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white60, fontSize: 13.0),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Loop toggle button
        Obx(() {
          final looping = controller.isLooping.value;
          return IconButton(
            onPressed: controller.toggleLoop,
            iconSize: 32.0,
            icon: Icon(
              Icons.loop_rounded,
              color: looping ? AppColors.gold : Colors.white30,
            ),
          );
        }),

        const SizedBox(width: 28.0),

        // Custom Play / Pause Button
        Obx(() {
          final playing = controller.isPlaying.value;
          return GestureDetector(
            onTap: () {
              HapticUtil.light();
              if (_ytController == null) return;
              if (playing) {
                _ytController!.pauseVideo();
              } else {
                // If the video has finished (position >= duration), seek to 0 first to play from start!
                final pos = _position.value.inSeconds;
                final dur = _duration.value.inSeconds;
                if (dur > 0 && pos >= dur) {
                  _ytController!.seekTo(seconds: 0.0);
                  _position.value = Duration.zero;
                }
                _ytController!.playVideo();
              }
            },
            child: Container(
              width: 76.0,
              height: 76.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.coral, AppColors.warningOrange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withOpacity(0.4),
                    blurRadius: 16.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 42.0,
              ),
            ),
          );
        }),

        const SizedBox(width: 28.0),

        // Replay Button
        IconButton(
          onPressed: () async {
            HapticUtil.medium();
            if (_ytController == null) return;
            _position.value = Duration.zero;
            controller.isPlaying.value = true;
            await _ytController!.seekTo(seconds: 0.0);
            await _ytController!.playVideo();
          },
          iconSize: 32.0,
          icon: const Icon(
            Icons.replay_rounded,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// Custom Painter to mask native WebView sharp corners with solid theme background
class RoundedCardMaskPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  RoundedCardMaskPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Path that covers only the four outer corners
    final path = Path()
      ..addRect(rect)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw the rounded golden border overlay
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
