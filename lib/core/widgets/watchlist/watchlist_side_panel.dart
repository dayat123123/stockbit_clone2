import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_bloc.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_event.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_state.dart';
import 'package:stockbit_clone2/core/widgets/watchlist/watchlist_stock_card.dart';

/// Professional Dark Trading Terminal Watchlist Side-Panel (Left Side).
class WatchlistSidePanel extends StatelessWidget {
  const WatchlistSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state is WatchlistLoadingState) {
          return Container(
            width: 270,
            color: AppColors.sidebarBg,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (state is WatchlistErrorState) {
          return Container(
            width: 270,
            color: AppColors.sidebarBg,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 28,
                    color: AppColors.offerRed,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<WatchlistBloc>().add(
                      const LoadWatchlistEvent(),
                    ),
                    child: const Text('Retry', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is WatchlistLoadedState) {
          final groups = state.groups;
          final currentGroupId = state.activeGroupId;
          final currentGroup = groups.firstWhere(
            (g) => g.id == currentGroupId,
            orElse: () => groups.isNotEmpty
                ? groups.first
                : const WatchlistGroup(
                    id: 'all',
                    title: 'Watchlist',
                    symbols: [],
                  ),
          );
          final items = state.items;

          return Container(
            width: 270,
            decoration: const BoxDecoration(
              color: AppColors.sidebarBg,
              border: Border(
                right: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Top Header: Group Dropdown ────────────────────────────
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.cardHeader,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Watchlist Group Dropdown
                      Expanded(
                        child: PopupMenuButton<WatchlistGroup>(
                          tooltip: 'Select Watchlist Group',
                          color: AppColors.cardBg,
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bookmark,
                                size: 14,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  currentGroup.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                          itemBuilder: (context) => groups.map((g) {
                            return PopupMenuItem<WatchlistGroup>(
                              value: g,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 14,
                                    color: g.id == currentGroup.id
                                        ? AppColors.primaryGreen
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    g.title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: g.id == currentGroup.id
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: g.id == currentGroup.id
                                          ? AppColors.primaryGreen
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onSelected: (selected) {
                            context.read<WatchlistBloc>().add(
                              SelectWatchlistGroupEvent(selected.id),
                            );
                          },
                        ),
                      ),

                      // Add Stock / Watchlist (+)
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Add Stock to Watchlist',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // ── 2. Table Column Header ───────────────────────────────────
                Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.cardBg,
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'STOCK',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            'TREND (1D)',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'LAST / CHG',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 0.5),

                // ── 3. Scrollable List of Stocks ─────────────────────────────
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'No stocks found',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final stock = items[index];
                            final isSelected =
                                stock.symbol == state.activeSymbol;

                            return WatchlistStockCard(
                              key: ValueKey(stock.symbol),
                              item: stock,
                              isSelected: isSelected,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
