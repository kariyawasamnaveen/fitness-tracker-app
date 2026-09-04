// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/fitness_data_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _selectTime(BuildContext context, AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settingsProvider.workoutReminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyanAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E2746),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF0D1321)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != settingsProvider.workoutReminderTime) {
      settingsProvider.updateWorkoutReminderTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1321),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'NOTIFICATION CENTER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Grid
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          
          SafeArea(
            child: Consumer3<AuthProvider, SettingsProvider, FitnessDataProvider>(
              builder: (context, authProvider, settingsProvider, fitnessProvider, child) {
                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      'Daily Reminders',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Motivation Toggle
                    _buildSwitchTile(
                      title: 'Morning Motivation ☀️',
                      subtitle: 'Receive a daily fitness quote to start your day.',
                      value: settingsProvider.motivationEnabled,
                      onChanged: (val) => settingsProvider.toggleMotivation(val),
                    ),
                    const SizedBox(height: 16),
                    
                    // Workout Reminder Toggle
                    _buildSwitchTile(
                      title: 'Workout Reminder 💪',
                      subtitle: "Get notified when it's time to train.",
                      value: settingsProvider.workoutReminderEnabled,
                      onChanged: (val) => settingsProvider.toggleWorkoutReminder(val),
                    ),
                    
                    // Time Picker for Workout Reminder
                    if (settingsProvider.workoutReminderEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: GestureDetector(
                          onTap: () => _selectTime(context, authProvider, settingsProvider, fitnessProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reminder Time',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      settingsProvider.workoutReminderTime.format(context),
                                      style: const TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.edit, color: Colors.cyanAccent, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 40),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Streak Protection',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Streak Saver Toggle
                    _buildSwitchTile(
                      title: 'Streak Saver Alert 🛡️',
                      subtitle: "Get a warning at 8:00 PM if you haven't completed your daily workout.",
                      value: settingsProvider.streakSaverEnabled,
                      onChanged: (val) => settingsProvider.toggleStreakSaver(val),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.cyanAccent,
            activeTrackColor: Colors.cyanAccent.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
