import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Feature Screen: Displays stock fundamental screener.
class ScreenerScreen extends StatelessWidget {
  const ScreenerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final presets = [
      'High Dividend Yield',
      'Breakout 52W High',
      'Undervalued PE < 10',
      'MACD Bullish Cross',
    ];
    final results = [
      {'sym': 'UNTR', 'pe': '4.8x', 'roe': '28.4%', 'div': '10.5%'},
      {'sym': 'BMRI', 'pe': '10.2x', 'roe': '20.1%', 'div': '5.2%'},
      {'sym': 'BBRI', 'pe': '11.8x', 'roe': '19.8%', 'div': '6.1%'},
      {'sym': 'ITMG', 'pe': '4.2x', 'roe': '31.2%', 'div': '16.4%'},
      {'sym': 'PTBA', 'pe': '5.1x', 'roe': '24.5%', 'div': '14.2%'},
    ];

    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: i == 0
                      ? AppColors.badgeBlue.withValues(alpha: 0.2)
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: i == 0 ? AppColors.badgeBlue : AppColors.border,
                  ),
                ),
                child: Text(
                  presets[i],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                    color: i == 0
                        ? AppColors.badgeBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: AppColors.cardHeader,
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Stock',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'P/E',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'ROE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Div Yield',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.border, height: 1),
              itemBuilder: (_, i) {
                final r = results[i];
                return Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  color: i.isEven ? AppColors.cardBg : AppColors.tableRowAlt,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          r['sym']!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          r['pe']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          r['roe']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.bidGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          r['div']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.araYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
