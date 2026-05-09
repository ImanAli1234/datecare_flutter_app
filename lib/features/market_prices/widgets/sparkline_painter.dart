/// ═══════════════════════════════════════════════════════════════════════════════
/// sparkline_painter.dart — Custom Sparkline Chart Renderer
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Draws a smooth price-history sparkline chart using Flutter's CustomPainter.
/// Features: Catmull-Rom curve interpolation, gradient fill, endpoint glow dot.
/// Used inside each PulseCard to visualize price trends.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// A custom painter that draws a smooth sparkline with a gradient fill beneath.
///
/// Uses Catmull-Rom-style cubic interpolation for organic, natural-looking curves.
/// The gradient fill fades from [lineColor] at the top to transparent at the bottom.
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final double strokeWidth;

  SparklinePainter({
    required this.data,
    required this.lineColor,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final points = _buildPoints(size);

    // ── Gradient fill beneath the curve ──────────────────────────────────
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    _addSmoothCurve(fillPath, points);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.18),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // ── The line itself ──────────────────────────────────────────────────
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    _addSmoothCurve(linePath, points);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // ── Endpoint dot ─────────────────────────────────────────────────────
    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(points.last, 3.0, dotPaint);

    // Glow ring around the endpoint
    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(points.last, 5.0, glowPaint);
  }

  /// Maps data values to pixel coordinates within the available size.
  List<Offset> _buildPoints(Size size) {
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final effectiveRange = range == 0 ? 1.0 : range;

    // Add vertical padding so the line doesn't touch edges
    const vPadding = 6.0;
    final drawHeight = size.height - vPadding * 2;

    return List.generate(data.length, (i) {
      final x = (i / (data.length - 1)) * size.width;
      final normalized = (data[i] - minVal) / effectiveRange;
      final y = vPadding + drawHeight * (1 - normalized); // Invert Y axis
      return Offset(x, y);
    });
  }

  /// Adds smooth cubic Bézier curves between points using Catmull-Rom interpolation.
  void _addSmoothCurve(Path path, List<Offset> points) {
    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

      // Catmull-Rom to cubic Bézier conversion
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6.0,
        p1.dy + (p2.dy - p0.dy) / 6.0,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6.0,
        p2.dy - (p3.dy - p1.dy) / 6.0,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
