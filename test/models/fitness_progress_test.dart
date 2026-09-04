import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/models/fitness_progress.dart';

void main() {
  group('FitnessProgress Model Tests', () {
    test('fromJson correctly parses data', () {
      final json = {
        'start_date': '2026-09-01T00:00:00.000Z',
        'completed_days': ['2026-9-1', '2026-9-2'],
        'best_streak': 5,
        'google_fit_connected': true,
        'max_squats': 50,
        'max_pushups': 30,
      };

      final progress = FitnessProgress.fromJson(json);

      expect(progress.startDate?.year, 2026);
      expect(progress.completedDays.length, 2);
      expect(progress.completedDays, contains('2026-9-1'));
      expect(progress.bestStreak, 5);
      expect(progress.isGoogleFitConnected, true);
      expect(progress.maxSquats, 50);
      expect(progress.maxPushups, 30);
    });

    test('toJson correctly serializes data', () {
      final date = DateTime(2026, 9, 1);
      final progress = FitnessProgress(
        startDate: date,
        completedDays: ['2026-9-1'],
        bestStreak: 2,
        isGoogleFitConnected: false,
      );

      final json = progress.toJson();

      expect(json['start_date'], date.toIso8601String());
      expect(json['completed_days'], ['2026-9-1']);
      expect(json['best_streak'], 2);
      expect(json['google_fit_connected'], false);
    });

    test('copyWith updates properties correctly', () {
      final progress = FitnessProgress(bestStreak: 10, maxSquats: 20);
      final updated = progress.copyWith(bestStreak: 15, isGoogleFitConnected: true);

      expect(updated.bestStreak, 15);
      expect(updated.isGoogleFitConnected, true);
      expect(updated.maxSquats, 20); // Should remain unchanged
    });
  });
}
