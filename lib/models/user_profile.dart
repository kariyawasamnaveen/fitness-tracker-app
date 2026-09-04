// ignore_for_file: unused_local_variable, use_build_context_synchronously
class UserProfile {
  final double weight;
  final double height;
  final bool isKgMode;
  final bool isCmMode;
  final bool isPremium;
  final bool hasSeenOnboarding;
  
  final String userName;
  final String gender;
  final DateTime? dateOfBirth;
  final String mainGoal;
  final String activityLevel;
  final double targetWeight;
  final DateTime? targetDate;
  final String workoutEnvironment;
  final String dietaryPreference;
  final String medicalConditions;

  UserProfile({
    this.weight = 70.0,
    this.height = 170.0,
    this.isKgMode = true,
    this.isCmMode = true,
    this.isPremium = false,
    this.hasSeenOnboarding = false,
    this.userName = "ATHLETE",
    this.gender = 'Not Specified',
    this.dateOfBirth,
    this.mainGoal = 'Stay Healthy',
    this.activityLevel = 'Lightly Active',
    this.targetWeight = 0.0,
    this.targetDate,
    this.workoutEnvironment = 'Home',
    this.dietaryPreference = 'Normal',
    this.medicalConditions = 'None',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      height: (json['height'] as num?)?.toDouble() ?? 170.0,
      isKgMode: json['is_kg_mode'] ?? true,
      isCmMode: json['is_cm_mode'] ?? true,
      isPremium: json['is_premium'] ?? false,
      hasSeenOnboarding: json['has_seen_onboarding'] ?? false,
      userName: json['user_name'] ?? "ATHLETE",
      gender: json['profile_gender'] ?? 'Not Specified',
      dateOfBirth: json['profile_dob'] != null ? DateTime.tryParse(json['profile_dob']) : null,
      mainGoal: json['profile_mainGoal'] ?? 'Stay Healthy',
      activityLevel: json['profile_activityLevel'] ?? 'Lightly Active',
      targetWeight: (json['profile_targetWeight'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['profile_targetDate'] != null ? DateTime.tryParse(json['profile_targetDate']) : null,
      workoutEnvironment: json['profile_workoutEnvironment'] ?? 'Home',
      dietaryPreference: json['profile_dietaryPreference'] ?? 'Normal',
      medicalConditions: json['profile_medicalConditions'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'is_kg_mode': isKgMode,
      'is_cm_mode': isCmMode,
      'is_premium': isPremium,
      'has_seen_onboarding': hasSeenOnboarding,
      'user_name': userName,
      'profile_gender': gender,
      'profile_dob': dateOfBirth?.toIso8601String(),
      'profile_mainGoal': mainGoal,
      'profile_activityLevel': activityLevel,
      'profile_targetWeight': targetWeight,
      'profile_targetDate': targetDate?.toIso8601String(),
      'profile_workoutEnvironment': workoutEnvironment,
      'profile_dietaryPreference': dietaryPreference,
      'profile_medicalConditions': medicalConditions,
    };
  }

  UserProfile copyWith({
    double? weight,
    double? height,
    bool? isKgMode,
    bool? isCmMode,
    bool? isPremium,
    bool? hasSeenOnboarding,
    String? userName,
    String? gender,
    DateTime? dateOfBirth,
    String? mainGoal,
    String? activityLevel,
    double? targetWeight,
    DateTime? targetDate,
    String? workoutEnvironment,
    String? dietaryPreference,
    String? medicalConditions,
  }) {
    return UserProfile(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      isKgMode: isKgMode ?? this.isKgMode,
      isCmMode: isCmMode ?? this.isCmMode,
      isPremium: isPremium ?? this.isPremium,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      userName: userName ?? this.userName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      mainGoal: mainGoal ?? this.mainGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      workoutEnvironment: workoutEnvironment ?? this.workoutEnvironment,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }
}
