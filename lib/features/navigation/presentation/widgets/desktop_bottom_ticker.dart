import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Responsive Fixed Bottom Status Bar & Market Running Ticker
/// styled precisely after the reference terminal layout.
class DesktopBottomTicker extends StatefulWidget {
  const DesktopBottomTicker({super.key});

  @override
  State<DesktopBottomTicker> createState() => _DesktopBottomTickerState();
}

class _DesktopBottomTickerState extends State<DesktopBottomTicker> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 24,
          width: constraints.maxWidth,
          decoration: const BoxDecoration(
            color: AppColors.headerBg,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Left: IHSG & Running Tickers ─────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IHSG
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'IHSG ',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            '6,523.69 ',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: AppColors.bidGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '1.94(+0.03%)',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: AppColors.bidGreen,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Trending
                      const Text(
                        'Trending ',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Text(
                        '25(+1.28%)',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: AppColors.bidGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Real-time Stock Tickers
                      _buildTickerItem('INET', '338', '12(-3.43%)', AppColors.offerRed),
                      const SizedBox(width: 12),
                      _buildTickerItem('KIJA', '208', '10(-4.59%)', AppColors.offerRed),
                      const SizedBox(width: 12),
                      _buildTickerItem('CUAN', '810', '5(-0.61%)', AppColors.offerRed),
                      const SizedBox(width: 12),
                      _buildTickerItem('BUMI', '190', '4(-2.06%)', AppColors.offerRed),
                      const SizedBox(width: 12),
                      _buildTickerItem('RANS', '214', '6(-2.73%)', AppColors.offerRed),
                      const SizedBox(width: 12),
                      _buildTickerItem('PACK', '510', '44(+9.44%)', AppColors.bidGreen),
                      const SizedBox(width: 12),
                      _buildTickerItem('BBCA', '6,475', '75(+1.17%)', AppColors.bidGreen),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // ── Right: Latency & Clock ───────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.signal_cellular_alt, size: 11, color: AppColors.primaryDark),
                      const SizedBox(width: 8),
                      Text(
                        _currentTime,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTickerItem(
    String symbol,
    String price,
    String change,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 3),
        Text(
          change,
          style: TextStyle(
            fontSize: 8.5,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
