import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitness_tracker/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider Tests', () {
    test('Initializes with default profile', () {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();
      final provider = SettingsProvider(auth: mockAuth, firestore: mockFirestore);
      
      expect(provider.profile.isKgMode, isA<bool>());
      expect(provider.profile.isCmMode, isA<bool>());
    });

    test('toggleWeightUnit updates state and syncs', () async {
      final mockAuth = MockFirebaseAuth(signedIn: true);
      final mockFirestore = FakeFirebaseFirestore();
      final provider = SettingsProvider(auth: mockAuth, firestore: mockFirestore);
      
      await provider.toggleWeightUnit(true);
      
      expect(provider.profile.isKgMode, true);
      
      final doc = await mockFirestore.collection('users').doc(mockAuth.currentUser!.uid).get();
      expect(doc.data()?['is_kg_mode'], true);
    });

    test('updateWeight and updateHeight sync', () async {
      final mockAuth = MockFirebaseAuth(signedIn: true);
      final mockFirestore = FakeFirebaseFirestore();
      final provider = SettingsProvider(auth: mockAuth, firestore: mockFirestore);
      
      await provider.updateWeight(85.5);
      await provider.updateHeight(180.0);
      
      expect(provider.profile.weight, 85.5);
      
      final doc = await mockFirestore.collection('users').doc(mockAuth.currentUser!.uid).get();
      expect(doc.data()?['weight'], 85.5);
      expect(doc.data()?['height'], 180.0);
    });

    test('completeOnboarding updates state and syncs', () async {
      final mockAuth = MockFirebaseAuth(signedIn: true);
      final mockFirestore = FakeFirebaseFirestore();
      final provider = SettingsProvider(auth: mockAuth, firestore: mockFirestore);
      
      await provider.completeOnboarding();
      
      expect(provider.profile.hasSeenOnboarding, true);
      
      final doc = await mockFirestore.collection('users').doc(mockAuth.currentUser!.uid).get();
      expect(doc.data()?['has_seen_onboarding'], true);
    });
  });
}
