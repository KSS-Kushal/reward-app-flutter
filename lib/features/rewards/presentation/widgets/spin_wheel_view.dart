import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../domain/entities/spin_wheel.dart';

/// Rotation (radians, clockwise) that puts [segmentIndex] under the pointer
/// at the top of the wheel, after at least [extraTurns] full turns from
/// [currentAngle].
double spinTargetAngle({
  required double currentAngle,
  required int segmentIndex,
  required int segmentCount,
  int extraTurns = 5,
}) {
  const fullTurn = 2 * math.pi;
  final sweep = fullTurn / segmentCount;
  final desired = (fullTurn - (segmentIndex + 0.5) * sweep) % fullTurn;
  final delta = (desired - currentAngle % fullTurn) % fullTurn;
  return currentAngle + extraTurns * fullTurn + delta;
}

/// The wheel itself. Rotation is driven from outside via [angle].
class SpinWheelView extends StatelessWidget {
  const SpinWheelView({required this.segments, required this.angle, super.key});

  final List<SpinSegment> segments;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Transform.rotate(
                angle: angle,
                child: CustomPaint(painter: _WheelPainter(segments)),
              ),
            ),
          ),
          // Hub
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.coin, width: 4),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.star_rounded, color: AppColors.coin),
          ),
          // Pointer
          const Positioned(top: 0, child: _Pointer()),
        ],
      ),
    );
  }
}

class _Pointer extends StatelessWidget {
  const _Pointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(32, 38), painter: _PointerPainter());
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas
      ..drawShadow(path, Colors.black, 3, false)
      ..drawPath(path, Paint()..color = AppColors.error);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.segments);

  final List<SpinSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final sweep = 2 * math.pi / segments.length;

    // Outer rim
    canvas.drawCircle(center, radius, Paint()..color = AppColors.primaryDark);

    final inner = Rect.fromCircle(center: center, radius: radius - 8);
    for (var i = 0; i < segments.length; i++) {
      final start = -math.pi / 2 + i * sweep;
      canvas.drawArc(
        inner,
        start,
        sweep,
        true,
        Paint()..color = colorFromHex(segments[i].colorHex),
      );
      canvas.drawArc(
        inner,
        start,
        sweep,
        true,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _paintLabel(canvas, center, radius, start + sweep / 2, segments[i]);
    }

    // Rim lights
    final bulb = Paint()..color = AppColors.coinLight;
    for (var i = 0; i < segments.length * 2; i++) {
      final a = i * math.pi / segments.length;
      canvas.drawCircle(
        center + Offset(math.cos(a), math.sin(a)) * (radius - 4),
        2.5,
        bulb,
      );
    }
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    SpinSegment segment,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: segment.label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.14,
            ),
          ),
          if (segment.coins > 0)
            TextSpan(
              text: '\ncoins',
              style: TextStyle(color: Colors.white, fontSize: radius * 0.07),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle + math.pi / 2)
      ..translate(-painter.width / 2, -radius * 0.78);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
