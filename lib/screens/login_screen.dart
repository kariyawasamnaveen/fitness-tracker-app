import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _focusedField = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart),
    );
    _animController.forward();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final provider = Provider.of<FitnessProvider>(context, listen: false);
    String? error = await provider.login(
      email.isEmpty ? 'athlete@elite.com' : email, 
      password.isEmpty ? 'password' : password
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE6), // Premium bottom cream background
      resizeToAvoidBottomInset: false, // 100% Non-scrollable guarantee
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final maxWidth = constraints.maxWidth;
          final navyHeight = maxHeight * 0.68; // Top 68% dark navy section
          final buttonHeight = maxHeight * 0.07; // Action button height

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 0. Bottom Cream Section Custom Plexus Tech Grid Background
                  Positioned(
                    top: navyHeight,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _BottomPlexusPainter(),
                        size: Size(maxWidth, maxHeight - navyHeight),
                      ),
                    ),
                  ),

                  // 1. Top Dark Navy Curved Container
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: navyHeight,
                    child: Container(
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
                        alignment: Alignment.topCenter,
                        children: [
                          // Background HUD Radar Rings & Tick Marks
                          Positioned(
                            top: maxHeight * 0.03,
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _HudRadarPainter(),
                                size: Size(maxHeight * 0.48, maxHeight * 0.48),
                              ),
                            ),
                          ),

                          // Navy Bottom Architectural Blueprint Tech Grid w/ Notations
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: maxHeight * 0.18,
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _NavyBlueprintPainter(),
                                size: Size(maxWidth, maxHeight * 0.18),
                              ),
                            ),
                          ),

                          // Main Navy Content (Wrapped in SafeArea & Column)
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.07),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Brand Title w/ Lightning Bolt
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.bolt, color: Color(0xFF4A90E2), size: 18),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'FITNESS ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      Text(
                                        'LEVELING',
                                        style: TextStyle(
                                          color: const Color(0xFF4A90E2),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: maxHeight * 0.02),

                                  // Metallic Medallion Emblem
                                  Container(
                                    width: maxHeight * 0.18,
                                    height: maxHeight * 0.18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/fitness_elite_emblem.webp',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: maxHeight * 0.02),

                                  // Gold Metallic Shimmer Headline w/ Condensed Tracking
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFFFFF0BC), Color(0xFFD4AF37), Color(0xFF996515)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'WELCOME TO THE ELITE.',
                                      style: TextStyle(
                                        color: Colors.white, // Required for ShaderMask
                                        fontSize: maxWidth * 0.065,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: -0.8, // Ultra-condensed tracking
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Subtitle (Light Silvery Grey)
                                  Text(
                                    'Level up your physical limits day by day.',
                                    style: TextStyle(
                                      color: const Color(0xFFCCCCCC),
                                      fontSize: maxWidth * 0.035,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: maxHeight * 0.025),

                                  // Email Input Field (Bulletproof Row Layout)
                                  _buildEliteTextField(
                                    controller: _emailController,
                                    hint: 'Email Address',
                                    icon: Icons.email_outlined,
                                    fieldKey: 'email',
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: maxHeight * 0.012),

                                  // Password Input Field (Bulletproof Row Layout w/ Eye Icon)
                                  _buildEliteTextField(
                                    controller: _passwordController,
                                    hint: 'Password',
                                    icon: Icons.lock_outline,
                                    fieldKey: 'password',
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  SizedBox(height: maxHeight * 0.01),

                                  // Forgot Password Link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: const Color(0xFF4A90E2),
                                          fontSize: maxWidth * 0.034,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Overlapping 3D Metallic Action Button w/ Lens Flare & Bevel Shimmer
                  Positioned(
                    top: navyHeight - (buttonHeight / 2),
                    left: maxWidth * 0.07,
                    right: maxWidth * 0.07,
                    height: buttonHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF254D7A), Color(0xFF0F2537)], // 3D Metallic Pill
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0B192C).withValues(alpha: 0.6), // Dark drop shadow
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Top Inner Bevel Shimmer
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
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

                          // Lens Flare Glow Highlight
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Color(0xFF00D2FF),
                                    blurRadius: 12,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Button Content
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: Size(double.infinity, buttonHeight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    'START JOURNEY',
                                    style: TextStyle(
                                      color: const Color(0xFFE5C583), // Metallic Gold Text
                                      fontSize: maxWidth * 0.045,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom Cream Section Content (OR, Google Button & Register Link)
                  Positioned(
                    top: navyHeight + (buttonHeight / 2) + (maxHeight * 0.015),
                    left: maxWidth * 0.07,
                    right: maxWidth * 0.07,
                    bottom: maxHeight * 0.015,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Tapered OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1.5,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Color(0xFF00D2FF)],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: const Color(0xFF0B192C).withValues(alpha: 0.6),
                                  fontSize: maxWidth * 0.034,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1.5,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF00D2FF), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Continue with Google Button w/ Soft Diffused Shadow
                        Container(
                          height: maxHeight * 0.065,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              setState(() => _isLoading = true);
                              final provider = Provider.of<FitnessProvider>(context, listen: false);
                              String? error = await provider.signInWithGoogle();
                              
                              if (mounted) {
                                setState(() => _isLoading = false);
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $error')),
                                  );
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata_rounded, color: Colors.red.shade600, size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: const Color(0xFF0B192C),
                                    fontSize: maxWidth * 0.04,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New Athlete? ",
                              style: TextStyle(
                                color: const Color(0xFF0B192C).withValues(alpha: 0.7),
                                fontSize: maxWidth * 0.036,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  color: const Color(0xFF0B192C),
                                  fontWeight: FontWeight.w900,
                                  fontSize: maxWidth * 0.036,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF0B192C),
                                  decorationThickness: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Explicit, Bulletproof Row Layout for Text Fields
  Widget _buildEliteTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String fieldKey,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    final isFocused = _focusedField == fieldKey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B).withValues(alpha: 0.85), // Rich translucent navy
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.15),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.4), // Neon diffused outer glow
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _focusedField = hasFocus ? fieldKey : '';
          });
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: isFocused ? const Color(0xFF00D2FF) : Colors.white70, // Crisp silvery-white / cyan
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.w500), // Beautiful visible silvery hint
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14), // Perfectly centered vertically
                ),
              ),
            ),
            ?suffixIcon,
          ],
        ),
      ),
    );
  }
}

