// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isGoogleLinked = false;
  String _userName = "ATHLETE";
  String _userEmail = "";
  
  // Security & Privacy
  bool _isAppLockEnabled = false;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGoogleLinked => _isGoogleLinked;
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isAppLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    _isAuthenticated = !_isAppLockEnabled;

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        _isLoggedIn = false;
        _userName = "ATHLETE";
        _userEmail = "";
        notifyListeners();
      } else {
        _isLoggedIn = true;
        _userName = user.displayName ?? prefs.getString('user_name') ?? "ATHLETE";
        _userEmail = user.email ?? "";
        _isGoogleLinked = user.providerData.any((userInfo) => userInfo.providerId == 'google.com');
        notifyListeners();
      }
    });

    final initialUser = await FirebaseAuth.instance.authStateChanges().first;
    if (initialUser != null) {
      _isLoggedIn = true;
      _isGoogleLinked = initialUser.providerData.any((userInfo) => userInfo.providerId == 'google.com');
      _userName = initialUser.displayName ?? prefs.getString('user_name') ?? "ATHLETE";
      _userEmail = initialUser.email ?? "";
    }
    _isInitialized = true;
    notifyListeners();
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

  Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
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
      
      if (userCredential.user?.displayName != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userCredential.user!.displayName!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Firebase Error: ${e.message}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  Future<String?> deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Just delete auth, other providers will handle their own cleanups if needed
        await user.delete();
        _isLoggedIn = false;
        _isGoogleLinked = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        notifyListeners();
        return null;
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
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential);
        _isGoogleLinked = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
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
    } catch (_) {
      return false;
    }
  }
}
