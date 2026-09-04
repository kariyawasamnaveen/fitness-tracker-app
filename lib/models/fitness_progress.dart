// ignore_for_file: unused_local_variable, use_build_context_synchronously
class FitnessProgress {
  final DateTime? startDate;
  final List<String> completedDays;
  final int bestStreak;
  final bool isGoogleFitConnected;
  final int maxSquats;
  final int maxPushups;

  FitnessProgress({
    this.startDate,
    this.completedDays = const [],
    this.bestStreak = 0,
    this.isGoogleFitConnected = false,
    this.maxSquats = 0,
    this.maxPushups = 0,
  });

  factory FitnessProgress.fromJson(Map<String, dynamic> json) {
    return FitnessProgress(
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      completedDays: json['completed_days'] != null ? List<String>.from(json['completed_days']) : [],
      bestStreak: json['best_streak'] ?? 0,
      isGoogleFitConnected: json['google_fit_connected'] ?? false,
      maxSquats: json['max_squats'] ?? 0,
      maxPushups: json['max_pushups'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate?.toIso8601String(),
      'completed_days': completedDays,
      'best_streak': bestStreak,
      'google_fit_connected': isGoogleFitConnected,
      'max_squats': maxSquats,
      'max_pushups': maxPushups,
    };
  }

  FitnessProgress copyWith({
    DateTime? startDate,
    List<String>? completedDays,
    int? bestStreak,
    bool? isGoogleFitConnected,
    int? maxSquats,
    int? maxPushups,
  }) {
    return FitnessProgress(
      startDate: startDate ?? this.startDate,
      completedDays: completedDays ?? this.completedDays,
      bestStreak: bestStreak ?? this.bestStreak,
      isGoogleFitConnected: isGoogleFitConnected ?? this.isGoogleFitConnected,
      maxSquats: maxSquats ?? this.maxSquats,
      maxPushups: maxPushups ?? this.maxPushups,
    );
  }
}
