import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Feature Screen: Interactive Candlestick / Line Technical Analysis Chart.
class ChartScreen extends StatefulWidget {
  final String symbol;

  const ChartScreen({super.key, required this.symbol});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _timeframe = '1D';
  bool _isCandle = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      child: Column(
        children: [
          // Timeframe & Mode Toolbar
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: AppColors.cardHeader,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.symbol,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(
                  color: AppColors.border,
                  width: 1,
                  indent: 4,
                  endIndent: 4,
                ),
                const SizedBox(width: 8),

                ...['1D', '1W', '1M', '1Y', 'ALL'].map((tf) {
                  final isSelected = _timeframe == tf;
                  return InkWell(
                    onTap: () => setState(() => _timeframe = tf),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.badgeBlue.withValues(alpha: 0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.badgeBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                InkWell(
                  onTap: () => setState(() => _isCandle = !_isCandle),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCandle
                              ? Icons.candlestick_chart
                              : Icons.show_chart,
                          size: 12,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isCandle ? 'Candles' : 'Line',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Technical Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomPaint(
                size: Size.infinite,
                painter: _CandleChartPainter(
                  symbol: widget.symbol,
                  isCandle: _isCandle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  final String symbol;
  final bool isCandle;

  _CandleChartPainter({required this.symbol, required this.isCandle});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const gridCols = 4;
    const gridRows = 4;
    for (int i = 0; i <= gridCols; i++) {
      final x = (size.width / gridCols) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int i = 0; i <= gridRows; i++) {
      final y = (size.height / gridRows) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final rand = Random(symbol.hashCode);
    final count = max(20, (size.width / 14).floor());
    final step = size.width / count;

    double basePrice = 5000.0;
    final prices = <double>[];
    for (int i = 0; i < count; i++) {
      basePrice += (rand.nextDouble() - 0.48) * 120;
      prices.add(basePrice);
    }

    final minP = prices.reduce(min);
    final maxP = prices.reduce(max);
    final range = max(1.0, maxP - minP);

    double getY(double p) =>
        size.height - 15 - ((p - minP) / range) * (size.height - 30);

    if (!isCandle) {
      final linePath = Path();
      final fillPath = Path();
      fillPath.moveTo(0, size.height);

      for (int i = 0; i < count; i++) {
        final x = i * step + step / 2;
        final y = getY(prices[i]);
        if (i == 0) {
          linePath.moveTo(x, y);
          fillPath.lineTo(x, y);
        } else {
          linePath.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }
      fillPath.lineTo(size.width, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.badgeBlue.withValues(alpha: 0.3),
            AppColors.badgeBlue.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);

      final linePaint = Paint()
        ..color = AppColors.badgeBlue
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(linePath, linePaint);
    } else {
      for (int i = 0; i < count; i++) {
        final x = i * step + step / 2;
        final open = prices[i];
        final close = open + (rand.nextDouble() - 0.49) * 80;
        final high = max(open, close) + rand.nextDouble() * 40;
        final low = min(open, close) - rand.nextDouble() * 40;

        final isGreen = close >= open;
        final candleColor = isGreen ? AppColors.bidGreen : AppColors.offerRed;

        final wickPaint = Paint()
          ..color = candleColor
          ..strokeWidth = 1.0;

        canvas.drawLine(Offset(x, getY(high)), Offset(x, getY(low)), wickPaint);

        final bodyTop = getY(max(open, close));
        final bodyBottom = getY(min(open, close));
        final bodyHeight = max(2.0, (bodyBottom - bodyTop).abs());

        final bodyPaint = Paint()
          ..color = candleColor
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, bodyTop + bodyHeight / 2),
            width: max(3.0, step - 3),
            height: bodyHeight,
          ),
          bodyPaint,
        );
      }
    }

    final fmt = NumberFormat('#,###', 'en_US');
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final axisPrices = [maxP, (maxP + minP) / 2, minP];

    for (final p in axisPrices) {
      textPainter.text = TextSpan(
        text: fmt.format(p.toInt()),
        style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 4, getY(p) - 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) =>
      oldDelegate.symbol != symbol || oldDelegate.isCandle != isCandle;
}
