import 'dart:math';
import 'package:flutter/material.dart';

/// Custom Painter that renders a mini sparkline trendline for a stock item.
class MiniSparklinePainter extends CustomPainter {
  final List<double> prices;
  final bool isPositive;

  const MiniSparklinePainter({required this.prices, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final range = max(1.0, maxPrice - minPrice);
    final step = size.width / (prices.length - 1);

    double getY(double p) =>
        size.height - 2 - ((p - minPrice) / range) * (size.height - 4);

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = i * step;
      final y = getY(prices[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final strokeColor = isPositive
        ? const Color(0xFF00C853) // Green
        : const Color(0xFFFF3B30); // Red

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MiniSparklinePainter oldDelegate) =>
      oldDelegate.prices != prices || oldDelegate.isPositive != isPositive;
}
