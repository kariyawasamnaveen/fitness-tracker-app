// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/user_profile.dart';
import '../utils/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  UserProfile _profile = UserProfile();
  bool _isInitialized = false;
  bool _shareAnalyticsData = true;

  bool _motivationEnabled = false;
  bool _workoutReminderEnabled = false;
  bool _streakSaverEnabled = false;
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 18, minute: 0);

  UserProfile get profile => _profile;
  bool get isInitialized => _isInitialized;
  bool get shareAnalyticsData => _shareAnalyticsData;

  bool get motivationEnabled => _motivationEnabled;
  bool get workoutReminderEnabled => _workoutReminderEnabled;
  bool get streakSaverEnabled => _streakSaverEnabled;
  TimeOfDay get workoutReminderTime => _workoutReminderTime;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SettingsProvider({FirebaseAuth? auth, FirebaseFirestore? firestore}) 
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    _motivationEnabled = prefs.getBool('motivation_enabled') ?? false;
    _workoutReminderEnabled = prefs.getBool('workout_reminder_enabled') ?? false;
    _streakSaverEnabled = prefs.getBool('streak_saver_enabled') ?? false;
    int hour = prefs.getInt('reminder_hour') ?? 18;
    int minute = prefs.getInt('reminder_minute') ?? 0;
    _workoutReminderTime = TimeOfDay(hour: hour, minute: minute);
    _shareAnalyticsData = prefs.getBool('share_analytics') ?? true;

    // Load initial local profile
    _profile = _profile.copyWith(
      hasSeenOnboarding: prefs.getBool('has_seen_onboarding') ?? false,
      gender: prefs.getString('profile_gender'),
      dateOfBirth: prefs.getString('profile_dob') != null ? DateTime.tryParse(prefs.getString('profile_dob')!) : null,
      mainGoal: prefs.getString('profile_mainGoal'),
      activityLevel: prefs.getString('profile_activityLevel'),
      targetWeight: prefs.getDouble('profile_targetWeight'),
      targetDate: prefs.getString('profile_targetDate') != null ? DateTime.tryParse(prefs.getString('profile_targetDate')!) : null,
      workoutEnvironment: prefs.getString('profile_workoutEnvironment'),
      dietaryPreference: prefs.getString('profile_dietaryPreference'),
      medicalConditions: prefs.getString('profile_medicalConditions'),
    );

    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        _profile = UserProfile(); // Reset on logout
        notifyListeners();
      } else {
        await _fetchFromCloud(user);
      }
    });

    final initialUser = await _auth.authStateChanges().first;
    if (initialUser != null) {
      await _fetchFromCloud(initialUser);
    }
    
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all['elite']?.isActive == true) {
        _profile = _profile.copyWith(isPremium: true);
      }
    } catch (_) {}

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _fetchFromCloud(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _profile = UserProfile.fromJson(data);
      } else {
        await _syncToCloud();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _syncToCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set(
          _profile.toJson(), 
          SetOptions(merge: true)
        );
      } catch (_) {}
    }
  }

  Future<void> toggleAnalytics(bool value) async {
    _shareAnalyticsData = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('share_analytics', value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    _profile = _profile.copyWith(hasSeenOnboarding: true);
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> updateAdvancedProfile({
    required String name,
    required String gender,
    required DateTime? dateOfBirth,
    required String mainGoal,
    required String activityLevel,
    required double targetWeight,
    required DateTime? targetDate,
    required String workoutEnvironment,
    required String dietaryPreference,
    required String medicalConditions,
  }) async {
    _profile = _profile.copyWith(
      userName: name,
      gender: gender,
      dateOfBirth: dateOfBirth,
      mainGoal: mainGoal,
      activityLevel: activityLevel,
      targetWeight: targetWeight,
      targetDate: targetDate,
      workoutEnvironment: workoutEnvironment,
      dietaryPreference: dietaryPreference,
      medicalConditions: medicalConditions,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('profile_gender', gender);
    if (dateOfBirth != null) await prefs.setString('profile_dob', dateOfBirth.toIso8601String());
    await prefs.setString('profile_mainGoal', mainGoal);
    await prefs.setString('profile_activityLevel', activityLevel);
    await prefs.setDouble('profile_targetWeight', targetWeight);
    if (targetDate != null) await prefs.setString('profile_targetDate', targetDate.toIso8601String());
    await prefs.setString('profile_workoutEnvironment', workoutEnvironment);
    await prefs.setString('profile_dietaryPreference', dietaryPreference);
    await prefs.setString('profile_medicalConditions', medicalConditions);
    
    await _syncToCloud();
  }

  Future<void> toggleMotivation(bool value) async {
    _motivationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('motivation_enabled', value);
    if (value) {
      await NotificationService.scheduleMotivationQuotes();
    } else {
      await NotificationService.cancelAllMotivationQuotes();
    }
    notifyListeners();
  }

  Future<void> toggleWorkoutReminder(bool value) async {
    _workoutReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('workout_reminder_enabled', value);
    if (value) {
      await NotificationService.scheduleWorkoutReminder(_workoutReminderTime.hour, _workoutReminderTime.minute);
    } else {
      await NotificationService.cancelNotification(NotificationService.workoutReminderId);
    }
    notifyListeners();
  }

  Future<void> updateWorkoutReminderTime(TimeOfDay newTime) async {
    _workoutReminderTime = newTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', newTime.hour);
    await prefs.setInt('reminder_minute', newTime.minute);
    if (_workoutReminderEnabled) {
      await NotificationService.scheduleWorkoutReminder(newTime.hour, newTime.minute);
    }
    notifyListeners();
  }

  Future<void> toggleStreakSaver(bool value) async {
    _streakSaverEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streak_saver_enabled', value);
    if (value) {
      await NotificationService.scheduleStreakSaver();
    } else {
      await NotificationService.cancelNotification(NotificationService.streakSaverId);
    }
    notifyListeners();
  }

  Future<void> updateWeight(double newWeight) async {
    _profile = _profile.copyWith(weight: newWeight);
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> updateHeight(double newHeight) async {
    _profile = _profile.copyWith(height: newHeight);
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> toggleWeightUnit(bool isKg) async {
    _profile = _profile.copyWith(isKgMode: isKg);
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> toggleHeightUnit(bool isCm) async {
    _profile = _profile.copyWith(isCmMode: isCm);
    await _syncToCloud();
    notifyListeners();
  }

  Future<bool> upgradeToPremium() async {
    _profile = _profile.copyWith(isPremium: true);
    await _syncToCloud();
    notifyListeners();
    return true;
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.all['elite']?.isActive == true) {
        await upgradeToPremium();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
