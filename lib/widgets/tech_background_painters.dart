// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class BottomPlexusPainter extends CustomPainter {
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

class HudRadarPainter extends CustomPainter {
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

    canvas.drawCircle(center, radius * 0.6, ringPaint);
    canvas.drawCircle(center, radius * 0.85, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height * 0.15), tickPaint);
    canvas.drawLine(Offset(center.dx, size.height * 0.85), Offset(center.dx, size.height), tickPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width * 0.15, center.dy), tickPaint);
    canvas.drawLine(Offset(size.width * 0.85, center.dy), Offset(size.width, center.dy), tickPaint);

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

class NavyBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final gridHeight = size.height * 0.8;
    final startY = size.height - gridHeight;

    final numCols = 10;
    final vanishingPoint = Offset(size.width / 2, startY - size.height * 0.5);

    for (int i = 0; i <= numCols; i++) {
      final bottomX = size.width * (i / numCols);
      final startPt = Offset(bottomX, size.height);
      final t = 0.45;
      final endPt = Offset(startPt.dx + (vanishingPoint.dx - startPt.dx) * t, startPt.dy + (vanishingPoint.dy - startPt.dy) * t);
      canvas.drawLine(startPt, endPt, paint);
    }

    for (int i = 0; i <= 5; i++) {
      final factor = math.pow(i / 5, 1.5);
      final y = startY + (gridHeight * factor);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

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
