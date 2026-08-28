import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_state.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/widgets/watchlist_stock_card.dart';

/// Professional Dark Trading Terminal Watchlist Side-Panel (Left Side).
///
/// Follows Separation of Concerns (SoC) & Clean Architecture:
/// - Replaces static navigation with interactive, scrollable real-time stock lists.
/// - Connects to [WatchlistBloc] and broadcasts symbol changes to workspace.
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
          if (!state.isPanelVisible) {
            // Collapsed pill strip
            return InkWell(
              onTap: () => context.read<WatchlistBloc>().add(
                const ToggleWatchlistPanelEvent(),
              ),
              child: Container(
                width: 28,
                color: AppColors.sidebarBg,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'WATCHLIST (${state.filteredItems.length})',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final groups = state.groups;
          final currentGroup = state.selectedGroup;
          final items = state.filteredItems;

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
                // ── 1. Top Header: Group Dropdown & Collapse Toggle ──────────
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
                      const SizedBox(width: 8),

                      // Collapse Panel Button
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        tooltip: 'Collapse Watchlist Panel',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          context.read<WatchlistBloc>().add(
                            const ToggleWatchlistPanelEvent(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ── 2. Search & Filter Bar ───────────────────────────────────
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.cardSurface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textPrimary,
                          ),
                          onChanged: (val) {
                            context.read<WatchlistBloc>().add(
                              FilterWatchlistQueryEvent(val),
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: 'Filter stock symbol / name...',
                            hintStyle: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 22,
                              minHeight: 22,
                            ),
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 4,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${items.length} stocks',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 3. Table Column Header ───────────────────────────────────
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

                // ── 4. Scrollable List of Stocks ─────────────────────────────
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'No matching stocks found',
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
