import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

/// Service for managing audio playback
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  just_audio.AudioPlayer? _justAudioPlayer;
  
  // Callbacks
  Function(bool)? onPlayingStateChanged;
  Function(bool)? onPausedStateChanged;
  Function(Duration)? onPositionChanged;
  Function(Duration)? onDurationChanged;

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    _player.onPlayerStateChanged.listen((PlayerState state) {
      onPlayingStateChanged?.call(state == PlayerState.playing);
      onPausedStateChanged?.call(state == PlayerState.paused);
    });
    
    _player.onPositionChanged.listen((Duration position) {
      onPositionChanged?.call(position);
    });
    
    _player.onDurationChanged.listen((Duration duration) {
      onDurationChanged?.call(duration);
    });
  }

  /// Play audio from file
  /// If [preservePosition] is true, preserves current position when switching files
  Future<void> playFromFile(String filePath, {bool preservePosition = false}) async {
    try {
      Duration? savedPosition;
      if (preservePosition) {
        savedPosition = await _player.getCurrentPosition();
        print('🔵 Preserving position: $savedPosition');
      }
      
      await _player.stop();
      await _player.play(DeviceFileSource(filePath));
      
      // Restore position if preserved
      if (preservePosition && savedPosition != null && savedPosition.inMilliseconds > 0) {
        // Wait a bit for player to initialize
        await Future.delayed(const Duration(milliseconds: 100));
        await _player.seek(savedPosition);
        print('🔵 Position restored: $savedPosition');
      }
    } catch (e) {
      print('❌ Error playing from file: $e');
      rethrow;
    }
  }

  /// Play audio from bytes
  Future<void> playFromBytes(List<int> bytes) async {
    try {
      await _player.stop();
      await _player.play(BytesSource(Uint8List.fromList(bytes)));
    } catch (e) {
      print('❌ Error playing from bytes: $e');
      rethrow;
    }
  }

  /// Setup just_audio player (for compatibility with waveform)
  Future<void> setupJustAudioPlayer(String filePath) async {
    _justAudioPlayer ??= just_audio.AudioPlayer();
    await _justAudioPlayer!.setFilePath(filePath);
    
    _justAudioPlayer!.playerStateStream.listen((state) {
      onPlayingStateChanged?.call(state.playing);
    });

    _justAudioPlayer!.durationStream.listen((duration) {
      if (duration != null) {
        onDurationChanged?.call(duration);
      }
    });

    _justAudioPlayer!.positionStream.listen((position) {
      onPositionChanged?.call(position);
    });
  }

  /// Play with just_audio
  Future<void> playJustAudio() async {
    if (_justAudioPlayer != null) {
      await _justAudioPlayer!.play();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
    await _justAudioPlayer?.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.resume();
    await _justAudioPlayer?.play();
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
    await _justAudioPlayer?.stop();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    await _justAudioPlayer?.seek(position);
  }

  /// Get current position
  Future<Duration?> getCurrentPosition() async {
    return await _player.getCurrentPosition();
  }

  /// Get duration
  Future<Duration?> getDuration() async {
    return await _player.getDuration();
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    await _justAudioPlayer?.setVolume(volume);
  }

  /// Get just_audio player (for waveform compatibility)
  just_audio.AudioPlayer? get justAudioPlayer => _justAudioPlayer;

  /// Check if playing
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Check if paused
  bool get isPaused => _player.state == PlayerState.paused;

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    await _justAudioPlayer?.dispose();
    _justAudioPlayer = null;
  }
}
