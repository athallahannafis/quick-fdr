import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/rc_theme.dart';

/// Custom vector widget rendering an RC Spur Gear intermeshed with a Pinion Gear.
class RcGearLogo extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const RcGearLogo({
    super.key,
    this.size = 120,
    this.primaryColor = RcTheme.accentCyan,
    this.accentColor = RcTheme.electricBlue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RcGearPainter(
          primaryColor: primaryColor,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

class _RcGearPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _RcGearPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.42, size.height * 0.46);
    final spurRadius = size.width * 0.35;

    // 1. Draw Large Spur Gear
    _drawGear(
      canvas: canvas,
      center: center,
      outerRadius: spurRadius,
      innerRadius: spurRadius * 0.82,
      holeRadius: spurRadius * 0.28,
      teethCount: 24,
      fillColor: RcTheme.surfaceNavy,
      strokeColor: primaryColor,
      strokeWidth: size.width * 0.02,
      spokesCount: 6,
    );

    // 2. Draw Smaller Pinion Gear meshing from bottom-right
    final pinionCenter = Offset(size.width * 0.72, size.height * 0.72);
    final pinionRadius = size.width * 0.18;

    _drawGear(
      canvas: canvas,
      center: pinionCenter,
      outerRadius: pinionRadius,
      innerRadius: pinionRadius * 0.78,
      holeRadius: pinionRadius * 0.32,
      teethCount: 12,
      fillColor: RcTheme.elevatedNavy,
      strokeColor: accentColor,
      strokeWidth: size.width * 0.018,
      spokesCount: 3,
    );
  }

  void _drawGear({
    required Canvas canvas,
    required Offset center,
    required double outerRadius,
    required double innerRadius,
    required double holeRadius,
    required int teethCount,
    required Color fillColor,
    required Color strokeColor,
    required double strokeWidth,
    required int spokesCount,
  }) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gearPath = Path();
    final angleStep = (math.pi * 2) / teethCount;
    final halfStep = angleStep / 2;
    final quarterStep = angleStep / 4;

    for (int i = 0; i < teethCount; i++) {
      final a0 = i * angleStep;
      final a1 = a0 + quarterStep;
      final a2 = a0 + halfStep;
      final a3 = a0 + 3 * quarterStep;

      // Inner root
      final p0 = Offset(center.dx + innerRadius * math.cos(a0), center.dy + innerRadius * math.sin(a0));
      // Outer tooth start
      final p1 = Offset(center.dx + outerRadius * math.cos(a1), center.dy + outerRadius * math.sin(a1));
      // Outer tooth end
      final p2 = Offset(center.dx + outerRadius * math.cos(a2), center.dy + outerRadius * math.sin(a2));
      // Inner root end
      final p3 = Offset(center.dx + innerRadius * math.cos(a3), center.dy + innerRadius * math.sin(a3));

      if (i == 0) {
        gearPath.moveTo(p0.dx, p0.dy);
      } else {
        gearPath.lineTo(p0.dx, p0.dy);
      }
      gearPath.lineTo(p1.dx, p1.dy);
      gearPath.lineTo(p2.dx, p2.dy);
      gearPath.lineTo(p3.dx, p3.dy);
    }
    gearPath.close();

    // Fill body
    canvas.drawPath(gearPath, fillPaint);
    // Outline body
    canvas.drawPath(gearPath, strokePaint);

    // Center shaft hole
    canvas.drawCircle(center, holeRadius, fillPaint);
    canvas.drawCircle(center, holeRadius, strokePaint);

    // Cutout spokes
    final spokePaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8;

    for (int s = 0; s < spokesCount; s++) {
      final sa = (math.pi * 2 / spokesCount) * s;
      final start = Offset(center.dx + holeRadius * math.cos(sa), center.dy + holeRadius * math.sin(sa));
      final end = Offset(center.dx + (innerRadius * 0.9) * math.cos(sa), center.dy + (innerRadius * 0.9) * math.sin(sa));
      canvas.drawLine(start, end, spokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
