import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import '../utils/date_utility.dart';
import '../utils/notification_service.dart';

class FitnessProvider with ChangeNotifier {
  DateTime? _startDate;
  Set<String> _completedDays = {};
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _hasSeenOnboarding = false;
  bool _isGoogleLinked = false;
  bool _isGoogleFitConnected = false;
  int _todaySteps = 0;

  bool _motivationEnabled = false;
  bool _workoutReminderEnabled = false;
  bool _streakSaverEnabled = false;
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 18, minute: 0);

  // Security & Privacy
  bool _isAppLockEnabled = false;
  bool _shareAnalyticsData = true;
  bool _isAuthenticated = false;

  // Health
  final Health _health = Health();
  
  // Settings
  double _weight = 70.0;
  double _height = 170.0;
  bool _isKgMode = true;
  bool _isCmMode = true;
  
  // Subscription
  bool _isPremium = false;

  int _bestStreak = 0;
  String _userName = "ATHLETE";
  String _userEmail = "";
  int _maxSquats = 0;
  int _maxPushups = 0;

  // Advanced Profile Info
  String _gender = 'Not Specified';
  DateTime? _dateOfBirth;
  String _mainGoal = 'Stay Healthy';
  String _activityLevel = 'Lightly Active';
  double _targetWeight = 0.0;
  DateTime? _targetDate;
  String _workoutEnvironment = 'Home';
  String _dietaryPreference = 'Normal';
  String _medicalConditions = 'None';

  DateTime? get startDate => _startDate;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isGoogleLinked => _isGoogleLinked;
  bool get isGoogleFitConnected => _isGoogleFitConnected;
  int get todaySteps => _todaySteps;
  bool get isPremium => _isPremium;
  
  double get weight => _weight;
  double get height => _height;
  bool get isKgMode => _isKgMode;
  bool get isCmMode => _isCmMode;

  int get bestStreak => _bestStreak;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get maxSquats => _maxSquats;
  int get maxPushups => _maxPushups;

  // Advanced Profile Getters
  String get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get mainGoal => _mainGoal;
  String get activityLevel => _activityLevel;
  double get targetWeight => _targetWeight;
  DateTime? get targetDate => _targetDate;
  String get workoutEnvironment => _workoutEnvironment;
  String get dietaryPreference => _dietaryPreference;
  String get medicalConditions => _medicalConditions;

  // Dynamic Fitness Level Badge
  String get fitnessLevelBadge {
    if (_bestStreak >= 30 || _completedDays.length >= 100) return '🏅 Elite';
    if (_bestStreak >= 14 || _completedDays.length >= 50) return '🏆 Pro';
    if (_bestStreak >= 7 || _completedDays.length >= 20) return '⭐ Intermediate';
    return '🔥 Beginner';
  }
  
  bool get motivationEnabled => _motivationEnabled;
  bool get workoutReminderEnabled => _workoutReminderEnabled;
  bool get streakSaverEnabled => _streakSaverEnabled;
  TimeOfDay get workoutReminderTime => _workoutReminderTime;

  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get shareAnalyticsData => _shareAnalyticsData;
  bool get isAuthenticated => _isAuthenticated;

  FitnessProvider() {
    _init();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<void> toggleAppLock(bool value) async {
    _isAppLockEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', value);
    notifyListeners();
  }

  Future<void> toggleAnalytics(bool value) async {
    _shareAnalyticsData = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('share_analytics', value);
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
    _userName = name;
    _gender = gender;
    _dateOfBirth = dateOfBirth;
    _mainGoal = mainGoal;
    _activityLevel = activityLevel;
    _targetWeight = targetWeight;
    _targetDate = targetDate;
    _workoutEnvironment = workoutEnvironment;
    _dietaryPreference = dietaryPreference;
    _medicalConditions = medicalConditions;
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
    
    _syncToCloud();
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

  Future<void> _syncToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'start_date': _startDate?.toIso8601String(),
          'completed_days': _completedDays.toList(),
          'best_streak': _bestStreak,
          'has_seen_onboarding': _hasSeenOnboarding,
          'google_fit_connected': _isGoogleFitConnected,
          'weight': _weight,
          'height': _height,
          'is_kg_mode': _isKgMode,
          'is_cm_mode': _isCmMode,
          'is_premium': _isPremium,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error syncing to cloud: $e");
      }
    }
  }

  Future<void> _fetchFromCloud(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['start_date'] != null) {
          _startDate = DateTime.parse(data['start_date']);
        }
        if (data['completed_days'] != null) {
          _completedDays = (data['completed_days'] as List).map((e) => e.toString()).toSet();
        }
        if (data['best_streak'] != null) {
          _bestStreak = data['best_streak'];
        }
        if (data['has_seen_onboarding'] != null) {
          _hasSeenOnboarding = data['has_seen_onboarding'];
        }
        if (data['google_fit_connected'] != null) {
          _isGoogleFitConnected = data['google_fit_connected'];
        }
        if (data['weight'] != null) {
          _weight = (data['weight'] as num).toDouble();
        }
        if (data['height'] != null) {
          _height = (data['height'] as num).toDouble();
        }
        if (data['is_kg_mode'] != null) {
          _isKgMode = data['is_kg_mode'];
        }
        if (data['is_cm_mode'] != null) {
          _isCmMode = data['is_cm_mode'];
        }
        if (data['is_premium'] != null) {
          _isPremium = data['is_premium'];
        }
        _updateBestStreak();
      } else {
        // New user, sync initial defaults to cloud
        await _syncToCloud();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching from cloud: $e");
    }
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load onboarding state locally first as fallback
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    // Load notification preferences
    _motivationEnabled = prefs.getBool('motivation_enabled') ?? false;
    _workoutReminderEnabled = prefs.getBool('workout_reminder_enabled') ?? false;
    _streakSaverEnabled = prefs.getBool('streak_saver_enabled') ?? false;
    int hour = prefs.getInt('reminder_hour') ?? 18;
    int minute = prefs.getInt('reminder_minute') ?? 0;
    _workoutReminderTime = TimeOfDay(hour: hour, minute: minute);

    // Load security preferences
    _isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    _shareAnalyticsData = prefs.getBool('share_analytics') ?? true;
    _isAuthenticated = !_isAppLockEnabled; // If lock is disabled, already authenticated

    // Load advanced profile preferences
    _gender = prefs.getString('profile_gender') ?? 'Not Specified';
    final dobStr = prefs.getString('profile_dob');
    if (dobStr != null) _dateOfBirth = DateTime.parse(dobStr);
    _mainGoal = prefs.getString('profile_mainGoal') ?? 'Stay Healthy';
    _activityLevel = prefs.getString('profile_activityLevel') ?? 'Lightly Active';
    _targetWeight = prefs.getDouble('profile_targetWeight') ?? 0.0;
    final tdStr = prefs.getString('profile_targetDate');
    if (tdStr != null) _targetDate = DateTime.parse(tdStr);
    _workoutEnvironment = prefs.getString('profile_workoutEnvironment') ?? 'Home';
    _dietaryPreference = prefs.getString('profile_dietaryPreference') ?? 'Normal';
    _medicalConditions = prefs.getString('profile_medicalConditions') ?? 'None';

    // Listen to Firebase Auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        _isLoggedIn = false;
        _userName = "ATHLETE";
        _userEmail = "";
        
        // Clear progress when logged out
        _completedDays.clear();
        _startDate = DateTime.now();
        _bestStreak = 0;
        notifyListeners();
      } else {
        _isLoggedIn = true;
        _userName = user.displayName ?? prefs.getString('user_name') ?? "ATHLETE";
        _userEmail = user.email ?? "";
        
        // Check if Google is linked
        _isGoogleLinked = user.providerData.any((userInfo) => userInfo.providerId == 'google.com');
        
        notifyListeners(); // Broadcast login state immediately for fast UI navigation
        
        // Fetch real progress from Firestore!
        await _fetchFromCloud(user);
      }
    });

    _isInitialized = true;
    notifyListeners();
  }

  int get daysPassed {
    if (_startDate == null) return 0;
    return DateUtility.getDaysPassed(_startDate!);
  }

  int get totalCompletedDays => _completedDays.length;

  bool isDayCompleted(DateTime date) {
    String dateKey = _getDateKey(date);
    return _completedDays.contains(dateKey);
  }

  Future<void> toggleCompletion(DateTime date) async {
    String dateKey = _getDateKey(date);
    if (_completedDays.contains(dateKey)) {
      _completedDays.remove(dateKey);
    } else {
      _completedDays.add(dateKey);
    }

    _updateBestStreak();
    
    notifyListeners(); // Immediate UI update (Optimistic UI)

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('completed_days', _completedDays.toList());
      await prefs.setInt('best_streak', _bestStreak);
      
      await _syncToCloud();
    } catch (e) {
      debugPrint("Error saving completion state: $e");
    }
  }

  void _updateBestStreak() {
    if (_completedDays.isEmpty) {
      _bestStreak = 0;
      return;
    }
    
    List<DateTime> sortedDates = _completedDays.map((d) {
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
    
    _bestStreak = maxStreak;
  }

  int get streakCount {
    if (_completedDays.isEmpty) return 0;
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Check today first
    if (isDayCompleted(checkDate)) {
      streak++;
    } else {
      // If today is not done, check if yesterday was done to continue a streak
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (!isDayCompleted(checkDate)) return 0;
      streak++;
    }

    // Keep checking previous days
    while (true) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (isDayCompleted(checkDate)) {
        streak++;
      } else {
        break;
      }
      
      // Safety break for extremely long streaks (optional)
      if (streak > 365 * 2) break; 
    }
    
    return streak;
  }

  Future<void> resetProgress() async {
    _startDate = DateTime.now();
    _completedDays.clear();
    _bestStreak = 0;
    
    notifyListeners(); // Optimistic UI update for instant feedback
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('start_date', _startDate!.toIso8601String());
      await prefs.setStringList('completed_days', []);
      await prefs.setInt('best_streak', 0);
      
      await _syncToCloud();
    } catch (e) {
      debugPrint("Error resetting progress: $e");
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    
    await _syncToCloud();
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Firebase Error: ${e.code}");
      return e.message;
    } catch (e) {
      debugPrint("Login error: $e");
      return "An unknown error occurred.";
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Sign-in canceled by user.';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _isGoogleLinked = true;
      
      // Save locally as fallback
      if (userCredential.user?.displayName != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userCredential.user!.displayName!);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Google Sign-In Firebase Error: ${e.code} - ${e.message}");
      return 'Firebase Error: ${e.message}';
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return e.toString();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Save locally as fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      
      return true;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint("Google sign out error: $e");
    }
  }

  Future<String?> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
        
        _isLoggedIn = false;
        _isGoogleLinked = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        notifyListeners();
        
        return null; // null means success
      }
      return "No user logged in.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return "For security reasons, please log out and log in again before deleting your account.";
      }
      return e.message ?? "An error occurred during account deletion.";
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> linkGoogleAccount() async {
    debugPrint("[DEBUG] fitness_provider: linkGoogleAccount() called.");
    try {
      debugPrint("[DEBUG] Calling GoogleSignIn().signIn()...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      debugPrint("[DEBUG] GoogleSignIn returned: $googleUser");
      
      if (googleUser == null) {
        debugPrint("[DEBUG] googleUser is null, user cancelled or it failed silently.");
        return false;
      }

      debugPrint("[DEBUG] Requesting googleUser.authentication...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint("[DEBUG] googleAuth received.");
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = FirebaseAuth.instance.currentUser;
      debugPrint("[DEBUG] Current Firebase User: ${user?.uid}");
      
      if (user != null) {
        debugPrint("[DEBUG] Calling user.linkWithCredential()...");
        await user.linkWithCredential(credential);
        debugPrint("[DEBUG] Credentials linked successfully.");
        
        _isGoogleLinked = true;
        notifyListeners();
        return true;
      }
      debugPrint("[DEBUG] Current user is null, returning false.");
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("[DEBUG] Firebase Auth Error linking Google account: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      debugPrint("[DEBUG] Error linking Google account: $e");
      return false;
    }
  }

  Future<bool> unlinkGoogleAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.unlink('google.com');
        _isGoogleLinked = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error unlinking Google account: $e");
      return false;
    }
  }

  Future<void> connectGoogleFit() async {
    debugPrint("[DEBUG] fitness_provider: connectGoogleFit() called.");
    try {
      if (_isGoogleFitConnected) {
        debugPrint("[DEBUG] Already connected, disconnecting now...");
        _isGoogleFitConnected = false;
        _todaySteps = 0;
        await _syncToCloud();
        notifyListeners();
        return;
      }

      debugPrint("[DEBUG] Preparing HealthDataType.STEPS...");
      var types = [HealthDataType.STEPS];
      
      debugPrint("[DEBUG] Configuring Health package for Health Connect...");
      _health.configure();
      
      debugPrint("[DEBUG] Calling _health.requestAuthorization()...");
      bool hasPermissions = await _health.requestAuthorization(types);
      debugPrint("[DEBUG] requestAuthorization returned: $hasPermissions");
      
      if (hasPermissions) {
        debugPrint("[DEBUG] Permissions granted. Syncing to cloud and fetching steps...");
        _isGoogleFitConnected = true;
        await _syncToCloud();
        await _fetchTodaySteps();
        notifyListeners();
      } else {
        debugPrint("[DEBUG] Authorization not granted for Health Connect");
      }
    } catch (e) {
      debugPrint("[DEBUG] Error connecting to Google Fit: $e");
    }
  }

  Future<void> _fetchTodaySteps() async {
    if (!_isGoogleFitConnected) return;
    
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      if (steps != null) {
        _todaySteps = steps;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching steps: $e");
    }
  }

  // Settings Methods
  Future<void> updateWeight(double newWeight) async {
    _weight = newWeight;
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> updateHeight(double newHeight) async {
    _height = newHeight;
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> toggleWeightUnit(bool isKg) async {
    _isKgMode = isKg;
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> toggleHeightUnit(bool isCm) async {
    _isCmMode = isCm;
    await _syncToCloud();
    notifyListeners();
  }

  // Subscription Mock Method (Until Stripe is added)
  Future<void> upgradeToPremium() async {
    _isPremium = true;
    await _syncToCloud();
    notifyListeners();
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  // Calculated values for the UI
  int get pushUpsCount => DateUtility.calculatePushUps(totalCompletedDays);
  int get squatsCount => DateUtility.calculateSquats(totalCompletedDays);
  int get joggingRounds => DateUtility.calculateJoggingRounds(totalCompletedDays);
  int get sprintsCount => DateUtility.calculateSprints(totalCompletedDays);
  int get jumpingJacksCount => DateUtility.getJumpingJacks();
}
