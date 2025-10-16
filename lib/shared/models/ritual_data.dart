import 'package:flutter/material.dart';

class RitualData {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String icon; // Changed from IconData to String for image path
  final LinearGradient gradient;
  final Map<String, dynamic> defaultSettings;

  const RitualData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.gradient,
    required this.defaultSettings,
  });

  // Factory method to create from JSON
  factory RitualData.fromJson(Map<String, dynamic> json) {
    return RitualData(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      primaryColor: Color(json['primaryColor'] as int),
      secondaryColor: Color(json['secondaryColor'] as int),
      icon: json['icon'] as String, // Changed to use string path
      gradient: LinearGradient(
        colors: (json['gradientColors'] as List)
            .map((c) => Color(c as int))
            .toList(),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      defaultSettings: Map<String, dynamic>.from(
        json['defaultSettings'] as Map,
      ),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'icon': icon, // Changed to use string path
      'gradientColors': gradient.colors.map((c) => c.toARGB32()).toList(),
      'defaultSettings': defaultSettings,
    };
  }

  // Copy with method for immutability
  RitualData copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? description,
    Color? primaryColor,
    Color? secondaryColor,
    String? icon, // Changed from IconData to String
    LinearGradient? gradient,
    Map<String, dynamic>? defaultSettings,
  }) {
    return RitualData(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      icon: icon ?? this.icon,
      gradient: gradient ?? this.gradient,
      defaultSettings: defaultSettings ?? this.defaultSettings,
    );
  }

  // Get a specific setting value
  dynamic getSetting(String key) {
    return defaultSettings[key];
  }

  // Check if ritual has a specific setting
  bool hasSetting(String key) {
    return defaultSettings.containsKey(key);
  }

  // Get ritual type
  String? get ritualType {
    final types = defaultSettings['ritualType'] as List<String>?;
    return types?.isNotEmpty == true ? types!.first : null;
  }

  // Get tone
  String? get tone {
    final tones = defaultSettings['tone'] as List<String>?;
    return tones?.isNotEmpty == true ? tones!.first : null;
  }

  // Get voice
  String? get voice {
    final voices = defaultSettings['voice'] as List<String>?;
    return voices?.isNotEmpty == true ? voices!.first : null;
  }

  // Get duration
  String? get duration {
    final durations = defaultSettings['duration'] as List<String>?;
    return durations?.isNotEmpty == true ? durations!.first : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RitualData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RitualData(id: $id, title: $title)';
  }
}

