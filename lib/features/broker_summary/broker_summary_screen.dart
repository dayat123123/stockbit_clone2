import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Feature Screen: Displays Broker Summary and Net Accumulation/Distribution.
class BrokerSummaryScreen extends StatelessWidget {
  final String symbol;

  const BrokerSummaryScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final topBuyers = [
      {'code': 'YP', 'lot': '48.2K', 'val': '23.6B', 'avg': '4,890'},
      {'code': 'CC', 'lot': '35.1K', 'val': '17.2B', 'avg': '4,895'},
      {'code': 'PD', 'lot': '22.8K', 'val': '11.1B', 'avg': '4,885'},
      {'code': 'AK', 'lot': '19.4K', 'val': '9.5B', 'avg': '4,900'},
    ];

    final topSellers = [
      {'code': 'ZP', 'lot': '52.1K', 'val': '25.4B', 'avg': '4,880'},
      {'code': 'BK', 'lot': '31.4K', 'val': '15.3B', 'avg': '4,875'},
      {'code': 'CS', 'lot': '20.6K', 'val': '10.1B', 'avg': '4,890'},
      {'code': 'RX', 'lot': '18.2K', 'val': '8.9B', 'avg': '4,885'},
    ];

    return Container(
      color: AppColors.cardBg,
      child: Column(
        children: [
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: AppColors.cardHeader,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Foreign Flow: +14.2B',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bidGreen,
                  ),
                ),
                Text(
                  'Net: ACCUMULATION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                        alignment: Alignment.center,
                        color: AppColors.bidGreen.withValues(alpha: 0.12),
                        child: const Text(
                          'TOP BUYERS (B)',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bidGreen,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: topBuyers.length,
                          separatorBuilder: (_, _) =>
                              const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (_, i) {
                            final b = topBuyers[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    b['code']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.bidGreen,
                                    ),
                                  ),
                                  Text(
                                    b['lot']!,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    b['avg']!,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
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
                ),
                const VerticalDivider(color: AppColors.border, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                        alignment: Alignment.center,
                        color: AppColors.offerRed.withValues(alpha: 0.12),
                        child: const Text(
                          'TOP SELLERS (S)',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.offerRed,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: topSellers.length,
                          separatorBuilder: (_, _) =>
                              const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (_, i) {
                            final s = topSellers[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    s['code']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.offerRed,
                                    ),
                                  ),
                                  Text(
                                    s['lot']!,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    s['avg']!,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
