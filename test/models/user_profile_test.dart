import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('fromJson correctly parses valid data', () {
      final json = {
        'weight': 75.5,
        'height': 180.0,
        'is_kg_mode': false,
        'is_cm_mode': true,
        'is_premium': true,
        'has_seen_onboarding': true,
        'user_name': 'Test User',
        'profile_gender': 'Male',
        'profile_dob': '1990-01-01T00:00:00.000Z',
        'profile_mainGoal': 'Lose Weight',
        'profile_activityLevel': 'Highly Active',
        'profile_targetWeight': 70.0,
        'profile_targetDate': '2027-01-01T00:00:00.000Z',
        'profile_workoutEnvironment': 'Gym',
        'profile_dietaryPreference': 'Vegan',
        'profile_medicalConditions': 'Asthma',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.weight, 75.5);
      expect(profile.height, 180.0);
      expect(profile.isKgMode, false);
      expect(profile.isCmMode, true);
      expect(profile.isPremium, true);
      expect(profile.hasSeenOnboarding, true);
      expect(profile.userName, 'Test User');
      expect(profile.gender, 'Male');
      expect(profile.dateOfBirth?.year, 1990);
      expect(profile.mainGoal, 'Lose Weight');
      expect(profile.activityLevel, 'Highly Active');
      expect(profile.targetWeight, 70.0);
      expect(profile.targetDate?.year, 2027);
      expect(profile.workoutEnvironment, 'Gym');
      expect(profile.dietaryPreference, 'Vegan');
      expect(profile.medicalConditions, 'Asthma');
    });

    test('toJson correctly serializes model', () {
      final profile = UserProfile(
        weight: 65.0,
        userName: 'Alice',
        isPremium: false,
        dateOfBirth: DateTime(2000, 5, 20),
      );

      final json = profile.toJson();

      expect(json['weight'], 65.0);
      expect(json['user_name'], 'Alice');
      expect(json['is_premium'], false);
      expect(json['profile_dob'], DateTime(2000, 5, 20).toIso8601String());
    });

    test('copyWith updates properties correctly', () {
      final profile = UserProfile(weight: 70.0, userName: 'Bob');
      final updated = profile.copyWith(weight: 68.0, isPremium: true);

      expect(updated.weight, 68.0);
      expect(updated.isPremium, true);
      expect(updated.userName, 'Bob'); // Should remain unchanged
    });
  });
}
