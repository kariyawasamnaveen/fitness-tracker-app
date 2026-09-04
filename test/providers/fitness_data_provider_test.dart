import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitness_tracker/providers/fitness_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FitnessDataProvider Tests', () {
    test('Initializes with default progress', () {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();
      final provider = FitnessDataProvider(auth: mockAuth, firestore: mockFirestore);
      
      expect(provider.progress.completedDays, isEmpty);
      expect(provider.progress.bestStreak, 0);
      expect(provider.totalCompletedDays, 0);
      expect(provider.streakCount, 0);
    });

    test('toggleCompletion adds and removes a date correctly', () async {
      final mockAuth = MockFirebaseAuth(signedIn: true);
      final mockFirestore = FakeFirebaseFirestore();
      final provider = FitnessDataProvider(auth: mockAuth, firestore: mockFirestore);
      
      final testDate = DateTime(2026, 9, 1);
      
      // Initially not completed
      expect(provider.isDayCompleted(testDate), false);
      
      // Toggle to complete
      await provider.toggleCompletion(testDate);
      expect(provider.isDayCompleted(testDate), true);
      expect(provider.totalCompletedDays, 1);
      
      // Verify sync to firestore (FitnessDataProvider syncs to 'users' collection)
      final doc = await mockFirestore.collection('users').doc(mockAuth.currentUser!.uid).get();
      expect(doc.data()?['completed_days'], contains('2026-9-1'));
      
      // Toggle to incomplete
      await provider.toggleCompletion(testDate);
      expect(provider.isDayCompleted(testDate), false);
      expect(provider.totalCompletedDays, 0);
    });

    test('fitnessLevelBadge returns correct badge based on points', () {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();
      final provider = FitnessDataProvider(auth: mockAuth, firestore: mockFirestore);
      
      // 0 days completed -> Beginner
      expect(provider.fitnessLevelBadge, '🔥 Beginner');
      
      // Toggle 8 days to reach Intermediate (streak > 7)
      for (int i = 1; i <= 8; i++) {
        provider.toggleCompletion(DateTime(2026, 1, i));
      }
      
      expect(provider.fitnessLevelBadge, '⭐ Intermediate');
    });
  });
}
