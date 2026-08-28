import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/features/navigation/domain/entities/app_nav_tab.dart';
import 'package:stockbit_clone2/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/widgets/mini_sparkline_painter.dart';

/// Stock Item Card rendered inside the Watchlist panel & window slots.
/// Responsive & Overflow-Protected:
/// - Supports [onDoubleTap] to instantly navigate to the Stock Detail Analytics page.
/// - Shows Circular Emblem, Symbol, Multiplier Badge, Mini Sparkline, Last Price, and % Change.
class WatchlistStockCard extends StatelessWidget {
  final WatchlistItem item;
  final bool isSelected;

  const WatchlistStockCard({
    super.key,
    required this.item,
    required this.isSelected,
  });

  Color _getEmblemColor(String symbol) {
    final colors = [
      const Color(0xFFD97706), // Amber
      const Color(0xFF2563EB), // Blue
      const Color(0xFF059669), // Emerald
      const Color(0xFFDC2626), // Red
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF0891B2), // Cyan
      const Color(0xFFE11D48), // Rose
      const Color(0xFF4F46E5), // Indigo
    ];
    return colors[symbol.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final isGreen = item.isPositive;
    final changeColor = isGreen ? AppColors.bidGreen : AppColors.offerRed;
    final emblemColor = _getEmblemColor(item.symbol);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final showSparkline = cardWidth >= 210;
        final isUltraNarrow = cardWidth < 180;

        return InkWell(
          onTap: () {
            // Single tap: select stock & sync symbol to workspace
            context.read<WatchlistBloc>().add(SelectActiveStockEvent(item.symbol));
            try {
              context.read<WorkspaceBloc>().add(GlobalSearchSymbolEvent(item.symbol));
            } catch (_) {}
          },
          onDoubleTap: () {
            // Double tap: navigate directly to full Watchlist Stock Detail page
            context.read<WatchlistBloc>().add(SelectActiveStockEvent(item.symbol));
            try {
              context.read<WorkspaceBloc>().add(GlobalSearchSymbolEvent(item.symbol));
            } catch (_) {}
            context.read<NavigationCubit>().selectTab(AppNavTab.watchlist);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.symmetric(
              horizontal: isUltraNarrow ? 6 : 8,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF19232B)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  width: 3,
                ),
                bottom: const BorderSide(color: Color(0xFF1F242C), width: 0.6),
              ),
            ),
            child: Row(
              children: [
                // ── 1. Circular Stock Emblem Logo ─────────────────────────
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: emblemColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: emblemColor.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.symbol.length >= 2 ? item.symbol.substring(0, 2) : item.symbol,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: emblemColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ── 2. Symbol, Badge, & Full Company Name ──────────────────
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.symbol,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isUltraNarrow ? 11 : 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (!isUltraNarrow) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 0.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.badgeBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: AppColors.badgeBlue.withValues(alpha: 0.4),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                item.badge,
                                style: const TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.badgeBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 3. Middle: Mini Sparkline Graph ────────────────────────
                if (showSparkline) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 18,
                      child: CustomPaint(
                        painter: MiniSparklinePainter(
                          prices: item.sparklinePrices,
                          isPositive: isGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else
                  const SizedBox(width: 4),

                // ── 4. Right: Price & Percent Change ───────────────────────
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          fmt.format(item.lastPrice.toInt()),
                          style: TextStyle(
                            fontSize: isUltraNarrow ? 10.5 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isGreen ? '↗ ' : '↘ ',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: changeColor,
                              ),
                            ),
                            Text(
                              '${item.change.abs().toInt()} (${isGreen ? '+' : ''}${item.changePercentage.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: changeColor,
                                fontFeatures: const [FontFeature.tabularFigures()],
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
          ),
        );
      },
    );
  }
}
