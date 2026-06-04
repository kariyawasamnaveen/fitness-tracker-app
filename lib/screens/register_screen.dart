import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final provider = Provider.of<FitnessProvider>(context, listen: false);
    bool success = await provider.register(
      name.isEmpty ? 'Athlete' : name, 
      email.isEmpty ? 'athlete@elite.com' : email, 
      password.isEmpty ? 'password' : password
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Email might be in use or invalid.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          
          // Flawless Architectural Proportions for Register Screen
          final headerHeight = maxHeight * 0.22; // Top 22% White Header
          final navyHeight = maxHeight * 0.52; // Middle 52% Dark Navy Section
          final navyBottom = headerHeight + navyHeight; // 74% boundary
          final buttonHeight = maxHeight * 0.07; // Action button height

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 0. Bottom Cream Section Custom 3D Plexus Wave Background
                  Positioned(
                    top: navyBottom,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _BottomPlexusWavePainter(),
                      size: Size(maxWidth, maxHeight - navyBottom),
                    ),
                  ),

                  // 1. Top White Header Section w/ Back Button & Titles
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: headerHeight,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F6F0), // Clean Off-White / Cream Header
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            // Back Button
                            Positioned(
                              top: maxHeight * 0.01,
                              left: maxWidth * 0.04,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B3B5A), size: 18),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),

                            // Main Header Titles
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: maxHeight * 0.015),
                                  // Brand Title (FITNESS LEVELING)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'FITNESS ',
                                        style: TextStyle(
                                          color: Color(0xFF1B3B5A), // Deep Navy
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      Text(
                                        'LEVELING',
                                        style: TextStyle(
                                          color: const Color(0xFF4A90E2), // Tech Blue
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Subtitle (CREATE ATHLETE PROFILE)
                                  const Text(
                                    'CREATE ATHLETE PROFILE',
                                    style: TextStyle(
                                      color: Color(0xFF222222), // Heavy Dark Grey
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Gold Metallic Divider Bar (Between White Header & Navy Section)
                  Positioned(
                    top: headerHeight - 2,
                    left: 0,
                    right: 0,
                    height: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF996515), // Dark Gold
                            Color(0xFFD4AF37), // Gold
                            Color(0xFFFFF0BC), // Light Shimmer
                            Color(0xFFD4AF37), // Gold
                            Color(0xFF996515), // Dark Gold
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFD4AF37),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Middle Dark Navy Curved Container (4 Fields + Blueprint Grid)
                  Positioned(
                    top: headerHeight + 2,
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
                        children: [
                          // Navy Bottom Architectural Blueprint Tech Grid w/ Notations
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: navyHeight * 0.45,
                            child: CustomPaint(
                              painter: _NavyBlueprintPainter(),
                              size: Size(maxWidth, navyHeight * 0.45),
                            ),
                          ),

                          // Main Navy Content (4 Text Fields)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.07),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Full Name Input Field (Inactive State)
                                _buildEliteTextField(
                                  controller: _nameController,
                                  hint: 'Full Name',
                                  icon: Icons.badge_outlined,
                                  fieldKey: 'name',
                                ),
                                SizedBox(height: maxHeight * 0.015),

                                // Email Input Field (Inactive State)
                                _buildEliteTextField(
                                  controller: _emailController,
                                  hint: 'Email Address',
                                  icon: Icons.email_outlined,
                                  fieldKey: 'email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: maxHeight * 0.015),

                                // Password Input Field (Active State w/ Neon Glow)
                                _buildEliteTextField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  fieldKey: 'password',
                                  obscureText: _obscurePassword,
                                  forceGlow: true, // Forces Neon Glow as shown in Target Image
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                SizedBox(height: maxHeight * 0.015),

                                // Confirm Password Input Field (Active State w/ Neon Glow)
                                _buildEliteTextField(
                                  controller: _confirmPasswordController,
                                  hint: 'Confirm Password',
                                  icon: Icons.lock_outline,
                                  fieldKey: 'confirm_password',
                                  obscureText: _obscurePassword,
                                  forceGlow: true, // Forces Neon Glow as shown in Target Image
                                ),
                                SizedBox(height: maxHeight * 0.02), // Bottom padding before button overlap
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Overlapping 3D Metallic Action Button w/ Lens Flare & Bevel Shimmer
                  Positioned(
                    top: navyBottom - (buttonHeight / 2),
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

                          // Button Content (START JOURNEY as shown in Target Image)
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
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

                  // 5. Bottom Cream Section (Already an Athlete? Sign In Link)
                  Positioned(
                    top: navyBottom + (buttonHeight / 2) + (maxHeight * 0.02),
                    left: maxWidth * 0.07,
                    right: maxWidth * 0.07,
                    bottom: maxHeight * 0.015,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already an Athlete? ",
                          style: TextStyle(
                            color: const Color(0xFF0B192C).withValues(alpha: 0.7),
                            fontSize: maxWidth * 0.036,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Sign In',
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Explicit, Bulletproof Row Layout for Text Fields w/ Neon Glow
  Widget _buildEliteTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String fieldKey,
    bool obscureText = false,
    bool forceGlow = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    final isFocused = _focusedField == fieldKey || forceGlow;

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

// 1. Navy Bottom Architectural Blueprint Tech Grid Painter w/ Notations
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

    // Tech Notations
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

// 2. Custom Painter for the Bottom Cream Section 3D Plexus Waves & Light Pillars
class _BottomPlexusWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final meshPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final pillarPaint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

    // 3D Flowing Terrain Waves (Plexus Curves)
    final path1 = Path()
      ..moveTo(0, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.05, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.75, size.width, size.height * 0.5);

    final path2 = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.55, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width, size.height * 0.65);

    final path3 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.35, size.width * 0.6, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.95, size.width, size.height * 0.8);

    canvas.drawPath(path1, meshPaint);
    canvas.drawPath(path2, meshPaint);
    canvas.drawPath(path3, meshPaint);

    // Vertical Connecting Mesh Lines (Creates the 3D Wireframe Grid Effect)
    final numCols = 12;
    for (int i = 1; i < numCols; i++) {
      final x = size.width * (i / numCols);
      // Sample rough Y positions along the waves
      final y1 = size.height * (0.1 + (i % 3) * 0.15);
      final y2 = size.height * (0.4 + (i % 4) * 0.12);
      canvas.drawLine(Offset(x, y1), Offset(x, y2), meshPaint);
    }

    // Vertical Light Pillars / Glowing Needles (As seen on the right side of Target Image)
    final pillarX1 = size.width * 0.78;
    final pillarX2 = size.width * 0.85;
    final pillarX3 = size.width * 0.92;

    canvas.drawLine(Offset(pillarX1, size.height * 0.3), Offset(pillarX1, size.height * 0.7), pillarPaint);
    canvas.drawLine(Offset(pillarX2, size.height * 0.2), Offset(pillarX2, size.height * 0.8), pillarPaint);
    canvas.drawLine(Offset(pillarX3, size.height * 0.4), Offset(pillarX3, size.height * 0.65), pillarPaint);

    // Intersecting Glowing Nodes
    final points = [
      Offset(size.width * 0.25, size.height * 0.18),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.55, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.75),
      Offset(size.width * 0.8, size.height * 0.65),
    ];

    for (final pt in points) {
      canvas.drawCircle(pt, 5, glowPaint);
      canvas.drawCircle(pt, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
