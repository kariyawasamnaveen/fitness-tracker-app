// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/health.dart';
import '../models/fitness_progress.dart';
import '../utils/date_utility.dart';

class FitnessDataProvider with ChangeNotifier {
  FitnessProgress _progress = FitnessProgress();
  bool _isInitialized = false;
  int _todaySteps = 0;
  final Health _health = Health();

  FitnessProgress get progress => _progress;
  bool get isInitialized => _isInitialized;
  int get todaySteps => _todaySteps;

  FitnessDataProvider() {
    _init();
  }

  Future<void> _init() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        _progress = FitnessProgress(startDate: DateTime.now());
        notifyListeners();
      } else {
        await _fetchFromCloud(user);
      }
    });

    final initialUser = await FirebaseAuth.instance.authStateChanges().first;
    if (initialUser != null) {
      await _fetchFromCloud(initialUser);
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _fetchFromCloud(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _progress = FitnessProgress.fromJson(data);
        _updateBestStreak();
      } else {
        await _syncToCloud();
      }

      if (_progress.isGoogleFitConnected) {
        autoFetchGoogleFitSteps();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _syncToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          _progress.toJson(), 
          SetOptions(merge: true)
        );
      } catch (_) {}
    }
  }

  int get daysPassed {
    if (_progress.startDate == null) return 0;
    return DateUtility.getDaysPassed(_progress.startDate!);
  }

  int get totalCompletedDays => _progress.completedDays.length;

  bool isDayCompleted(DateTime date) {
    String dateKey = _getDateKey(date);
    return _progress.completedDays.contains(dateKey);
  }

  Future<void> toggleCompletion(DateTime date) async {
    String dateKey = _getDateKey(date);
    List<String> newCompleted = List.from(_progress.completedDays);
    if (newCompleted.contains(dateKey)) {
      newCompleted.remove(dateKey);
    } else {
      newCompleted.add(dateKey);
    }

    _progress = _progress.copyWith(completedDays: newCompleted);
    _updateBestStreak();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('completed_days', newCompleted);
      await prefs.setInt('best_streak', _progress.bestStreak);
      await _syncToCloud();
    } catch (_) {}
  }

  void _updateBestStreak() {
    if (_progress.completedDays.isEmpty) {
      _progress = _progress.copyWith(bestStreak: 0);
      return;
    }
    
    List<DateTime> sortedDates = _progress.completedDays.map((d) {
      List<String> parts = d.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList();
    
    sortedDates.sort((a, b) => a.compareTo(b));
    
    int maxStreak = 1;
    int current = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      DateTime expectedNext = sortedDates[i-1].add(const Duration(days: 1));
      if (sortedDates[i].year == expectedNext.year && 
          sortedDates[i].month == expectedNext.month && 
          sortedDates[i].day == expectedNext.day) {
        current++;
      } else {
        if (current > maxStreak) maxStreak = current;
        current = 1;
      }
    }
    if (current > maxStreak) maxStreak = current;
    
    _progress = _progress.copyWith(bestStreak: maxStreak);
  }

  int get streakCount {
    if (_progress.completedDays.isEmpty) return 0;
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    if (isDayCompleted(checkDate)) {
      streak++;
    } else {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (!isDayCompleted(checkDate)) return 0;
      streak++;
    }

    while (true) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (isDayCompleted(checkDate)) {
        streak++;
      } else {
        break;
      }
      if (streak > 365 * 2) break; 
    }
    
    return streak;
  }

  Future<void> resetProgress() async {
    _progress = _progress.copyWith(
      startDate: DateTime.now(),
      completedDays: [],
      bestStreak: 0,
    );
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('start_date', _progress.startDate!.toIso8601String());
      await prefs.setStringList('completed_days', []);
      await prefs.setInt('best_streak', 0);
      await _syncToCloud();
    } catch (_) {}
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<void> connectGoogleFit() async {
    try {
      if (_progress.isGoogleFitConnected) {
        _progress = _progress.copyWith(isGoogleFitConnected: false);
        _todaySteps = 0;
        await _syncToCloud();
        notifyListeners();
        return;
      }

      var types = [HealthDataType.STEPS];
      _health.configure();
      bool hasPermissions = await _health.requestAuthorization(types);
      
      if (hasPermissions) {
        _progress = _progress.copyWith(isGoogleFitConnected: true);
        await _syncToCloud();
        await _fetchTodaySteps();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> autoFetchGoogleFitSteps() async {
    if (!_progress.isGoogleFitConnected) return;
    try {
      _health.configure();
      bool hasPermissions = await _health.requestAuthorization([HealthDataType.STEPS]);
      if (hasPermissions) {
        await _fetchTodaySteps();
      }
    } catch (_) {}
  }

  Future<void> _fetchTodaySteps() async {
    if (!_progress.isGoogleFitConnected) return;
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      if (steps != null) {
        _todaySteps = steps;
        notifyListeners();
      }
    } catch (_) {}
  }

  String get fitnessLevelBadge {
    if (_progress.bestStreak >= 30 || _progress.completedDays.length >= 100) return '🏅 Elite';
    if (_progress.bestStreak >= 14 || _progress.completedDays.length >= 50) return '🏆 Pro';
    if (_progress.bestStreak >= 7 || _progress.completedDays.length >= 20) return '⭐ Intermediate';
    return '🔥 Beginner';
  }

  int get pushUpsCount => DateUtility.calculatePushUps(totalCompletedDays);
  int get squatsCount => DateUtility.calculateSquats(totalCompletedDays);
  int get joggingRounds => DateUtility.calculateJoggingRounds(totalCompletedDays);
  int get sprintsCount => DateUtility.calculateSprints(totalCompletedDays);
  int get jumpingJacksCount => DateUtility.getJumpingJacks();
}
