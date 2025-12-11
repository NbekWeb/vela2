class WeeklyLoginStats {
  final String weekStart;
  final String weekEnd;
  final int totalLoginsThisWeek;
  final List<DayStats> days;

  WeeklyLoginStats({
    required this.weekStart,
    required this.weekEnd,
    required this.totalLoginsThisWeek,
    required this.days,
  });

  factory WeeklyLoginStats.fromJson(Map<String, dynamic> json) {
    List<DayStats> daysList = [];
    
    if (json['days'] != null) {
      if (json['days'] is List) {
        // New format: array of day objects
        final daysJson = json['days'] as List;
        daysList = daysJson.map((item) => DayStats.fromJson(item)).toList();
      } else if (json['days'] is Map) {
        // Old format: map with day names as keys
        final daysJson = json['days'] as Map<String, dynamic>;
        daysList = daysJson.values.map((value) => DayStats.fromJson(value)).toList();
      }
    }

    return WeeklyLoginStats(
      weekStart: json['week_start'] ?? '',
      weekEnd: json['week_end'] ?? '',
      totalLoginsThisWeek: json['total_logins_this_week'] ?? 0,
      days: daysList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_start': weekStart,
      'week_end': weekEnd,
      'total_logins_this_week': totalLoginsThisWeek,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

class DayStats {
  final String name;
  final bool login;

  DayStats({
    required this.name,
    required this.login,
  });

  factory DayStats.fromJson(Map<String, dynamic> json) {
    return DayStats(
      name: json['name'] ?? '',
      login: json['login'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'login': login,
    };
  }
}

class CheckIn {
  final int id;
  final String checkInDate;
  final String checkInChoice;
  final String description;

  CheckIn({
    required this.id,
    required this.checkInDate,
    required this.checkInChoice,
    required this.description,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] ?? 0,
      checkInDate: json['check_in_date'] ?? '',
      checkInChoice: json['check_in_choice'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'check_in_date': checkInDate,
      'check_in_choice': checkInChoice,
      'description': description,
    };
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final bool? userDeviceActive;
  final String? gender;
  final String? ageRange;
  final String? dream;
  final String? goals;
  final String? happiness;
  final WeeklyLoginStats? weeklyLoginStats;
  final List<CheckIn> checkIns;
  final int? goalsCount;
  final List<Map<String, dynamic>> checkGoalsList;
  final List<Map<String, dynamic>> goalsGenerateList;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatar,
    required this.createdAt,
    this.userDeviceActive,
    this.gender,
    this.ageRange,
    this.dream,
    this.goals,
    this.happiness,
    this.weeklyLoginStats,
    this.checkIns = const [],
    this.goalsCount,
    this.checkGoalsList = const [],
    this.goalsGenerateList = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse weekly login stats
    WeeklyLoginStats? weeklyStats;
    if (json['weekly_login_stats'] != null) {
      if (json['weekly_login_stats'] is List) {
        // New format: direct array of day objects
        final daysJson = json['weekly_login_stats'] as List;
        final daysList = daysJson.map((item) => DayStats.fromJson(item)).toList();
        weeklyStats = WeeklyLoginStats(
          weekStart: '',
          weekEnd: '',
          totalLoginsThisWeek: daysList.where((day) => day.login).length,
          days: daysList,
        );
      } else {
        // Old format: WeeklyLoginStats object
        weeklyStats = WeeklyLoginStats.fromJson(json['weekly_login_stats']);
      }
    }

    // Parse check-ins
    List<CheckIn> checkInsList = [];
    if (json['check_in'] != null) {
      final checkInsJson = json['check_in'] as List;
      checkInsList = checkInsJson.map((item) => CheckIn.fromJson(item)).toList();
    }

    // Parse user_detail nested object
    final userDetail = json['user_detail'] as Map<String, dynamic>?;
    
    // Parse goals_count and check_goals_list
    int? goalsCount;
    if (json['goals_count'] != null) {
      goalsCount = json['goals_count'] is int 
          ? json['goals_count'] 
          : int.tryParse(json['goals_count'].toString());
    }
    
    List<Map<String, dynamic>> checkGoalsList = [];
    try {
      if (json['check_goals_list'] != null && json['check_goals_list'] is List) {
        final list = json['check_goals_list'] as List;
        checkGoalsList = list
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      // If parsing fails, use empty list
      checkGoalsList = [];
    }
    
    List<Map<String, dynamic>> goalsGenerateList = [];
    try {
      if (json['goals_generate_list'] != null && json['goals_generate_list'] is List) {
        final list = json['goals_generate_list'] as List;
        goalsGenerateList = list
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      // If parsing fails, use empty list
      goalsGenerateList = [];
    }
    
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      userDeviceActive: json['user_device_active'],
      gender: userDetail?['gender'],
      ageRange: userDetail?['age_range'],
      dream: userDetail?['dream'],
      goals: userDetail?['goals'],
      happiness: userDetail?['happiness'],
      weeklyLoginStats: weeklyStats,
      checkIns: checkInsList,
      goalsCount: goalsCount,
      checkGoalsList: checkGoalsList,
      goalsGenerateList: goalsGenerateList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? 0,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'user_device_active': userDeviceActive,
      'weekly_login_stats': weeklyLoginStats?.toJson(),
      'check_in': checkIns.map((checkIn) => checkIn.toJson()).toList(),
      'user_detail': {
        'id': int.tryParse(id) ?? 0,
        'gender': gender,
        'age_range': ageRange,
        'dream': dream,
        'goals': goals,
        'happiness': happiness,
      },
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    bool? userDeviceActive,
    String? gender,
    String? ageRange,
    String? dream,
    String? goals,
    String? happiness,
    WeeklyLoginStats? weeklyLoginStats,
    List<CheckIn>? checkIns,
    int? goalsCount,
    List<Map<String, dynamic>>? checkGoalsList,
    List<Map<String, dynamic>>? goalsGenerateList,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      userDeviceActive: userDeviceActive ?? this.userDeviceActive,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      dream: dream ?? this.dream,
      goals: goals ?? this.goals,
      happiness: happiness ?? this.happiness,
      weeklyLoginStats: weeklyLoginStats ?? this.weeklyLoginStats,
      checkIns: checkIns ?? this.checkIns,
      goalsCount: goalsCount ?? this.goalsCount,
      checkGoalsList: checkGoalsList ?? this.checkGoalsList,
      goalsGenerateList: goalsGenerateList ?? this.goalsGenerateList,
    );
  }
} 

class LifeVision {
  final int id;
  final String liveVision;
  final String dreamsRealized;
  final List<String> visionType;
  final String createdAt;
  final String updatedAt;

  LifeVision({
    this.id = 0,
    this.liveVision = '',
    this.dreamsRealized = '',
    this.visionType = const [],
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory LifeVision.fromJson(Map<String, dynamic> json) {
    return LifeVision(
      id: json['id'] ?? 0,
      liveVision: json['live_vision'] ?? '',
      dreamsRealized: json['dreams_realized'] ?? '',
      visionType: json['vision_type'] != null 
          ? List<String>.from(json['vision_type']) 
          : [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'live_vision': liveVision,
      'dreams_realized': dreamsRealized,
      'vision_type': visionType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  LifeVision copyWith({
    int? id,
    String? liveVision,
    String? dreamsRealized,
    List<String>? visionType,
    String? createdAt,
    String? updatedAt,
  }) {
    return LifeVision(
      id: id ?? this.id,
      liveVision: liveVision ?? this.liveVision,
      dreamsRealized: dreamsRealized ?? this.dreamsRealized,
      visionType: visionType ?? this.visionType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 