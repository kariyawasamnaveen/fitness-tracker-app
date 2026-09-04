// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/fitness_data_provider.dart';

class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() => _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  bool _isLoading = false;

  void _handleGoogleLink(AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider) async {
    debugPrint("[DEBUG] ConnectedAccountsScreen: _handleGoogleLink clicked.");
    debugPrint("[DEBUG] Current authProvider.isGoogleLinked state: ${authProvider.isGoogleLinked}");
    setState(() => _isLoading = true);
    
    if (authProvider.isGoogleLinked) {
      debugPrint("[DEBUG] Calling authProvider.unlinkGoogleAccount()...");
      bool success = await authProvider.unlinkGoogleAccount();
      debugPrint("[DEBUG] unlinkGoogleAccount returned: $success");
      if (mounted) {
        if (!success) {
          debugPrint("[DEBUG] Showing Snackbar for failed unlink.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to unlink Google account.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google account disconnected successfully!')),
          );
        }
      }
    } else {
      debugPrint("[DEBUG] Calling authProvider.linkGoogleAccount()...");
      bool success = await authProvider.linkGoogleAccount();
      debugPrint("[DEBUG] linkGoogleAccount returned: $success");
      if (mounted) {
        if (!success) {
          debugPrint("[DEBUG] Showing Snackbar for failed link.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to link Google account.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google account connected successfully!')),
          );
        }
      }
    }
    debugPrint("[DEBUG] Finished Google Link flow. Setting isLoading = false.");
    if (mounted) setState(() => _isLoading = false);
  }

  void _handleGoogleFitConnect(AuthProvider authProvider, SettingsProvider settingsProvider, FitnessDataProvider fitnessProvider) async {
    debugPrint("[DEBUG] ConnectedAccountsScreen: _handleGoogleFitConnect clicked.");
    setState(() => _isLoading = true);
    debugPrint("[DEBUG] Calling fitnessProvider.connectGoogleFit()...");
    await fitnessProvider.connectGoogleFit();
    debugPrint("[DEBUG] connectGoogleFit completed. Setting isLoading = false.");
    if (mounted) {
      setState(() => _isLoading = false);
      if (fitnessProvider.progress.isGoogleFitConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Fit connected successfully!')),
        );
      }
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
          'CONNECTED ACCOUNTS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          
          SafeArea(
            child: Consumer3<AuthProvider, SettingsProvider, FitnessDataProvider>(
              builder: (context, authProvider, settingsProvider, fitnessProvider, child) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sync Your Journey',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Google Account linking
                      _buildConnectionCard(
                        icon: Icons.g_mobiledata_rounded,
                        iconColor: Colors.blueAccent,
                        title: 'Google Account',
                        description: 'Sign in faster across devices',
                        isConnected: authProvider.isGoogleLinked,
                        onTap: () => _handleGoogleLink(authProvider, settingsProvider, fitnessProvider),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Google Fit linking
                      _buildConnectionCard(
                        icon: Icons.monitor_heart_outlined,
                        iconColor: Colors.greenAccent,
                        title: 'Google Fit',
                        description: 'Sync steps and workouts automatically',
                        isConnected: fitnessProvider.progress.isGoogleFitConnected,
                        onTap: () => _handleGoogleFitConnect(authProvider, settingsProvider, fitnessProvider),
                      ),
                      
                      const Spacer(),
                      
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                          ),
                        ),
                        
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.white10,
          width: 1,
        ),
        boxShadow: isConnected ? [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isConnected ? Colors.cyanAccent : Colors.white30,
                    ),
                  ),
                  child: Text(
                    isConnected ? 'CONNECTED' : 'CONNECT',
                    style: TextStyle(
                      color: isConnected ? Colors.cyanAccent : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