// 1. Background HUD Radar Rings & Tick Marks Painter
class _HudRadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Concentric Radar Rings
    canvas.drawCircle(center, radius * 0.6, ringPaint);
    canvas.drawCircle(center, radius * 0.85, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    // Crosshairs
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height * 0.15), tickPaint);
    canvas.drawLine(Offset(center.dx, size.height * 0.85), Offset(center.dx, size.height), tickPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width * 0.15, center.dy), tickPaint);
    canvas.drawLine(Offset(size.width * 0.85, center.dy), Offset(size.width, center.dy), tickPaint);

    // Angular Tick Marks
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final p1 = Offset(center.dx + math.cos(angle) * (radius * 0.82), center.dy + math.sin(angle) * (radius * 0.82));
      final p2 = Offset(center.dx + math.cos(angle) * (radius * 0.88), center.dy + math.sin(angle) * (radius * 0.88));
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Navy Bottom Architectural Blueprint Tech Grid Painter w/ Notations
class _NavyBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final gridHeight = size.height * 0.8;
    final startY = size.height - gridHeight;

    // Vanishing Point Perspective Lines
    final numCols = 10;
    final vanishingPoint = Offset(size.width / 2, startY - size.height * 0.5);

    for (int i = 0; i <= numCols; i++) {
      final bottomX = size.width * (i / numCols);
      final startPt = Offset(bottomX, size.height);
      final t = 0.45;
      final endPt = Offset(startPt.dx + (vanishingPoint.dx - startPt.dx) * t, startPt.dy + (vanishingPoint.dy - startPt.dy) * t);
      canvas.drawLine(startPt, endPt, paint);
    }

    // Horizontal Perspective Grid Lines
    for (int i = 0; i <= 5; i++) {
      final factor = math.pow(i / 5, 1.5);
      final y = startY + (gridHeight * factor);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Tech Notations (Moved lower to avoid overlapping text fields)
    _drawTechText(canvas, 'SYS.01_ACTIVE', Offset(size.width * 0.08, size.height - 25));
    _drawTechText(canvas, 'LAT.45.89°', Offset(size.width * 0.78, size.height - 25));
  }

  void _drawTechText(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF00D2FF).withValues(alpha: 0.5),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Custom Painter for the Bottom Cream Section Plexus Tech Grid
class _BottomPlexusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

    // Left Plexus Mesh (Complex Polygons)
    final path1 = Path()
      ..moveTo(0, size.height * 0.15)
      ..lineTo(size.width * 0.22, size.height * 0.12)
      ..lineTo(size.width * 0.35, size.height * 0.38)
      ..lineTo(size.width * 0.18, size.height * 0.65)
      ..lineTo(0, size.height * 0.75);

    final path2 = Path()
      ..moveTo(size.width * 0.22, size.height * 0.12)
      ..lineTo(size.width * 0.18, size.height * 0.65);

    final path3 = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width * 0.35, size.height * 0.38);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);

    // Right Plexus Mesh (Complex Polygons)
    final path4 = Path()
      ..moveTo(size.width, size.height * 0.08)
      ..lineTo(size.width * 0.78, size.height * 0.18)
      ..lineTo(size.width * 0.65, size.height * 0.48)
      ..lineTo(size.width * 0.82, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.88);

    final path5 = Path()
      ..moveTo(size.width * 0.78, size.height * 0.18)
      ..lineTo(size.width * 0.82, size.height * 0.75);

    final path6 = Path()
      ..moveTo(size.width, size.height * 0.35)
      ..lineTo(size.width * 0.65, size.height * 0.48);

    canvas.drawPath(path4, paint);
    canvas.drawPath(path5, paint);
    canvas.drawPath(path6, paint);

    // Intersecting Glowing Nodes
    final points = [
      Offset(size.width * 0.22, size.height * 0.12),
      Offset(size.width * 0.35, size.height * 0.38),
      Offset(size.width * 0.18, size.height * 0.65),
      Offset(size.width * 0.78, size.height * 0.18),
      Offset(size.width * 0.65, size.height * 0.48),
      Offset(size.width * 0.82, size.height * 0.75),
    ];

    for (final pt in points) {
      canvas.drawCircle(pt, 6, glowPaint);
      canvas.drawCircle(pt, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
