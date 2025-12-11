import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../pages/meditation_streaming/helpers.dart';
import '../../core/stores/meditation_store.dart';

/// Service for handling meditation audio streaming
class MeditationStreamingService {
  http.Client? _client;
  StreamSubscription<List<int>>? _streamSub;
  File? _tempAudioFile;
  final List<Uint8List> _pcmChunks = [];

  // Callbacks
  Function(List<Uint8List>)? onChunkReceived;
  Function(Uint8List)? onStreamComplete;
  Function(String)? onError;
  Function(bool)? onStreamingStateChanged;
  Function(int)? onProgressUpdate;

  /// Start streaming meditation audio
  Future<File?> startStreaming(
    BuildContext context, {
    Function(List<Uint8List>)? onChunk,
    Function(Uint8List)? onComplete,
    Function(String)? onErrorCallback,
    Function(bool)? onStateChanged,
    Function(int)? onProgress,
  }) async {
    // Set callbacks
    onChunkReceived = onChunk;
    onStreamComplete = onComplete;
    onError = onErrorCallback;
    onStreamingStateChanged = onStateChanged;
    onProgressUpdate = onProgress;

    try {
      _client = http.Client();
      _pcmChunks.clear();

      // Get ritualType from context to determine endpoint
      String? ritualType;
      if (context != null) {
        try {
          final meditationStore = Provider.of<MeditationStore>(context, listen: false);
          ritualType = meditationStore.storedRitualType ?? meditationStore.storedRitualId ?? '1';
        } catch (e) {
          ritualType = '1';
        }
      } else {
        ritualType = '1';
      }

      final endpoint = getEndpoint(ritualType);
      final requestBody = buildRequestBody(context);
      print('🔵 ========== Starting stream request ==========');
      print('🔵 RitualType: $ritualType');
      print('🔵 Endpoint: $endpoint');
      print('🔵 Request body: ${jsonEncode(requestBody)}');

      final request = http.Request('POST', Uri.parse(endpoint));

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(requestBody);

      print('🔵 Sending request to: $endpoint');
      final streamedResponse = await _client!.send(request);
      print('🔵 Response status: ${streamedResponse.statusCode}');
      print('🔵 Response headers: ${streamedResponse.headers}');

      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        String errorBody = '';
        try {
          final chunks = <List<int>>[];
          await for (final chunk in streamedResponse.stream) {
            chunks.add(chunk);
          }
          if (chunks.isNotEmpty) {
            final allBytes = chunks.expand((chunk) => chunk).toList();
            errorBody = utf8.decode(allBytes);
          }
        } catch (e) {
          print('❌ SERVER ERROR: ${streamedResponse.statusCode}');
        }
        throw Exception(
          "Server error: ${streamedResponse.statusCode} - $errorBody",
        );
      }

      onStreamingStateChanged?.call(true);

      // Create temporary file for streaming
      final tempDir = await getTemporaryDirectory();
      _tempAudioFile = File(
        '${tempDir.path}/meditation_stream_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      _streamSub = streamedResponse.stream.listen(
        (List<int> chunk) async {
          final data = Uint8List.fromList(chunk);
          _pcmChunks.add(data);

          final totalBytes = _pcmChunks.fold<int>(
            0,
            (sum, c) => sum + c.length,
          );
          
          // Calculate audio duration in seconds
          final bytesPerSecond = SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE;
          final audioSeconds = totalBytes / bytesPerSecond;
          final requiredBytes = 2 * SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE;
          
          // Debug: Stream hajmi va sekundlarni ko'rsatish
          print('🔵 Stream chunk: chunkSize=${chunk.length} bytes, totalBytes=$totalBytes bytes (${(totalBytes / 1024).toStringAsFixed(2)} KB), audioSeconds=${audioSeconds.toStringAsFixed(2)}s, requiredBytes=$requiredBytes (2s)');
          
          onProgressUpdate?.call(totalBytes);
          onChunkReceived?.call(_pcmChunks);

          // Create/update WAV file with current chunks
          try {
            final wav = createWavBytes(_pcmChunks, SAMPLE_RATE, CHANNELS);
            final wavSize = wav.length;
            print('🔵 WAV file size: $wavSize bytes (${(wavSize / 1024).toStringAsFixed(2)} KB)');
            await _tempAudioFile!.writeAsBytes(wav);
          } catch (e, stackTrace) {
            print('⚠️ Stack trace: $stackTrace');
          }
        },
        onDone: () async {
          final totalBytes = _pcmChunks.fold<int>(
            0,
            (sum, c) => sum + c.length,
          );
          
          // Calculate final audio duration
          final bytesPerSecond = SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE;
          final finalAudioSeconds = totalBytes / bytesPerSecond;
          
          print('🔵 ========== Stream to\'liq tugadi ==========');
          print('🔵 Total bytes: $totalBytes (${(totalBytes / 1024).toStringAsFixed(2)} KB)');
          print('🔵 Final audio duration: ${finalAudioSeconds.toStringAsFixed(2)} seconds (${(finalAudioSeconds / 60).toStringAsFixed(2)} minutes)');
          print('🔵 Total chunks: ${_pcmChunks.length}');
          
          if (_pcmChunks.isNotEmpty) {
            try {
              final wav = createWavBytes(_pcmChunks, SAMPLE_RATE, CHANNELS);
              final wavSize = wav.length;
              print('🔵 Final WAV file size: $wavSize bytes (${(wavSize / 1024).toStringAsFixed(2)} KB)');

              if (_tempAudioFile != null) {
                await _tempAudioFile!.writeAsBytes(wav);
                print('✅ WAV file written successfully to: ${_tempAudioFile!.path}');
              }
              onStreamingStateChanged?.call(false);

              onStreamComplete?.call(wav);
            } catch (e, stackTrace) {
              print('❌ WAV creation error: $e');
              onStreamingStateChanged?.call(false);
              onError?.call("WAV creation error: $e");
            }
          } else {
            print('❌ Empty stream from server');
            onStreamingStateChanged?.call(false);
            onError?.call("Empty stream from server");
          }
        },
        onError: (err, stackTrace) {
          ;
          onStreamingStateChanged?.call(false);
          onError?.call(err.toString());
        },
        cancelOnError: true,
      );
      return _tempAudioFile;
    } catch (e, stackTrace) {
      onStreamingStateChanged?.call(false);
      onError?.call(e.toString());
      return null;
    }
  }

  /// Stop streaming
  Future<void> stopStreaming() async {
    _streamSub?.cancel();
    _streamSub = null;
    _client?.close();
    _client = null;
    // Callback'ni chaqirmaslik - widget dispose bo'lganda xatolik yuzaga kelmasligi uchun
    // onStreamingStateChanged?.call(false);
  }

  /// Get current PCM chunks
  List<Uint8List> get pcmChunks => List.unmodifiable(_pcmChunks);

  /// Get temporary audio file
  File? get tempAudioFile => _tempAudioFile;

  /// Calculate minimum bytes for initial playback
  int get bytesForInitialPlayback =>
      2 * SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE;

  /// Dispose resources
  Future<void> dispose() async {
    await stopStreaming();
    // Clean up temp file
    if (_tempAudioFile != null) {
      _tempAudioFile!.delete().catchError((e) {
        print('⚠️ Error deleting temp file: $e');
        return _tempAudioFile!;
      });
    }
    _tempAudioFile = null;
    _pcmChunks.clear();
  }
}
