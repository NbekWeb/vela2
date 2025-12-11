import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../../core/stores/auth_store.dart';
import '../../core/stores/meditation_store.dart';

const String BASE_ENDPOINT = "http://31.97.98.47:8000";
const int SAMPLE_RATE = 44100;
const int CHANNELS = 2;
const int BYTES_PER_SAMPLE = 2;

/// Get endpoint based on ritualType (1, 2, 3, 4)
String getEndpoint(String? ritualType) {
  final type = ritualType ?? '1';
  switch (type) {
    case '1':
      return "$BASE_ENDPOINT/sleep";
    case '2':
      return "$BASE_ENDPOINT/spark";
    case '3':
      return "$BASE_ENDPOINT/calm";
    case '4':
      return "$BASE_ENDPOINT/dream";
    default:
      return "$BASE_ENDPOINT/calm";
  }
}

/// Capitalize ritual type for API (guided -> Guided, story -> Story)
String capitalizeRitualType(String value) {
  final lower = value.toLowerCase();
  if (lower == 'guided') return 'Guided';
  if (lower == 'story') return 'Story';
  // Default: capitalize first letter
  return value.isEmpty
      ? 'Story'
      : value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Capitalize tone for API (dreamy -> Dreamy, asmr -> ASMR)
String capitalizeTone(String value) {
  final lower = value.toLowerCase();
  if (lower == 'dreamy') return 'Dreamy';
  if (lower == 'asmr') return 'ASMR';
  // Default: capitalize first letter
  return value.isEmpty
      ? 'Dreamy'
      : value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Capitalize voice for API (male -> Male, female -> Female)
String capitalizeVoice(String value) {
  final lower = value.toLowerCase();
  if (lower == 'male') return 'Male';
  if (lower == 'female') return 'Female';
  // Default: capitalize first letter
  return value.isEmpty
      ? 'Female'
      : value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Build request body from user data
Map<String, dynamic> buildRequestBody(BuildContext? context) {
  // Default values
  String name = "User";
  String goals = "";
  String dreamlife = "";
  String dreamActivities = "";
  String ritualType = "Story";
  String tone = "Dreamy";
  String voice = "Female";
  int length = 2;
  String checkIn = "string";

  // Try to get user data from stores if context is available
  if (context != null) {
    try {
      // Check if Provider is available in the widget tree
      try {
        final authStore = Provider.of<AuthStore>(context, listen: false);
        final meditationStore = Provider.of<MeditationStore>(
          context,
          listen: false,
        );

        final user = authStore.user;
        final profile = meditationStore.meditationProfile;

        // Get name
        if (user != null) {
          final firstName = user.firstName;
          final lastName = user.lastName;
          name = "$firstName $lastName".trim();
          if (name.isEmpty && user.email.isNotEmpty) {
            name = user.email.split('@').first;
          }
        }

        // Get goals
        if (user != null && user.goals != null && user.goals!.isNotEmpty) {
          goals = user.goals!;
        } else if (profile != null &&
            profile.goals != null &&
            profile.goals!.isNotEmpty) {
          goals = profile.goals!.join(", ");
        }

        // Get dreamlife
        if (user != null && user.dream != null && user.dream!.isNotEmpty) {
          dreamlife = user.dream!;
        } else if (profile != null &&
            profile.dream != null &&
            profile.dream!.isNotEmpty) {
          dreamlife = profile.dream!.join(", ");
        }

        // Get dream activities (same as dreamlife for now)
        dreamActivities = dreamlife;

        // Get ritual settings - handle null safety and capitalize for API
        if (meditationStore.storedRitualType != null &&
            meditationStore.storedRitualType!.isNotEmpty) {
          ritualType = capitalizeRitualType(meditationStore.storedRitualType!);
        } else if (profile?.ritualType != null &&
            profile!.ritualType!.isNotEmpty) {
          ritualType = capitalizeRitualType(profile.ritualType!.first);
        }

        if (meditationStore.storedTone != null &&
            meditationStore.storedTone!.isNotEmpty) {
          tone = capitalizeTone(meditationStore.storedTone!);
        } else if (profile?.tone != null && profile!.tone!.isNotEmpty) {
          tone = capitalizeTone(profile.tone!.first);
        }

        if (meditationStore.storedVoice != null &&
            meditationStore.storedVoice!.isNotEmpty) {
          voice = capitalizeVoice(meditationStore.storedVoice!);
        } else if (profile?.voice != null && profile!.voice!.isNotEmpty) {
          voice = capitalizeVoice(profile.voice!.first);
        }

        // Get duration/length
        if (meditationStore.storedDuration != null &&
            meditationStore.storedDuration!.isNotEmpty) {
          final durationStr = meditationStore.storedDuration!;
          length = int.tryParse(durationStr) ?? 2;
        } else if (profile?.duration != null && profile!.duration!.isNotEmpty) {
          final durationStr = profile.duration!.first;
          length = int.tryParse(durationStr) ?? 2;
        }

        print(
          '🔵 Using user data: name=$name, ritualType=$ritualType, tone=$tone, voice=$voice, length=$length',
        );
      } catch (providerError) {
        print('⚠️ Provider error (stores not available): $providerError');
        print('⚠️ Using default values');
      }
    } catch (e, stackTrace) {
      print('⚠️ Error getting user data: $e');
      print('⚠️ Stack trace: $stackTrace');
      print('⚠️ Using default values');
    }
  } else {
    print('⚠️ Context is null, using default values');
  }

  return {
    "ritual_type": "Story",
    "name": name,
    "goals": goals.isNotEmpty ? goals : "Inner peace and personal growth",
    "dreamlife": dreamlife.isNotEmpty
        ? dreamlife
        : "A peaceful and fulfilling life",
    "dream_activities": dreamActivities.isNotEmpty
        ? dreamActivities
        : dreamlife.isNotEmpty
        ? dreamlife
        : "A peaceful and fulfilling life",
    "tone": tone,
    "voice": voice,
    "length": length,
    "check_in": checkIn,
  };
}

/// Создать WAV-байты из сырых PCM (Int16 LE)
Uint8List createWavBytes(
  List<Uint8List> pcmChunks,
  int sampleRate,
  int channels,
) {
  final bytesPerSample = BYTES_PER_SAMPLE;
  final dataLength = pcmChunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
  const headerSize = 44;
  final totalDataSize = headerSize + dataLength;
  final header = ByteData(headerSize);

  void writeString(int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      header.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  // RIFF header
  writeString(0, "RIFF");
  header.setUint32(4, 36 + dataLength, Endian.little);
  writeString(8, "WAVE");

  // fmt chunk
  writeString(12, "fmt ");
  header.setUint32(16, 16, Endian.little); // размер fmt
  header.setUint16(20, 1, Endian.little); // формат = 1 (PCM)
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  final byteRate = sampleRate * channels * bytesPerSample;
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, channels * bytesPerSample, Endian.little); // block align
  header.setUint16(34, 8 * bytesPerSample, Endian.little); // bits per sample

  // data chunk
  writeString(36, "data");
  header.setUint32(40, dataLength, Endian.little);

  final builder = BytesBuilder();
  builder.add(header.buffer.asUint8List());
  for (final chunk in pcmChunks) {
    builder.add(chunk);
  }

  final fullBytes = builder.toBytes();
  assert(fullBytes.length == totalDataSize);
  return fullBytes;
}

/// Extract amplitude samples from PCM data for visualization
List<double> extractAmplitudes(List<Uint8List> pcmChunks, int maxSamples) {
  if (pcmChunks.isEmpty) return [];

  // Combine all chunks
  final totalBytes = pcmChunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
  if (totalBytes < BYTES_PER_SAMPLE * CHANNELS) return [];

  final allBytes = Uint8List(totalBytes);
  int offset = 0;
  for (final chunk in pcmChunks) {
    allBytes.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }

  // Extract samples (Int16 LE, stereo)
  final samples = <double>[];
  final bytesPerFrame = BYTES_PER_SAMPLE * CHANNELS;
  final step = math.max(1, (totalBytes ~/ bytesPerFrame) ~/ maxSamples);

  for (int i = 0; i < totalBytes - bytesPerFrame; i += bytesPerFrame * step) {
    // Read left channel (first sample)
    final sampleValue = allBytes.buffer.asByteData().getInt16(i, Endian.little);
    // Normalize to 0-1 range
    final amplitude = (sampleValue.abs() / 32768.0).clamp(0.0, 1.0);
    samples.add(amplitude);

    if (samples.length >= maxSamples) break;
  }

  return samples;
}
