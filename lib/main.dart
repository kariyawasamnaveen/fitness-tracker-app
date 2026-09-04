// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/fitness_data_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trends_screen.dart';
import 'screens/subscription_screen.dart';
import 'dart:io';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  if (Platform.isAndroid) {
    await Purchases.configure(PurchasesConfiguration(dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? ""));
  } else if (Platform.isIOS) {
    await Purchases.configure(PurchasesConfiguration(dotenv.env['REVENUECAT_API_KEY_IOS'] ?? ""));
  }
  
  // Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  
  // Initialize Notifications safely in the background
  try {
    NotificationService.init(); // Removed await to speed up startup
  } catch (e) {
    debugPrint("Notification init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FitnessDataProvider()),
      ],
      child: const FitnessTrackerApp(),
    ),
  );
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone X / 11 Pro size for design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Fitness Leveling',
          debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFF0D6EFD), // Tech Blue
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D6EFD),
          secondary: Color(0xFF005B96), // Royal Blue
          surface: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.08),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D20),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D20),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Color(0xFF3C4248),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
        useMaterial3: true,
      ),
      home: Consumer3<AuthProvider, SettingsProvider, FitnessDataProvider>(
        builder: (context, authProvider, settingsProvider, fitnessProvider, child) {
          debugPrint("============== MAIN NAVIGATION TRACE ==============");
          debugPrint("1. isInitialized: ${(authProvider.isInitialized && settingsProvider.isInitialized && fitnessProvider.isInitialized)}");
          debugPrint("2. hasSeenOnboarding: ${settingsProvider.profile.hasSeenOnboarding}");
          debugPrint("3. isLoggedIn: ${authProvider.isLoggedIn}");
          debugPrint("4. isPremium: ${settingsProvider.profile.isPremium}");
          
          if (!(authProvider.isInitialized && settingsProvider.isInitialized && fitnessProvider.isInitialized)) {
            debugPrint("-> Routing to: CircularProgressIndicator (Not Initialized)");
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (!settingsProvider.profile.hasSeenOnboarding) {
            debugPrint("-> Routing to: OnboardingScreen (hasSeenOnboarding is false)");
            return const OnboardingScreen();
          }
          if (!authProvider.isLoggedIn) {
            debugPrint("-> Routing to: LoginScreen (isLoggedIn is false)");
            return const LoginScreen();
          }
          if (!settingsProvider.profile.isPremium) {
            debugPrint("-> Routing to: SubscriptionScreen (isPremium is false)");
            return const SubscriptionScreen();
          }
          debugPrint("-> Routing to: MainNavigationScreen (App is fully unlocked)");
          return const AppLockWrapper(child: MainNavigationScreen());
        },
      ),
    );
      },
    );
  }
}

class AppLockWrapper extends StatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authenticateIfNeeded();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessDataProvider>(context, listen: false);
      fitnessProvider.autoFetchGoogleFitSteps();
    } else if (state == AppLifecycleState.paused) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessDataProvider>(context, listen: false);
      if (authProvider.isAppLockEnabled) {
        authProvider.setAuthenticated(false);
      }
    }
  }

  Future<void> _authenticateIfNeeded() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final fitnessProvider = Provider.of<FitnessDataProvider>(context, listen: false);
    if (!authProvider.isAppLockEnabled || authProvider.isAuthenticated) return;

    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to open Fitness Tracker',
        biometricOnly: false,
      );
      if (didAuthenticate && mounted) {
        authProvider.setAuthenticated(true);
      }
    } catch (e) {
      debugPrint("Auth error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final fitnessProvider = Provider.of<FitnessDataProvider>(context);
    if (authProvider.isAppLockEnabled && !authProvider.isAuthenticated) {
      // Return a blank screen to hide app content. 
      // The native fingerprint prompt is automatically shown on startup/resume.
      // If the user dismisses the native prompt, tapping the screen will show it again.
      return GestureDetector(
        onTap: _authenticateIfNeeded,
        child: const Scaffold(
          backgroundColor: Color(0xFF061121), // Dark app theme background
          body: SizedBox.expand(),
        ),
      );
    }
    return widget.child;
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrendsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE6),
      extendBody: true, // Allow body to extend behind bottom nav
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F5F2), // Light cream
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: const Color(0xFFF6F5F2),
          selectedItemColor: const Color(0xFF00D2FF), // Neon Cyan
          unselectedItemColor: const Color(0xFF6C757D), // Dark gray
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home, size: 28, color: Color(0xFF00D2FF)),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.insights),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.insights, size: 28, color: Color(0xFF00D2FF)),
              ),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person, size: 28, color: Color(0xFF00D2FF)),
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings, size: 28, color: Color(0xFF00D2FF)),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE6),
      body: Center(
        child: Text(
          title, 
          style: const TextStyle(
            fontSize: 24, 
            color: Color(0xFF0B192C), 
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
