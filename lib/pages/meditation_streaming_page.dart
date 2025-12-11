import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import '../shared/widgets/wave_visualization.dart';
import '../shared/widgets/stars_animation.dart';
import '../core/services/meditation_streaming_service.dart';
import '../core/services/audio_player_service.dart';
import '../core/services/meditation_action_service.dart';
import 'components/sleep_meditation_header.dart';
import 'package:provider/provider.dart';
import '../core/stores/meditation_store.dart';
import '../core/stores/like_store.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class MeditationStreamingPage extends StatefulWidget {
  const MeditationStreamingPage({super.key});

  @override
  State<MeditationStreamingPage> createState() => _MeditationStreamingPageState();
}

class _MeditationStreamingPageState extends State<MeditationStreamingPage> {
  final MeditationStreamingService _streamingService = MeditationStreamingService();
  final AudioPlayerService _audioService = AudioPlayerService();
  
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _error;
  double _progressSeconds = 0;
  final List<Uint8List> _pcmChunks = [];
  Uint8List? _wavBytes;
  Timer? _progressTimer;
  DateTime? _startTime;
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isMuted = false;
  bool _isLiked = false;
  bool _showGeneratingScreen = true; // Generating screen ko'rsatish uchun
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAudioServiceListeners();
    _loadRitualSettings();
    _initializeVideoController();
    // Auto-start streaming when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStreaming();
    });
    // Generating screen ni boshlang'ich holatda ko'rsatish
    _showGeneratingScreen = true;
  }

  Future<void> _initializeVideoController() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/moon.mp4');
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController!
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  Future<void> _loadRitualSettings() async {
    final meditationStore = Provider.of<MeditationStore>(
      context,
      listen: false,
    );
    if (meditationStore.storedRitualType == null) {
      await meditationStore.loadRitualSettings();
    }
  }

  void _setupAudioServiceListeners() {
    _audioService.onPlayingStateChanged = (playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
        });
      }
    };
    
    _audioService.onPausedStateChanged = (paused) {
      if (mounted) {
        setState(() {
          _isPaused = paused;
        });
      }
    };
    
    _audioService.onPositionChanged = (position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    };
    
    _audioService.onDurationChanged = (duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    };
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _streamingService.dispose();
    _audioService.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> _startStreaming() async {
    print('🔵 ========== _startStreaming called ==========');
    setState(() {
      _error = null;
      _isLoading = true;
      _isStreaming = false;
      _wavBytes = null;
      _pcmChunks.clear();
      _progressSeconds = 0;
      _showGeneratingScreen = true; // Generating screen ni ko'rsatish
    });

    _progressTimer?.cancel();
    await _streamingService.startStreaming(
      context,
      onChunk: (chunks) {
        print('🔵 onChunk received: ${chunks.length} chunks');
        if (mounted) {
          setState(() {
            _pcmChunks.clear();
            _pcmChunks.addAll(chunks);
          });
        }
      },
      onComplete: (wavBytes) async {
        print("🔵 Stream to'liq tugadi, generating screen ni yashirish");
        if (mounted) {
          setState(() {
            _wavBytes = wavBytes;
            _isStreaming = false;
            _isLoading = false;
            _showGeneratingScreen = false; // Stream to'liq tugagach ham yashirish
          });

          if (_streamingService.tempAudioFile != null) {
            try {
              bool wasPlaying = _isPlaying;
              bool wasPaused = _isPaused;
              
              Duration? savedPosition;
              if (wasPlaying || wasPaused) {
                savedPosition = await _audioService.getCurrentPosition();
              }
              
              await _audioService.playFromFile(_streamingService.tempAudioFile!.path);
              
              if (savedPosition != null && savedPosition.inMilliseconds > 0) {
                await Future.delayed(const Duration(milliseconds: 100));
                await _audioService.seek(savedPosition);
                
                if (wasPlaying && !wasPaused) {
                  await _audioService.resume();
                }
              } else if (!wasPlaying && !wasPaused) {
                await _audioService.resume();
                if (mounted) {
                  setState(() {
                    _isPlaying = true;
                  });
                }
              }
            } catch (e) {
              if (mounted) {
                setState(() {
                  _error = "Playback error: $e";
                });
              }
            }
          }
        }
      },
      onErrorCallback: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isStreaming = false;
            _error = error;
          });
        }
      },
      onStateChanged: (streaming) {
        if (mounted) {
          setState(() {
            _isStreaming = streaming;
            _isLoading = false;
          });
          
          if (streaming) {
            _startTime = DateTime.now();
            _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
              if (_startTime != null && mounted) {
                final elapsed = DateTime.now().difference(_startTime!).inMilliseconds / 1000.0;
                setState(() {
                  _progressSeconds = elapsed;
                });
              }
            });
          } else {
            _progressTimer?.cancel();
            _progressTimer = null;
          }
        }
      },
      onProgress: (totalBytes) {
        final requiredBytes = _streamingService.bytesForInitialPlayback;
        print('🔵 onProgress callback: totalBytes=$totalBytes, requiredBytes=$requiredBytes, _showGeneratingScreen=$_showGeneratingScreen');
        
        // 2 sekundlik audio yetgach, generating screen ni yashirish
        if (totalBytes >= requiredBytes && _showGeneratingScreen) {
          print('🔵 ✅ 2 sekundlik audio yetdi, generating screen ni yashirish');
          if (mounted) {
            setState(() {
              _showGeneratingScreen = false;
            });
          }
        }
        
        if (!_isPlaying && totalBytes >= requiredBytes) {
          final tempFile = _streamingService.tempAudioFile;
          if (tempFile != null) {
            _startPlaybackDuringStreaming(tempFile);
          }
        }
      },
    );
  }

  Future<void> _startPlaybackDuringStreaming(File tempFile) async {
    if (_isPlaying) return;
    
    try {
      await _audioService.playFromFile(tempFile.path);
      
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _togglePlayPause() async {
    if (_isStreaming && !_isPlaying) {
      return;
    }

    if (_isPlaying) {
      await _audioService.pause();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    } else {
      await _audioService.resume();
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _audioService.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleLike() async {
    final meditationStore = context.read<MeditationStore>();
    final likeStore = context.read<LikeStore>();

    final meditationId = meditationStore.meditationProfile?.ritual?['id']?.toString();

    if (meditationId != null) {
      await likeStore.toggleLike(meditationId);
      setState(() {
        _isLiked = likeStore.isLiked(meditationId);
      });
    } else {
      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }

  void _shareMeditation() async {
    await Share.share('Vela - Navigate from Within. https://myvela.ai/');
  }

  void _showPersonalizedMeditationInfo() {
    MeditationActionService.showPersonalizedMeditationInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    final meditationStore = Provider.of<MeditationStore>(context, listen: false);
    final storedRitualType = meditationStore.storedRitualType ?? meditationStore.storedRitualId ?? '1';
    final profileData = meditationStore.meditationProfile;

    // Check if audio is fully loaded
    final isAudioReady = !_isStreaming && _wavBytes != null;

    // Get duration from audio file (rounded to minutes)
    // Agar audio hali yuklanmagan bo'lsa, default qiymat
    int durationMinutes = 2; // Default
    if (_duration.inMilliseconds > 0 && isAudioReady) {
      // Audio vaqtini minutlarda yaxlitlab olish
      final totalSeconds = _duration.inSeconds;
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      // Agar sekundlar 30 dan katta bo'lsa, 1 minut qo'shamiz (yaxlitlab yuqoriga)
      durationMinutes = seconds >= 30 ? minutes + 1 : minutes;
      // Minimum 1 minut
      if (durationMinutes < 1) durationMinutes = 1;
    }

    // Get title based on ritual type
    final title = storedRitualType == '1'
        ? 'Sleep Manifestation'
        : storedRitualType == '2'
            ? 'Morning Spark'
            : storedRitualType == '3'
                ? 'Calming Reset'
                : 'Dream Visualizer';

    // Get image path based on ritual type
    final imagePath = storedRitualType == '1'
        ? 'assets/img/card.png'
        : storedRitualType == '2'
            ? 'assets/img/card2.png'
            : storedRitualType == '3'
                ? 'assets/img/card3.png'
                : 'assets/img/card4.png';

    // Get description based on ritual type
    final description = storedRitualType == '1'
        ? 'A deeply personalized journey crafted from your unique vision and dreams'
        : storedRitualType == '2'
            ? 'An intimately tailored experience shaped by your individual aspirations and fantasies'
            : storedRitualType == '3'
                ? 'An expressive outlet that fosters creativity and self-discovery through various artistic mediums'
                : 'A deeply personalized journey crafted around your unique desires and dreams';

    // Generating screen ko'rsatish - 2 sekundlik audio yetguncha
    if (_showGeneratingScreen) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (route) {
                  return route.settings.name == '/dashboard' ||
                      route.settings.name == '/my-meditations' ||
                      route.settings.name == '/archive' ||
                      route.settings.name == '/vault' ||
                      route.settings.name == '/generator';
                },
              );
            }
          },
          child: Stack(
            children: [
              // Gradient background
              const StarsAnimation(),
              // Background video
              if (_isVideoInitialized && _videoController != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              else if (!_isVideoInitialized)
                // Video yuklanmagan bo'lsa, background image ko'rsatish
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/dep.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x663B6EAA), // 40% opacity
                      Color(0xE6A4C7EA),
                    ],
                  ),
                ),
              ),
              // Text content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Text(
                      'Generating meditation',
                      style: TextStyle(
                        color: Color(0xFFF2EFEA),
                        fontSize: 36,
                        fontFamily: 'Canela',
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We\'re shaping your vision\ninto a meditative journey...',
                      style: TextStyle(
                        color: Color(0xFFF2EFEA),
                        fontSize: 16,
                        fontFamily: 'Satoshi',
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const StarsAnimation(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SleepMeditationHeader(
                            onBackPressed: isAudioReady
                                ? () => Navigator.of(context).pop()
                                : () {
                                    // Streaming paytida dashboard pagega o'tish
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/dashboard',
                                      (route) {
                                        return route.settings.name == '/dashboard' ||
                                            route.settings.name == '/my-meditations' ||
                                            route.settings.name == '/archive' ||
                                            route.settings.name == '/vault' ||
                                            route.settings.name == '/generator';
                                      },
                                    );
                                  },
                            onInfoPressed: isAudioReady ? _showPersonalizedMeditationInfo : () {},
                          ),
                          SizedBox(height: 20),
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Canela',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC9DFF4),
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'This $durationMinutes min meditation weaves together your personal aspirations, gratitude, and authentic self with dreamy guidance to help manifest your dream life.',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          // Play/Pause button in center of card
                          Center(
                            child: GestureDetector(
                              onTap: isAudioReady ? _togglePlayPause : null,
                              child: Opacity(
                                opacity: isAudioReady ? 1.0 : 0.5,
                                child: Container(
                                  width: 170,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: AssetImage(imagePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Center(
                                    child: ClipOval(
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(59, 110, 170, 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Control bar (mute, like, share)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                  color: Colors.white.withOpacity(isAudioReady ? 1.0 : 0.5),
                                ),
                                onPressed: isAudioReady ? _toggleMute : null,
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                              Expanded(
                                child: Opacity(
                                  opacity: isAudioReady ? 1.0 : 0.5,
                                  child: GestureDetector(
                                    onTap: isAudioReady ? _toggleLike : null,
                                    child: Container(
                                      height: 60,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Resonating?',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Satoshi',
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                              IconButton(
                                icon: Icon(
                                  Icons.share,
                                  color: Colors.white.withOpacity(isAudioReady ? 1.0 : 0.5),
                                ),
                                onPressed: isAudioReady ? _shareMeditation : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Wave visualization with scrubbing
                          if (_pcmChunks.isNotEmpty) ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  height: 120,
                                  child: GestureDetector(
                                    onTapDown: isAudioReady
                                        ? (details) async {
                                            if (_duration.inMilliseconds > 0) {
                                              final tapX = details.localPosition.dx;
                                              final width = constraints.maxWidth;
                                              final progress = (tapX / width).clamp(0.0, 1.0);
                                              final seekPosition = Duration(
                                                milliseconds: (_duration.inMilliseconds * progress).round(),
                                              );
                                              await _audioService.seek(seekPosition);
                                              setState(() {
                                                _position = seekPosition;
                                              });
                                            }
                                          }
                                        : null,
                                    onPanUpdate: isAudioReady
                                        ? (details) async {
                                            if (_duration.inMilliseconds > 0) {
                                              final tapX = details.localPosition.dx;
                                              final width = constraints.maxWidth;
                                              final progress = (tapX / width).clamp(0.0, 1.0);
                                              final seekPosition = Duration(
                                                milliseconds: (_duration.inMilliseconds * progress).round(),
                                              );
                                              await _audioService.seek(seekPosition);
                                              setState(() {
                                                _position = seekPosition;
                                              });
                                            }
                                          }
                                        : null,
                                    child: WaveVisualization(
                                      pcmChunks: _pcmChunks,
                                      height: 120,
                                      duration: _duration,
                                      position: _position,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Time indicators below waveform - faqat audio to'liq yuklangach
                            if (isAudioReady) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Current time (left)
                                    Text(
                                      _formatTime(_position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // Total duration (right)
                                    Text(
                                      _formatTime(_duration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                          // Save to Dream Vault button - faqat audio to'liq yuklangach
                          if (isAudioReady) ...[
                            const SizedBox(height: 40),
                            SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Save to vault first
                                  await MeditationActionService.saveToVault(context);
                                  // Navigate to vault page
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/vault',
                                    (route) {
                                      return route.settings.name == '/vault' ||
                                          route.settings.name == '/dashboard' ||
                                          route.settings.name == '/my-meditations' ||
                                          route.settings.name == '/archive' ||
                                          route.settings.name == '/generator';
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B6EAA),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Save to Dream Vault',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
