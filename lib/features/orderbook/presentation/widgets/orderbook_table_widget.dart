import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_entry.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';

class OrderbookTableWidget extends StatelessWidget {
  final String symbol;
  final List<OrderbookEntry> entries;
  final int totalBidLot;
  final int totalOfferLot;

  const OrderbookTableWidget({
    super.key,
    required this.symbol,
    required this.entries,
    required this.totalBidLot,
    required this.totalOfferLot,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'en_US');

    int maxBidLot = 1;
    int maxOfferLot = 1;
    for (final e in entries) {
      maxBidLot = max(maxBidLot, e.bidLot);
      maxOfferLot = max(maxOfferLot, e.offerLot);
    }

    return Column(
      children: [
        // Table Header
        Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Freq',
                    style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Lot',
                    style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Bid',
                    style: TextStyle(fontSize: 8.5, color: AppColors.bidGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              VerticalDivider(width: 8, color: AppColors.border, thickness: 1),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Offer',
                    style: TextStyle(fontSize: 8.5, color: AppColors.offerRed, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lot',
                    style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Freq',
                    style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Depth Rows
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final row = entries[index];
              final isAlt = index % 2 == 1;

              final bidRatio = (row.bidLot / maxBidLot).clamp(0.0, 1.0);
              final offerRatio = (row.offerLot / maxOfferLot).clamp(0.0, 1.0);

              return Container(
                height: 19,
                decoration: BoxDecoration(
                  color: isAlt ? AppColors.tableRowAlt : Colors.transparent,
                ),
                child: Row(
                  children: [
                    // Bid Side (Click to Quick Buy)
                    Expanded(
                      flex: 8,
                      child: InkWell(
                        onTap: row.bidPrice > 0
                            ? () {
                                QuickTradeModal.show(
                                  context,
                                  symbol: symbol,
                                  price: row.bidPrice,
                                  isBuy: true,
                                );
                              }
                            : null,
                        hoverColor: AppColors.bidGreen.withValues(alpha: 0.15),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            // Bid Depth Bar
                            FractionallySizedBox(
                              alignment: Alignment.centerRight,
                              widthFactor: bidRatio * 0.9,
                              child: Container(
                                color: AppColors.bidGreenSubtle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        row.bidFreq > 0 ? '${row.bidFreq}' : '-',
                                        style: const TextStyle(fontSize: 8.5, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.bidLot > 0 ? numberFormat.format(row.bidLot) : '-',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          color: AppColors.textPrimary,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.bidPrice > 0 ? numberFormat.format(row.bidPrice.toInt()) : '-',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          color: AppColors.bidGreen,
                                          fontWeight: FontWeight.w600,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const VerticalDivider(width: 8, color: AppColors.border, thickness: 0.8),

                    // Offer Side (Click to Quick Sell)
                    Expanded(
                      flex: 8,
                      child: InkWell(
                        onTap: row.offerPrice > 0
                            ? () {
                                QuickTradeModal.show(
                                  context,
                                  symbol: symbol,
                                  price: row.offerPrice,
                                  isBuy: false,
                                );
                              }
                            : null,
                        hoverColor: AppColors.offerRed.withValues(alpha: 0.15),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Offer Depth Bar
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: offerRatio * 0.9,
                              child: Container(
                                color: AppColors.offerRedSubtle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        row.offerPrice > 0 ? numberFormat.format(row.offerPrice.toInt()) : '-',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          color: AppColors.offerRed,
                                          fontWeight: FontWeight.w600,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        row.offerLot > 0 ? numberFormat.format(row.offerLot) : '-',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          color: AppColors.textPrimary,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.offerFreq > 0 ? '${row.offerFreq}' : '-',
                                        style: const TextStyle(fontSize: 8.5, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Total Bid vs Total Offer Footer Summary
        Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Bid: ', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted)),
                      Text(
                        numberFormat.format(totalBidLot),
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.bidGreen),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Offer: ', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted)),
                      Text(
                        numberFormat.format(totalOfferLot),
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.offerRed),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
