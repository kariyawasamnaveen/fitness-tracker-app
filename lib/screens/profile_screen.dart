import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import 'personal_records_screen.dart';
import 'connected_accounts_screen.dart';
import 'settings_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'subscription_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061121), // Darker navy for the top
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          final completedDays = provider.totalCompletedDays;
          final totalDays = 730;
          final streak = provider.streakCount; // Keeping current streak as it's common for profiles

          return Stack(
            children: [
              // Dark Tech Grid Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
              // The White/Cream curved bottom background
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 220, // Covers the bottom buttons perfectly
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F5F2), // Solid Light cream matching image
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _LightGridPainter(),
                  ),
                ),
              ),
              // Main Content
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileHeader(provider),
                    const SizedBox(height: 24),
                    if (!provider.isPremium) ...[
                      _buildUpgradeButton(context),
                      const SizedBox(height: 24),
                    ],
                    _buildJourneyStatusCard(completedDays, totalDays, streak),
                    const SizedBox(height: 24),
                    _buildMenuOption(context, Icons.workspace_premium_outlined, "Personal Records", onTap: () {
                      if (!provider.isPremium) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalRecordsScreen()));
                      }
                    }),
                    const SizedBox(height: 10),
                    _buildMenuOption(context, Icons.link, "Connected Accounts", showGoogle: true, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConnectedAccountsScreen()),
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildMenuOption(context, Icons.settings_outlined, "App Settings", onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildMenuOption(context, Icons.notifications_none, "Notification Center", onTap: () {
                      if (!provider.isPremium) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
                      }
                    }),
                    const SizedBox(height: 10),
                    _buildMenuOption(context, Icons.lock_outline, "Security & Privacy", onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildMenuOption(context, Icons.logout, "Logout", isLogout: true, onTap: () {
                      provider.logout();
                    }),
                    const SizedBox(height: 24),
                    _buildEditProfileButton(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(FitnessProvider provider) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E5FF), width: 3), // Bright Cyan
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5C583), width: 2), // Inner Gold
                color: const Color(0xFF14243B),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile_avatar.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Metallic Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFDAA520), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            provider.userName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          provider.userEmail.isEmpty ? "No Email Provided" : provider.userEmail,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Dynamic Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
          ),
          child: Text(
            provider.fitnessLevelBadge,
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (provider.isPremium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF87).withOpacity(0.2),
                  blurRadius: 10,
                )
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: Color(0xFF00FF87), size: 16),
                SizedBox(width: 6),
                Text(
                  'ELITE MEMBER',
                  style: TextStyle(
                    color: Color(0xFF00FF87),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            "FREE ATHLETE",
            style: TextStyle(
              color: Colors.white54, 
              fontSize: 12, 
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
      ],
    );
  }

  String _calculateRank(int completedDays) {
    if (completedDays < 10) return "NOVICE\nINITIATE";
    if (completedDays < 30) return "DEDICATED\nATHLETE";
    if (completedDays < 90) return "SEASONED\nWARRIOR";
    if (completedDays < 180) return "MASTER\nCHALLENGER";
    if (completedDays < 365) return "GRANDMASTER\nCHAMPION";
    return "ELITE\nASCENDANT";
  }

  Widget _buildJourneyStatusCard(int completedDays, int totalDays, int streak) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding for smaller height
        decoration: BoxDecoration(
          color: const Color(0xFF2A364F).withOpacity(0.85), // Solidified base color to simulate glass without heavy blur
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "JOURNEY STATUS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Current Day
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CURRENT DAY:",
                        style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                            ).createShader(bounds),
                            child: Text(
                              "$completedDays",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                            ).createShader(bounds),
                            child: Text(
                              " / $totalDays",
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Streak
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "STREAK:",
                        style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                            ).createShader(bounds),
                            child: Text(
                              "$streak",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                            ).createShader(bounds),
                            child: const Text(
                              "DAYS",
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text("🔥", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  // Rank
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "RANK:",
                            style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          // 3D Stacked Icon Badge (Perfect Transparency)
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFC0C0C0), Color(0xFF707070)], // Silver
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Icon(Icons.security, size: 36, color: Colors.white),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFFD700), Color(0xFFDAA520)], // Gold
                                    begin: Alignment.topRight, end: Alignment.bottomLeft,
                                  ).createShader(bounds),
                                  child: const Icon(Icons.shield, size: 24, color: Colors.white),
                                ),
                                const Icon(Icons.keyboard_arrow_up, size: 18, color: Color(0xFF0B192C)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                        ).createShader(bounds),
                        child: Text(
                          _calculateRank(completedDays),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, {bool showGoogle = false, bool isLogout = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title coming soon!")),
        );
      },
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLogout ? Colors.redAccent.withValues(alpha: 0.8) : const Color(0xFF00E5FF).withValues(alpha: 0.8), 
            width: 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: isLogout ? Colors.redAccent.withValues(alpha: 0.2) : const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B2C42), // Dark Convex gradient
              Color(0xFF081221),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFFE5C583), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout ? Colors.redAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (showGoogle) ...[
              Icon(Icons.link, color: const Color(0xFF00E5FF), size: 20),
              const SizedBox(width: 12),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      },
      child: Column(
      children: [
        // Top glowing line
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00E5FF), blurRadius: 10, spreadRadius: 2),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 55,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFF3D27E), Color(0xFF987730)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "EDIT PROFILE",
              style: TextStyle(
                color: Color(0xFF061121),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        // Bottom glowing line
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00E5FF), blurRadius: 10, spreadRadius: 2),
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF00FF87).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF87).withOpacity(0.2),
              blurRadius: 15,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFF00FF87)),
            const SizedBox(width: 10),
            const Text(
              'UPGRADE TO ELITE',
              style: TextStyle(
                color: Color(0xFF00FF87),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Background Tech Grid Painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final circlePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawCircle(Offset(size.width * 0.5, 150), 120, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.5, 150), 250, circlePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for the white/cream curved bottom area
class _LightGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

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
