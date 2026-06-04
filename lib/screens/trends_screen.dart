import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../utils/date_utility.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B192C), // Very dark navy
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          final daysPassed = provider.daysPassed;
          final completedDays = provider.totalCompletedDays;
          final totalDays = 730;
          final double progress = (completedDays / totalDays).clamp(0.0, 1.0);
          final String progressStr = (progress * 100).toStringAsFixed(1);

          return CustomPaint(
            painter: _GridPainter(),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    "TRENDS: PROGRESS EVOLUTION",
                    style: TextStyle(
                      color: Color(0xFFE5C583), // Goldish
                      fontSize: 12, // Scaled down
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16), // Scaled down
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Compact padding
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildJourneyCard(completedDays, totalDays, progress, progressStr),
                        const SizedBox(height: 24), // Compact spacing
                        _buildConsistencyChart(provider),
                        const SizedBox(height: 20), // Compact spacing
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: "PUSH UPS",
                          level: _calculateLevel(completedDays),
                          startVal: DateUtility.calculatePushUps(0).toString(),
                          nowVal: "${DateUtility.calculatePushUps(completedDays)} REPS",
                        ),
                        const SizedBox(height: 8), // Compact spacing
                        _buildStatCard(
                          icon: Icons.directions_run,
                          title: "SPRINTS",
                          level: _calculateLevel(completedDays),
                          startVal: DateUtility.calculateSprints(0).toString(),
                          nowVal: "${DateUtility.calculateSprints(completedDays)} SPRINT",
                        ),
                        const SizedBox(height: 8), // Compact spacing
                        _buildStreakCard(provider.bestStreak),
                        const SizedBox(height: 24), // Compact spacing
                        _buildHistoryButton(context, provider),
                        const SizedBox(height: 100),
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

  int _calculateLevel(int days) {
    return (days ~/ 30) + 1; // 1 level per month roughly
  }

  Widget _buildJourneyCard(int completedDays, int totalDays, double progress, String progressStr) {
    return Container(
      padding: const EdgeInsets.all(16), // Scaled down
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20), // Scaled down
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "JOURNEY COMPLETION",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Scaled down
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    "DAY ",
                    style: TextStyle(color: Color(0xFFE5C583), fontSize: 16, fontWeight: FontWeight.bold), // Scaled down
                  ),
                  Text(
                    "$completedDays",
                    style: const TextStyle(color: Color(0xFFE5C583), fontSize: 28, fontWeight: FontWeight.w900), // Scaled down
                  ),
                  Text(
                    " / $totalDays",
                    style: const TextStyle(color: Color(0xFFE5C583), fontSize: 14, fontWeight: FontWeight.bold), // Scaled down
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "TOTAL DAYS COMPLETED",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10, // Scaled down
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Circular Progress
          Container(
            width: 70, // Scaled down from 90
            height: 70, // Scaled down from 90
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
                  blurRadius: 15, // Scaled down
                  spreadRadius: 4, // Scaled down
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 3, // Scaled down from 4
                  color: const Color(0xFF14243B).withValues(alpha: 0.8),
                ),
                CircularProgressIndicator(
                  value: progress == 0 ? 0.01 : progress, // Minimum so something shows
                  strokeWidth: 3, // Scaled down from 4
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D2FF)),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$progressStr%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Scaled down from 18
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "TOTAL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 7, // Scaled down from 8
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyChart(FitnessProvider provider) {
    // Determine last 7 days status
    List<bool> past7Days = [];
    List<DateTime> past7Dates = [];
    DateTime today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime d = today.subtract(Duration(days: i));
      past7Days.add(provider.isDayCompleted(d));
      past7Dates.add(d);
    }

    return Column(
      children: [
        const Text(
          "WEEKLY CONSISTENCY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13, // Scaled down
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16), // Scaled down
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            bool isCompleted = past7Days[index];
            DateTime date = past7Dates[index];
            bool isGold = index % 2 != 0; // Alternate colors to match aesthetic
            return _buildGlassTube(isCompleted, isGold, date);
          }),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Last Week", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)), // Scaled down
            Text("This Week", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)), // Scaled down
          ],
        ),
      ],
    );
  }

  Widget _buildGlassTube(bool isCompleted, bool isGold, DateTime date) {
    Color activeColor = isGold ? const Color(0xFFE5C583) : const Color(0xFF00D2FF);
    // Determine arbitrary liquid level based on complete status
    double heightFactor = isCompleted ? 0.8 : 0.2; 
    String dateStr = "${date.day}/${date.month}";
    
    return Column(
      children: [
        Container(
          width: 24, // Scaled down from 34
          height: 90, // Scaled down from 120
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4), // Dark inside
            borderRadius: BorderRadius.circular(12), // Scaled down
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // The liquid fill
              FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Scaled down
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        activeColor.withValues(alpha: 0.8),
                        activeColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.5),
                        blurRadius: 8, // Scaled down
                        spreadRadius: 1, // Scaled down
                      ),
                    ],
                  ),
                ),
              ),
              // Top label e.g., 6/7
              Positioned(
                top: 6,
                child: Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 8, // Scaled down from 10
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Glass reflection overlay for 3D effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Scaled down
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required int level, required String startVal, required String nowVal}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Scaled down vertical padding
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3D), // Deep rich card bg
        borderRadius: BorderRadius.circular(16), // Scaled down
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8, // Scaled down
            offset: const Offset(0, 3), // Scaled down
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 36, // Scaled down from 48
            height: 36, // Scaled down from 48
            decoration: BoxDecoration(
              color: const Color(0xFF0B192C),
              borderRadius: BorderRadius.circular(10), // Scaled down
              border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: const Color(0xFF00D2FF), size: 20), // Scaled down from 28
          ),
          const SizedBox(width: 12), // Scaled down from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1), // Scaled down from 16
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "LEVEL: $level",
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold), // Scaled down from 12
                    ),
                  ],
                ),
                const SizedBox(height: 4), // Scaled down from 6
                Row(
                  children: [
                    const Text("START: ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)), // Scaled down from 14
                    Text(startVal, style: const TextStyle(color: Color(0xFFE5C583), fontSize: 13, fontWeight: FontWeight.w900)), // Scaled down from 16
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(Icons.arrow_forward, color: Colors.white70, size: 12), // Scaled down from 14
                    ),
                    const Text("NOW: ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)), // Scaled down from 14
                    Text(nowVal, style: const TextStyle(color: Color(0xFFE5C583), fontSize: 13, fontWeight: FontWeight.w900)), // Scaled down from 16
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Scaled down
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3D),
        borderRadius: BorderRadius.circular(16), // Scaled down
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "BEST STREAK",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1), // Scaled down from 18
          ),
          Row(
            children: [
              Text(
                "$streak",
                style: const TextStyle(color: Color(0xFFE5C583), fontSize: 20, fontWeight: FontWeight.w900), // Scaled down from 24
              ),
              const SizedBox(width: 6),
              const Text(
                "DAYS",
                style: TextStyle(color: Color(0xFFE5C583), fontSize: 12, fontWeight: FontWeight.bold), // Scaled down from 16
              ),
              const SizedBox(width: 6),
              const Text("🔥", style: TextStyle(fontSize: 18)), // Scaled down from 22
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context, FitnessProvider provider) {
    return GestureDetector(
      onTap: () => _showHistoryBottomSheet(context, provider),
      child: Column(
        children: [
          // Top glowing line
          Container(
            width: 150, // Scaled down
            height: 2, // Scaled down
            decoration: BoxDecoration(
              color: const Color(0xFF00D2FF),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 1), // Scaled down
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50, // Scaled down from 65
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), // Scaled down
              gradient: const LinearGradient(
                colors: [Color(0xFFE5C583), Color(0xFF8A6C30)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10, // Scaled down
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "VIEW FULL HISTORY",
                style: TextStyle(
                  color: Color(0xFF0B192C),
                  fontSize: 14, // Scaled down from 18
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Bottom glowing line
          Container(
            width: 150, // Scaled down
            height: 2, // Scaled down
            decoration: BoxDecoration(
              color: const Color(0xFF00D2FF),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.8), blurRadius: 8, spreadRadius: 1), // Scaled down
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context, FitnessProvider provider) {
    int totalPushups = 0;
    int totalSprints = 0;
    int totalCompletedDays = 0;
    
    if (provider.startDate != null) {
      for (int i = 0; i <= provider.daysPassed; i++) {
        DateTime checkDate = provider.startDate!.add(Duration(days: i));
        if (provider.isDayCompleted(checkDate)) {
          totalCompletedDays++;
          totalPushups += DateUtility.calculatePushUps(i);
          totalSprints += DateUtility.calculateSprints(i);
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF0B192C),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            border: Border.all(color: const Color(0xFF00D2FF).withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text(
                "LIFETIME HISTORY",
                style: TextStyle(color: Color(0xFFE5C583), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 32),
              // Lifetime Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(child: _buildLifetimeStatCard("TOTAL DAYS", "$totalCompletedDays", Icons.check_circle, const Color(0xFF00D2FF))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLifetimeStatCard("PUSH UPS", "$totalPushups", Icons.trending_up, const Color(0xFFE5C583))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLifetimeStatCard("SPRINTS", "$totalSprints", Icons.directions_run, const Color(0xFFE5C583))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "JOURNEY HEATMAP",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Heatmap Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.daysPassed + 1,
                  itemBuilder: (context, index) {
                    DateTime date = provider.startDate!.add(Duration(days: index));
                    bool isCompleted = provider.isDayCompleted(date);
                    return Container(
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isCompleted ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
                        boxShadow: isCompleted
                            ? [BoxShadow(color: const Color(0xFF00D2FF).withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)]
                            : [],
                      ),
                      child: isCompleted
                        ? const Icon(Icons.check, size: 18, color: Color(0xFF0B192C))
                        : Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLifetimeStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Tech Grid Background Painter matching the original image aesthetic
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const double spacing = 45.0;
    
    // Vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    // Horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Abstract architectural circles (Sci-Fi radar look)
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 200, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 350, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
