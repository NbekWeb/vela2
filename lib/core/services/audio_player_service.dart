import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:audio_session/audio_session.dart';

/// Service for managing audio playback
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  just_audio.AudioPlayer? _justAudioPlayer;
  
  // Callbacks
  Function(bool)? onPlayingStateChanged;
  Function(bool)? onPausedStateChanged;
  Function(Duration)? onPositionChanged;
  Function(Duration)? onDurationChanged;

  // Track current position to preserve it during file updates
  Duration? _lastKnownPosition;
  bool _isUpdatingFile = false; // Flag to prevent position updates during file update
  AudioSession? _audioSession;
  bool _isAudioSessionConfigured = false;
  bool _isFileUpdateInProgress = false; // Prevent parallel file updates

  AudioPlayerService() {
    _setupListeners();
    _configureAudioSession();
  }

  /// Configure audio session for Android/iOS
  Future<void> _configureAudioSession() async {
    if (_isAudioSessionConfigured) return;
    
    try {
      _audioSession = await AudioSession.instance;
      // Use music() preset for meditation audio playback
      await _audioSession!.configure(AudioSessionConfiguration.music());
      _isAudioSessionConfigured = true;
      print('✅ Audio session configured successfully');
    } catch (e) {
      print('⚠️ Error configuring audio session: $e');
      // Continue anyway - audio might still work
    }
  }

  void _setupListeners() {
    _player.onPlayerStateChanged.listen((PlayerState state) {
      onPlayingStateChanged?.call(state == PlayerState.playing);
      onPausedStateChanged?.call(state == PlayerState.paused);
    });
    
    _player.onPositionChanged.listen((Duration position) {
      // Only update last known position if we're not updating the file
      // This prevents position from being reset during file updates
      if (!_isUpdatingFile) {
        _lastKnownPosition = position;
      }
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
      // Ensure audio session is configured before playing
      if (!_isAudioSessionConfigured) {
        await _configureAudioSession();
      }
      
      // Validate file path
      if (filePath.isEmpty) {
        throw Exception('File path is empty');
      }
      
      // Check if file exists (with error handling for Android)
      try {
        final file = File(filePath);
        final exists = await file.exists();
        if (!exists) {
          throw Exception('File does not exist: $filePath');
        }
      } catch (e) {
        // On Android, file.exists() might fail, but file might still be valid
        // Log warning but continue
        print('⚠️ Could not verify file existence: $e');
      }
      
      Duration? savedPosition;
      if (preservePosition) {
        try {
          savedPosition = await _player.getCurrentPosition();
          print('🔵 Preserving position: $savedPosition');
        } catch (e) {
          print('⚠️ Error getting current position: $e');
          savedPosition = null;
        }
      }
      
      try {
        await _player.stop();
      } catch (e) {
        print('⚠️ Error stopping player: $e');
        // Continue anyway
      }
      
      // Request audio focus before playing (Android)
      if (Platform.isAndroid && _audioSession != null) {
        try {
          await _audioSession!.setActive(true);
        } catch (e) {
          print('⚠️ Error setting audio session active: $e');
          // Continue anyway
        }
      }
      
      await _player.play(DeviceFileSource(filePath));
      
      // Restore position if preserved
      if (preservePosition && savedPosition != null && savedPosition.inMilliseconds > 0) {
        // Wait a bit for player to initialize
        await Future.delayed(const Duration(milliseconds: 100));
        try {
          await _player.seek(savedPosition);
          print('🔵 Position restored: $savedPosition');
        } catch (e) {
          print('⚠️ Error seeking to position: $e');
          // Continue anyway - playback will start from beginning
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error playing from file: $e');
      print('❌ Stack trace: $stackTrace');
      // Don't rethrow on Android - try to continue
      if (Platform.isAndroid) {
        print('⚠️ Android: Continuing despite error');
        return;
      }
      rethrow;
    }
  }

  /// Update audio file while preserving current position
  /// Used when streaming file is updated with new chunks
  /// [savedPosition] - optional position to preserve (if not provided, uses last known position)
  Future<void> updateFilePreservingPosition(
    String filePath, {
    Duration? savedPosition,
  }) async {
    // Prevent parallel file updates - this causes Android freezing
    if (_isFileUpdateInProgress) {
      print('⚠️ File update already in progress, skipping...');
      return;
    }
    
    bool wasPlaying = false;
    try {
      _isFileUpdateInProgress = true;
      // Set flag to prevent position updates during file update
      _isUpdatingFile = true;
      
      // Use provided position, or fallback to last known position, or getCurrentPosition()
      final positionToPreserve = savedPosition ?? _lastKnownPosition ?? await _player.getCurrentPosition();
      wasPlaying = _player.state == PlayerState.playing;
      
      // Skip update if position is null or 0 (audio not started yet)
      if (positionToPreserve == null || positionToPreserve.inMilliseconds == 0) {
        print('🔵 Skipping file update - position is null or 0');
        _isUpdatingFile = false;
        return;
      }
      
      // At this point, positionToPreserve is guaranteed to be non-null
      final Duration nonNullPosition = positionToPreserve;
      
      // Check if file exists and is readable
      File? file;
      try {
        file = File(filePath);
        // Check if file exists with error handling for Android
        bool fileExists = false;
        try {
          fileExists = await file.exists();
        } catch (e) {
          print('⚠️ Error checking file existence: $e');
          _isUpdatingFile = false;
          return;
        }
        
        if (!fileExists) {
          print('⚠️ File does not exist yet: $filePath');
          _isUpdatingFile = false;
          return;
        }
        
        // Wait a bit to ensure file is fully written
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Check file size - if it's too small, skip update
        int fileSize = 0;
        try {
          fileSize = await file.length();
        } catch (e) {
          print('⚠️ Error getting file size: $e');
          // Continue anyway - file might be valid but size check failed
        }
        
        if (fileSize > 0 && fileSize < 1000) {
          print('⚠️ File too small, skipping update: $fileSize bytes');
          _isUpdatingFile = false;
          return;
        }
      } catch (e) {
        print('⚠️ Error accessing file: $e');
        _isUpdatingFile = false;
        return;
      }
      
      print('🔵 Updating file, preserving position: $nonNullPosition (from ${savedPosition != null ? "callback" : _lastKnownPosition != null ? "state" : "getCurrentPosition()"}), wasPlaying: $wasPlaying');
      
      // IMPORTANT: Set flag BEFORE stop() to prevent position listener from resetting _lastKnownPosition
      // Stop() can trigger position changes that reset position to 0
      
      // Stop current playback with error handling
      try {
        await _player.stop();
      } catch (e) {
        print('⚠️ Error stopping player: $e');
        // Continue anyway
      }
      
      // Wait a bit before loading new file (increased for Android stability)
      await Future.delayed(Duration(milliseconds: Platform.isAndroid ? 150 : 50));
      
      // Request audio focus before playing (Android)
      if (Platform.isAndroid && _audioSession != null) {
        try {
          await _audioSession!.setActive(true);
        } catch (e) {
          print('⚠️ Error setting audio session active: $e');
          // Continue anyway
        }
      }
      
      // Load new file (this will auto-play, so we'll pause it immediately)
      try {
        await _player.play(DeviceFileSource(filePath));
      } catch (e) {
        print('❌ Error playing new file: $e');
        _isUpdatingFile = false;
        _isFileUpdateInProgress = false;
        // Try to resume playback if it was playing before
        if (wasPlaying) {
          try {
            await Future.delayed(const Duration(milliseconds: 100));
            await _player.resume();
          } catch (resumeError) {
            print('❌ Error resuming after play failure: $resumeError');
          }
        }
        // On Android, don't throw - just return
        if (Platform.isAndroid) {
          return;
        }
        return;
      }
      
      // Immediately pause to prevent auto-play
      try {
        await _player.pause();
      } catch (e) {
        print('⚠️ Error pausing player: $e');
        // Continue anyway
      }
      
      // Wait for player to initialize and load the file (increased for Android stability)
      await Future.delayed(Duration(milliseconds: Platform.isAndroid ? 500 : 300));
      
      // Restore position (we already checked it's not null and > 0)
      try {
        await _player.seek(nonNullPosition);
        // Update last known position AFTER seek and BEFORE resetting flag
        _lastKnownPosition = nonNullPosition;
        print('🔵 Position restored after file update: $nonNullPosition');
      } catch (e) {
        print('⚠️ Error seeking to position: $e');
        // Continue anyway - position might be restored later
      }
      
      // Resume playback if it was playing before
      if (wasPlaying) {
        await Future.delayed(const Duration(milliseconds: 50));
        try {
          await _player.resume();
          print('🔵 Playback resumed after file update');
        } catch (e) {
          print('⚠️ Error resuming playback: $e');
          // Continue anyway
        }
      }
    } catch (e) {
      print('❌ Error updating file preserving position: $e');
      // Try to resume playback if it was playing before
      try {
        if (wasPlaying) {
          await _player.resume();
        }
      } catch (resumeError) {
        print('❌ Error resuming playback after update failure: $resumeError');
      }
      // Don't rethrow - allow playback to continue even if update fails
    } finally {
      // Always reset flags
      _isUpdatingFile = false;
      _isFileUpdateInProgress = false;
    }
  }

  /// Play audio from bytes
  Future<void> playFromBytes(List<int> bytes) async {
    try {
      // Ensure audio session is configured before playing
      if (!_isAudioSessionConfigured) {
        await _configureAudioSession();
      }
      
      // Request audio focus before playing (Android)
      if (Platform.isAndroid && _audioSession != null) {
        try {
          await _audioSession!.setActive(true);
        } catch (e) {
          print('⚠️ Error setting audio session active: $e');
          // Continue anyway
        }
      }
      
      await _player.stop();
      await _player.play(BytesSource(Uint8List.fromList(bytes)));
    } catch (e) {
      print('❌ Error playing from bytes: $e');
      // Don't rethrow on Android - try to continue
      if (Platform.isAndroid) {
        print('⚠️ Android: Continuing despite error');
        return;
      }
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
    try {
      // Request audio focus before resuming (Android)
      if (Platform.isAndroid && _audioSession != null) {
        try {
          await _audioSession!.setActive(true);
        } catch (e) {
          print('⚠️ Error setting audio session active: $e');
          // Continue anyway
        }
      }
      
      await _player.resume();
      await _justAudioPlayer?.play();
    } catch (e) {
      print('❌ Error resuming playback: $e');
      // On Android, don't throw
      if (!Platform.isAndroid) {
        rethrow;
      }
    }
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
    try {
      // Release audio focus (Android)
      if (Platform.isAndroid && _audioSession != null) {
        try {
          await _audioSession!.setActive(false);
        } catch (e) {
          print('⚠️ Error deactivating audio session: $e');
        }
      }
      
      await _player.dispose();
      await _justAudioPlayer?.dispose();
      _justAudioPlayer = null;
      _audioSession = null;
      _isAudioSessionConfigured = false;
    } catch (e) {
      print('⚠️ Error disposing audio player: $e');
    }
  }
}
