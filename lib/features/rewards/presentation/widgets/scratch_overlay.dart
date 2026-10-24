import 'package:flutter/material.dart';

/// Covers [child] with a scratchable foil.
///
/// [onScratchStart] fires on the first touch (used to request the prize from
/// the backend), [onThresholdReached] once [threshold] of the surface has
/// been cleared, after which the foil fades out entirely.
class ScratchOverlay extends StatefulWidget {
  const ScratchOverlay({
    required this.child,
    this.label = 'Scratch here',
    this.foilColors = const [Color(0xFFB8BEC6), Color(0xFFE3E7EC)],
    this.onScratchStart,
    this.onThresholdReached,
    this.enabled = true,
    this.threshold = 0.5,
    this.brushRadius = 22,
    super.key,
  });

  final Widget child;
  final String label;
  final List<Color> foilColors;
  final VoidCallback? onScratchStart;
  final VoidCallback? onThresholdReached;
  final bool enabled;
  final double threshold;
  final double brushRadius;

  @override
  State<ScratchOverlay> createState() => _ScratchOverlayState();
}

class _ScratchOverlayState extends State<ScratchOverlay> {
  /// Coverage is estimated on a coarse grid of cells.
  static const _grid = 16;

  final List<Offset?> _points = [];
  final Set<int> _clearedCells = {};
  bool _started = false;
  bool _revealed = false;

  void _scratch(Offset point, Size size) {
    if (!widget.enabled || _revealed) return;
    if (!_started) {
      _started = true;
      widget.onScratchStart?.call();
    }
    setState(() => _points.add(point));
    _markCells(point, size);
  }

  void _markCells(Offset point, Size size) {
    final cellW = size.width / _grid;
    final cellH = size.height / _grid;
    for (var x = 0; x < _grid; x++) {
      for (var y = 0; y < _grid; y++) {
        final cell = Offset((x + 0.5) * cellW, (y + 0.5) * cellH);
        if ((cell - point).distance <= widget.brushRadius) {
          _clearedCells.add(x * _grid + y);
        }
      }
    }
    if (_clearedCells.length / (_grid * _grid) >= widget.threshold) {
      setState(() => _revealed = true);
      widget.onThresholdReached?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            IgnorePointer(
              ignoring: _revealed,
              child: AnimatedOpacity(
                opacity: _revealed ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                child: Semantics(
                  label: widget.label,
                  hint: 'Drag your finger to scratch',
                  child: GestureDetector(
                    onPanStart: (d) => _scratch(d.localPosition, size),
                    onPanUpdate: (d) => _scratch(d.localPosition, size),
                    onPanEnd: (_) => _points.add(null),
                    child: CustomPaint(
                      size: size,
                      painter: _FoilPainter(
                        points: List.of(_points),
                        radius: widget.brushRadius,
                        colors: widget.foilColors,
                        label: widget.label,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Paints the foil and erases the scratched path from it on one layer.
class _FoilPainter extends CustomPainter {
  _FoilPainter({
    required this.points,
    required this.radius,
    required this.colors,
    required this.label,
  });

  final List<Offset?> points;
  final double radius;
  final List<Color> colors;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..saveLayer(rect, Paint())
      ..drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ).createShader(rect),
      );

    // Subtle diagonal sheen.
    final sheen = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 10;
    for (var x = -size.height; x < size.width; x += 36) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        sheen,
      );
    }

    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF5F6368),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, (size.height - text.height) / 2),
    );

    final eraser = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 2;
    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      if (current == null) continue;
      canvas.drawCircle(current, radius, eraser);
      final next = i + 1 < points.length ? points[i + 1] : null;
      if (next != null) canvas.drawLine(current, next, eraser);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoilPainter oldDelegate) =>
      oldDelegate.points.length != points.length;
}
