import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'stars_animation.dart';
import '../../pages/dashboard/main.dart';
import '../../core/stores/meditation_store.dart';
import '../../shared/models/meditation_profile_data.dart';
import '../../pages/meditation_streaming_page.dart';

class GeneratingMeditation extends StatefulWidget {
  final String title;
  final String subtitle;
  final String videoAsset;
  final double bottomPadding;
  final MeditationProfileData? profileData; // Profile ma'lumotlari
  final bool isDirectRitual;

  const GeneratingMeditation({
    super.key,
    this.title = 'Generating Meditation',
    this.subtitle = 'We\'re shaping your vision\ninto a meditative journey...',
    this.videoAsset = 'assets/videos/moon.mp4',
    this.bottomPadding = 80,
    this.profileData, // Yangi parameter
    this.isDirectRitual = false,
  });

  @override
  State<GeneratingMeditation> createState() => _GeneratingMeditationState();
}

class _GeneratingMeditationState extends State<GeneratingMeditation>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _wasPlayingBeforePause = false;
  String _statusMessage =
      'We\'re shaping your vision\ninto a meditative journey...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoController();
    // initState da setState chaqirish muammosini oldini olish uchun keyingi frame da ishga tushiramiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProfileGeneration();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App background ga o'tganda video to'xtatish
        if (_controller != null && _controller!.value.isPlaying) {
          _wasPlayingBeforePause = true;
          _controller!.pause();
        }
        break;

      case AppLifecycleState.resumed:
        // App foreground ga qaytganda video davom ettirish
        if (_controller != null) {
          if (_wasPlayingBeforePause) {
            _controller!.play();
            _wasPlayingBeforePause = false;
          } else if (!_controller!.value.isPlaying && _isInitialized) {
            // Agar video to'xtagan bo'lsa va initialized bo'lsa, qayta ishga tushirish
            _restartVideo();
          }
        }
        break;

      case AppLifecycleState.detached:
        // App to'liq yopilganda
        break;

      case AppLifecycleState.hidden:
        // App yashiringan holatda
        break;
    }
  }

  Future<void> _initializeVideoController() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoAsset);

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        _controller!
          ..setLooping(true)
          ..setVolume(0)
          ..addListener(_videoListener)
          ..play();
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
        // 3 soniyadan keyin qayta urinish
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isInitialized) {
            _initializeVideoController();
          }
        });
      }
    }
  }

  Future<void> _restartVideo() async {
    if (_controller != null) {
      try {
        await _controller!.seekTo(Duration.zero);
        await _controller!.play();
      } catch (e) {
        // Video qayta ishga tushirishda xatolik bo'lsa, qayta initialize qilish
        await _initializeVideoController();
      }
    }
  }

  Future<void> _startProfileGeneration() async {
    if (widget.profileData == null) {
      _showErrorAndNavigate();
      return;
    }

    try {
      setState(() {
        _statusMessage =
            'We\'re shaping your vision\ninto a meditative journey...';
      });

      // MeditationStore ni olish - listen: false bilan olish kerak
      final meditationStore = Provider.of<MeditationStore>(
        context,
        listen: false,
      );

      // Force reload ritual settings from storage to ensure latest values
      await meditationStore.loadRitualSettings();

      // Storage dan ma'lumotlarni o'qish va profile ga saqlash
      final storedRitualType = meditationStore.storedRitualType;
      final storedTone = meditationStore.storedTone;
      final storedDuration = meditationStore.storedDuration;
      final storedVoice = meditationStore.storedVoice;

      // Profile ma'lumotlarini yangilash va saqlash
      final updatedProfileData = widget.profileData!.copyWith(
        ritualType: storedRitualType?.isNotEmpty == true
            ? [storedRitualType!]
            : widget.profileData!.ritualType,
        tone: storedTone?.isNotEmpty == true
            ? [storedTone!]
            : widget.profileData!.tone,
        duration: storedDuration?.isNotEmpty == true
            ? [storedDuration!]
            : widget.profileData!.duration,
        voice: storedVoice?.isNotEmpty == true
            ? [storedVoice!]
            : widget.profileData!.voice,
      );

      // Save updated profile to store
      meditationStore.setMeditationProfile(updatedProfileData);

      // Qisqa kutish (UI ko'rsatish uchun)
      await Future.delayed(const Duration(seconds: 1));

      // To'g'ridan-to'g'ri meditation_streaming_page ga o'tish - streaming u yerda boshlanadi
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MeditationStreamingPage(),
          ),
        );
      }
    } catch (e) {
      print('⚠️ Error in _startProfileGeneration: $e');
      _showErrorAndNavigate();
    }
  }

  void _showErrorAndNavigate() {
    if (mounted) {
      setState(() {
        _statusMessage = 'Something went wrong.\nPlease try again.';
      });

      // Toast xabarini ko'rsatish
      Fluttertoast.showToast(
        msg: 'Failed to generate meditation',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // Xatolik xabarini ko'rsatish va keyin dashboard pagega o'tish
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardMainPage()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    super.dispose();
  }

  // Video controller ni tekshirish va qayta ishga tushirish
  void _checkAndRestartVideo() {
    if (_controller != null &&
        !_controller!.value.isPlaying &&
        _isInitialized) {
      _restartVideo();
    }
  }

  // Video listener - video holatini kuzatish uchun
  void _videoListener() {
    if (_controller != null && mounted) {
      // Video to'xtagan bo'lsa va loop bo'lsa, qayta ishga tushirish
      if (!_controller!.value.isPlaying && _controller!.value.isLooping) {
        _restartVideo();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Har safar build bo'lganda video holatini tekshirish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRestartVideo();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Clear navigation stack to prevent back navigation to auth pages
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/dashboard',
            (route) {
              // Keep only dashboard and its sub-routes, remove auth pages
              return route.settings.name == '/dashboard' || 
                     route.settings.name == '/my-meditations' ||
                     route.settings.name == '/archive' ||
                     route.settings.name == '/vault' ||
                     route.settings.name == '/generator';
            }
          );
        }
      },
      child: Stack(
        children: [
        // Gradient background
        const StarsAnimation(),
        if (_isInitialized && _controller != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else if (!_isInitialized)
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

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFF2EFEA),
                  fontSize: 36,
                  fontFamily: 'Canela',
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: const TextStyle(
                  color: Color(0xFFF2EFEA),
                  fontSize: 16,
                  fontFamily: 'Satoshi',
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: widget.bottomPadding),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