// Predefined rituals data
class RitualDataProvider {
  static const List<RitualData> availableRituals = [
    RitualData(
      id: 1,
      title: 'Sleep Manifestation',
      subtitle: 'Fall asleep inside your future',
      description:
          'Let your mind drift into your dream life as you fall asleep. This ritual helps you visualize your goals and primes your subconscious for success overnight.',
      primaryColor: Color(0xFF296CB8),
      secondaryColor: Color(0xFFB3D0E7),
      icon: 'assets/img/sleep.png',
      gradient: LinearGradient(
        colors: [Color(0xFFB2CAE2), Color(0xFF82AAD1)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      defaultSettings: {
        'ritualType': ['guided'],
        'tone': ['dreamy'],
        'voice': ['male'],
        'duration': ['2'],
      },
    ),
    RitualData(
      id: 2,
      title: 'Morning Spark',
      subtitle: 'Fuel your vision with focus and energy',
      description:
          'Start your day with clarity and energy. This ritual focuses your mind on your vision, setting a positive and productive tone for the day.',
      primaryColor: Color(0xFFE38F6E),
      secondaryColor: Color(0xFFE0CDAD),
      icon: 'assets/img/spark.png',
      gradient: LinearGradient(
        colors: [Color(0xFFE68E6A), Color(0xFFE0CDAD)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      defaultSettings: {
        'ritualType': ['guided'],
        'tone': ['dreamy'],
        'voice': ['male'],
        'duration': ['2'],
      },
    ),
    RitualData(
      id: 3,
      title: 'Calming Reset',
      subtitle: 'Return to calm. Reconnect with clarity',
      description:
          'Take a mindful pause to reset and reconnect. This ritual brings you back to calm, helping you regain clarity and composure.',
      primaryColor: Color(0xFFD33FED),
      secondaryColor: Color(0xFFF5EAF3),
      icon: 'assets/img/calming.png',
      gradient: LinearGradient(
        colors: [Color(0xFFFB92B7), Color(0xFF91A9C2)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      defaultSettings: {
        'ritualType': ['guided'],
        'tone': ['dreamy'],
        'voice': ['male'],
        'duration': ['2'],
      },
    ),
    RitualData(
      id: 4,
      title: 'Dream Visualizer',
      subtitle: 'Drop into the life you\'re building',
      description:
          'Immerse yourself in the life you\'re building. This ritual strengthens your vision and motivation, making your dreams feel real and attainable.',
      primaryColor: Color(0xFF5A3AA5),
      secondaryColor: Color(0xFFCEC5F6),
      icon: 'assets/img/dream.png',
      gradient: LinearGradient(
        colors: [Color(0xFFAAAFD4), Color(0xFFA2A7D1)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      defaultSettings: {
        'ritualType': ['guided'],
        'tone': ['dreamy'],
        'voice': ['male'],
        'duration': ['2'],
      },
    ),
  ];

  // Get ritual by ID
  static RitualData? getRitualById(int id) {
    try {
      return availableRituals.firstWhere((ritual) => ritual.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get ritual by title
  static RitualData? getRitualByTitle(String title) {
    try {
      return availableRituals.firstWhere((ritual) => ritual.title == title);
    } catch (e) {
      return null;
    }
  }

  // Get rituals by type
  static List<RitualData> getRitualsByType(String ritualType) {
    return availableRituals
        .where(
          (ritual) =>
              ritual.defaultSettings['ritualType']?.contains(ritualType) ==
              true,
        )
        .toList();
  }

  // Get rituals by tone
  static List<RitualData> getRitualsByTone(String tone) {
    return availableRituals
        .where(
          (ritual) => ritual.defaultSettings['tone']?.contains(tone) == true,
        )
        .toList();
  }

  // Get rituals by voice
  static List<RitualData> getRitualsByVoice(String voice) {
    return availableRituals
        .where(
          (ritual) => ritual.defaultSettings['voice']?.contains(voice) == true,
        )
        .toList();
  }

  // Get rituals by duration
  static List<RitualData> getRitualsByDuration(String duration) {
    return availableRituals
        .where(
          (ritual) =>
              ritual.defaultSettings['duration']?.contains(duration) == true,
        )
        .toList();
  }

  // Get all ritual types
  static List<String> get allRitualTypes {
    final types = <String>{};
    for (final ritual in availableRituals) {
      final ritualTypes = ritual.defaultSettings['ritualType'] as List<String>?;
      if (ritualTypes != null) {
        types.addAll(ritualTypes);
      }
    }
    return types.toList();
  }

  // Get all tones
  static List<String> get allTones {
    final tones = <String>{};
    for (final ritual in availableRituals) {
      final ritualTones = ritual.defaultSettings['tone'] as List<String>?;
      if (ritualTones != null) {
        tones.addAll(ritualTones);
      }
    }
    return tones.toList();
  }

  // Get all voices
  static List<String> get allVoices {
    final voices = <String>{};
    for (final ritual in availableRituals) {
      final ritualVoices = ritual.defaultSettings['voice'] as List<String>?;
      if (ritualVoices != null) {
        voices.addAll(ritualVoices);
      }
    }
    return voices.toList();
  }

  // Get all durations
  static List<String> get allDurations {
    final durations = <String>{};
    for (final ritual in availableRituals) {
      final ritualDurations =
          ritual.defaultSettings['duration'] as List<String>?;
      if (ritualDurations != null) {
        durations.addAll(ritualDurations);
      }
    }
    return durations.toList();
  }

  // Filter rituals by multiple criteria
  static List<RitualData> filterRituals({
    String? ritualType,
    String? tone,
    String? voice,
    String? duration,
  }) {
    return availableRituals.where((ritual) {
      if (ritualType != null &&
          !ritual.defaultSettings['ritualType']?.contains(ritualType) == true) {
        return false;
      }
      if (tone != null &&
          !ritual.defaultSettings['tone']?.contains(tone) == true) {
        return false;
      }
      if (voice != null &&
          !ritual.defaultSettings['voice']?.contains(voice) == true) {
        return false;
      }
      if (duration != null &&
          !ritual.defaultSettings['duration']?.contains(duration) == true) {
        return false;
      }
      return true;
    }).toList();
  }
}
