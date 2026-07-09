import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B192C), // Deep Navy
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            children: [
              _buildPage1(),
              _buildPage2(context),
              _buildPage3(context),
            ],
          ),
          // Bottom Navigation Controls
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (index) => _buildDotIndicator(index: index),
                  ),
                ),
                _currentPage == 2
                    ? const SizedBox.shrink() // Button is inside page 3
                    : _buildNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 1: The Core Concept (Hero Image with Glow and Seamless Blending)
  Widget _buildPage1() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Blended Image
          Expanded(
            flex: 5,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.65, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                "assets/images/onboarding_1.webp",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Text content
          const Text(
            "WELCOME TO\nTHE ELITE",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "A minimalist, hyper-focused progression system designed for a 2-year transformation. No complex AI. Just pure, calculated discipline.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // PAGE 2: The Mechanics (Premium Glassmorphic Layout)
  Widget _buildPage2(BuildContext context) {
    return Stack(
      children: [
        // Background Image faded out at the bottom and top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black, Colors.transparent],
                stops: [0.0, 0.5, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              "assets/images/onboarding_2.webp",
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Glassmorphic Panel at the bottom
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF14243B).withValues(alpha: 0.85), // Rich dark blue glass
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_up, color: Color(0xFF00D2FF), size: 32),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "PROGRESSIVE\nOVERLOAD",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your targets dynamically increase as your journey progresses. Start small, stay consistent, and let the mathematics build your strength.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120), // Space for bottom nav
            ],
          ),
        ),
      ],
    );
  }

  // PAGE 3: The Commitment (Full screen feel with big action button)
  Widget _buildPage3(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with dark overlay fading at bottom
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.65,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              "assets/images/onboarding_3.webp",
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "FORGE YOUR\nLEGACY",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Track your daily streaks, conquer the exercise zones, and mark your days as completed. Are you ready to begin?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildGetStartedButton(context),
              const SizedBox(height: 100), // Space for dot indicators
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDotIndicator({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: _currentPage == index ? 24 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNextButton() {
    return InkWell(
      onTap: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            Text(
              "NEXT",
              style: TextStyle(
                color: Color(0xFF00D2FF),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF00D2FF), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<FitnessProvider>(context, listen: false).completeOnboarding();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF254D7A), Color(0xFF0F2537)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
              blurRadius: 20,
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
            // Content
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GET STARTED',
                  style: TextStyle(
                    color: Color(0xFFE5C583), // Metallic Gold Text
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.bolt, color: Color(0xFFE5C583)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
