// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/fitness_data_provider.dart';
import '../widgets/exercise_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE6), // Premium bottom cream background
      body: Consumer3<AuthProvider, SettingsProvider, FitnessDataProvider>(
        builder: (context, authProvider, settingsProvider, fitnessProvider, child) {
          if (!(authProvider.isInitialized && settingsProvider.isInitialized && fitnessProvider.isInitialized)) {
            return const Center(child: CircularProgressIndicator());
          }

          final today = DateTime.now();
          final isCompleted = fitnessProvider.isDayCompleted(today);

          return Stack(
            children: [
              Column(
                children: [
                  // 1. Top Dark Navy Curved Header
                  _buildEliteHeader(context, authProvider, settingsProvider, fitnessProvider, isCompleted),

                  // 2. Scrollable Body
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0), // Extra padding for fixed button
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // SECTION A: EXERCISE ZONE
                        ExerciseCard(
                          title: 'Jumping Jacks',
                          count: fitnessProvider.jumpingJacksCount.toString(),
                          unit: 'Repetitions',
                          icon: Icons.accessibility_new,
                        ),
                        ExerciseCard(
                          title: 'Push Ups',
                          count: fitnessProvider.pushUpsCount.toString(),
                          unit: 'Repetitions',
                          icon: Icons.fitness_center,
                        ),
                        ExerciseCard(
                          title: 'Squats',
                          count: fitnessProvider.squatsCount.toString(),
                          unit: 'Repetitions',
                          icon: Icons.airline_seat_recline_extra,
                        ),
                        const SizedBox(height: 16),
                        
                        // Mandatory UI Disclaimer
                        _buildDisclaimer(),
                        
                        const SizedBox(height: 32),
                        
                        // RUNNING ZONE Divider
                        _buildRunningZoneDivider(),
                        
                        const SizedBox(height: 24),
                        
                        // SECTION B: RUNNING ZONE
                        ExerciseCard(
                          title: 'Jogging Rounds',
                          count: fitnessProvider.joggingRounds.toString(),
                          unit: 'Ground Rounds',
                          icon: Icons.directions_run,
                        ),
                        ExerciseCard(
                          title: 'Sprints (6m)',
                          count: fitnessProvider.sprintsCount.toString(),
                          unit: 'Full Speed Sets',
                          icon: Icons.bolt,
                        ),
                        const SizedBox(height: 32),
                        _buildAlternatingDaysNote(),
                        const SizedBox(height: 16),
                        _buildResetButton(context, authProvider, settingsProvider, fitnessProvider),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 3. Fixed Action Button at the bottom (above nav bar)
              if (!isCompleted)
                Positioned(
                  bottom: 85,
                  left: 24,
                  right: 24,
                  child: _buildMarkCompletedButton(context, authProvider, settingsProvider, fitnessProvider, today, isCompleted),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEliteHeader(BuildContext context, AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider, bool isCompleted) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B192C), // Deep premium navy
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background HUD elements
          Positioned(
            right: -30,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.fitness_center, size: 200, color: Colors.white),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Color(0xFF4A90E2), size: 18),
                          const SizedBox(width: 4),
                          const Text(
                            'DAILY PROGRESS',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      _buildCompletionBadge(isCompleted),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JOURNEY',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFF0BC), Color(0xFFD4AF37), Color(0xFF996515)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'DAY ${fitnessProvider.daysPassed + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStreakBadge(fitnessProvider.streakCount),
                          if (fitnessProvider.progress.isGoogleFitConnected) ...[
                            const SizedBox(height: 8),
                            _buildStepsBadge(fitnessProvider.todaySteps),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF00D2FF).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isCompleted ? const Color(0xFF00D2FF) : Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'COMPLETED' : 'PENDING',
            style: TextStyle(
              color: isCompleted ? const Color(0xFF00D2FF) : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStepsBadge(int steps) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk, color: Colors.greenAccent, size: 14),
          const SizedBox(width: 4),
          Text(
            '$steps STEPS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFD4AF37), size: 18),
          const SizedBox(width: 6),
          Text(
            '$streak STREAK',
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0B192C).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B192C).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B192C).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFF0B192C), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'For people who can\'t do push ups do knee push ups. People who can\'t do squats do sit ups instead.',
              style: TextStyle(
                color: const Color(0xFF0B192C).withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningZoneDivider() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D2FF).withValues(alpha: 0.0),
            const Color(0xFF00D2FF).withValues(alpha: 0.1),
            const Color(0xFF00D2FF).withValues(alpha: 0.0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 1, width: 40, color: const Color(0xFF00D2FF).withValues(alpha: 0.5)),
          const SizedBox(width: 12),
          const Icon(Icons.speed, color: Color(0xFF00D2FF), size: 18),
          const SizedBox(width: 8),
          const Text(
            'RUNNING ZONE',
            style: TextStyle(
              color: Color(0xFF00D2FF),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              shadows: [
                Shadow(color: Color(0xFF00D2FF), blurRadius: 10),
              ]
            ),
          ),
          const SizedBox(width: 12),
          Container(height: 1, width: 40, color: const Color(0xFF00D2FF).withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildMarkCompletedButton(BuildContext context, AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider, DateTime date, bool isCompleted) {
    return GestureDetector(
      onTap: () => fitnessProvider.toggleCompletion(date),
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isCompleted 
                ? [const Color(0xFF1B3B5A).withValues(alpha: 0.5), const Color(0xFF0B192C).withValues(alpha: 0.5)] 
                : [const Color(0xFF254D7A), const Color(0xFF0F2537)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: isCompleted ? [] : [
            BoxShadow(
              color: const Color(0xFF0B192C).withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
          border: isCompleted ? Border.all(color: const Color(0xFF0B192C).withValues(alpha: 0.2)) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isCompleted)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            if (!isCompleted)
              Positioned(
                top: 0,
                child: Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 2),
                      BoxShadow(color: Color(0xFF00D2FF), blurRadius: 12, spreadRadius: 4),
                    ],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCompleted) const Icon(Icons.replay, color: Color(0xFF1B3B5A), size: 18),
                if (isCompleted) const SizedBox(width: 8),
                Text(
                  isCompleted ? 'UNDO COMPLETION' : 'MARK DAY AS COMPLETED',
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF1B3B5A) : const Color(0xFFE5C583),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider) {
    return Center(
      child: TextButton(
        onPressed: () => _showResetConfirmation(context, authProvider, settingsProvider, fitnessProvider),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          'Reset All Progress',
          style: TextStyle(
            color: Colors.red.shade400,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF8F6F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF0B192C), width: 2),
        ),
        title: const Text(
          'RESET PROGRESS?',
          style: TextStyle(
            color: Color(0xFF0B192C), 
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        content: const Text(
          'This will set your journey back to Day 1 and clear all completed history. This action cannot be undone.',
          style: TextStyle(color: Color(0xFF222222), height: 1.5, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              fitnessProvider.resetProgress();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('RESET NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternatingDaysNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B192C).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_repeat, color: Color(0xFF0B192C), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Do exercise one day and do running the other day on separate days.',
              style: TextStyle(
                color: const Color(0xFF0B192C).withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
