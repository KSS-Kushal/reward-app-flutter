import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/captcha.dart';

/// Displays a captcha challenge: the backend image in production, or a
/// locally distorted rendering of the mock challenge text in development.
class CaptchaImage extends StatelessWidget {
  const CaptchaImage({required this.challenge, super.key});

  final CaptchaChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final imageUrl = challenge.imageUrl;
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        height: 96,
        width: double.infinity,
        child: imageUrl != null
            ? AppNetworkImage(url: imageUrl, fit: BoxFit.contain)
            : ExcludeSemantics(
                child: CustomPaint(
                  painter: _CaptchaPainter(
                    text: challenge.previewText ?? '',
                    seed: challenge.id.hashCode,
                  ),
                ),
              ),
      ),
    );
  }
}

class _CaptchaPainter extends CustomPainter {
  _CaptchaPainter({required this.text, required this.seed});

  final String text;
  final int seed;

  static const _inkColors = [
    Color(0xFF1C1C1E),
    Color(0xFF6A4BE0),
    Color(0xFF0B8F55),
    Color(0xFFB45309),
    Color(0xFF1F7AF0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.captchaSurface,
    );

    // Noise lines behind the text.
    for (var i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        Paint()
          ..color = _inkColors[random.nextInt(_inkColors.length)].withValues(
            alpha: 0.35,
          )
          ..strokeWidth = 1 + random.nextDouble() * 2,
      );
    }

    if (text.isEmpty) return;
    final slot = size.width / (text.length + 1);
    for (var i = 0; i < text.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: text[i],
          style: TextStyle(
            fontSize: 30 + random.nextDouble() * 10,
            fontWeight: FontWeight.w700,
            fontStyle: random.nextBool() ? FontStyle.italic : FontStyle.normal,
            color: _inkColors[random.nextInt(_inkColors.length)],
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = slot * (i + 0.5) + random.nextDouble() * 6;
      final dy =
          (size.height - painter.height) / 2 + random.nextDouble() * 12 - 6;
      canvas
        ..save()
        ..translate(dx + painter.width / 2, dy + painter.height / 2)
        ..rotate((random.nextDouble() - 0.5) * 0.7);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }

    // Noise dots on top.
    final dot = Paint()..color = Colors.black.withValues(alpha: 0.25);
    for (var i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 1.6,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) =>
      oldDelegate.text != text || oldDelegate.seed != seed;
}
