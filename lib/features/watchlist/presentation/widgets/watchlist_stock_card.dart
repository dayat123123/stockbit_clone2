import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/widgets/mini_sparkline_painter.dart';

/// Stock Item Card rendered inside the Watchlist side panel.
///
/// Follows Separation of Concerns (SoC):
/// - Displays Code, Multiplier Badge, Sparkline, Last Price, and % Change.
/// - When tapped, triggers [SelectActiveStockEvent] and dynamically broadcasts
///   [GlobalSearchSymbolEvent] to [WorkspaceBloc] to update the active window/chart.
class WatchlistStockCard extends StatelessWidget {
  final WatchlistItem item;
  final bool isSelected;

  const WatchlistStockCard({
    super.key,
    required this.item,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final isGreen = item.isPositive;
    final changeColor = isGreen ? AppColors.bidGreen : AppColors.offerRed;

    return InkWell(
      onTap: () {
        // 1. Update Watchlist selection state
        context.read<WatchlistBloc>().add(SelectActiveStockEvent(item.symbol));

        // 2. Broadcast active symbol to Core Workspace (updates active Orderbook/Chart window)
        context.read<WorkspaceBloc>().add(GlobalSearchSymbolEvent(item.symbol));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              width: 3,
            ),
            bottom: const BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // ── Left: Symbol & Badge ─────────────────────────────────────
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        item.symbol,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: AppColors.badgeBlue.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          item.badge,
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: AppColors.badgeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // ── Middle: Mini Sparkline Chart ─────────────────────────────
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 20,
                child: CustomPaint(
                  painter: MiniSparklinePainter(
                    prices: item.sparklinePrices,
                    isPositive: isGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // ── Right: Last Price & % Change Pill ────────────────────────
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fmt.format(item.lastPrice.toInt()),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: changeColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: changeColor.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${isGreen ? '+' : ''}${item.changePercentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: changeColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
