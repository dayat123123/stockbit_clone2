import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_state.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/widgets/watchlist_stock_card.dart';

/// Feature Screen: Displays Watchlist inside a modular workspace window slot.
class WatchlistScreen extends StatelessWidget {
  final String windowId;

  const WatchlistScreen({super.key, required this.windowId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state is WatchlistLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 2,
            ),
          );
        }

        if (state is WatchlistErrorState) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.offerRed, fontSize: 11),
            ),
          );
        }

        if (state is WatchlistLoadedState) {
          final groups = state.groups;
          final currentGroup = state.selectedGroup;
          final items = state.filteredItems;

          return Container(
            color: AppColors.cardBg,
            child: Column(
              children: [
                // Group selector
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<WatchlistGroup>(
                        tooltip: 'Select Watchlist Group',
                        color: AppColors.cardBg,
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bookmark_outline,
                              size: 13,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentGroup.title,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                        itemBuilder: (context) => groups.map((g) {
                          return PopupMenuItem<WatchlistGroup>(
                            value: g,
                            child: Text(
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
                          );
                        }).toList(),
                        onSelected: (selected) {
                          context.read<WatchlistBloc>().add(
                                SelectWatchlistGroupEvent(selected.id),
                              );
                        },
                      ),
                      Text(
                        '${items.length} items',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Table List
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'No items in this watchlist',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final stock = items[index];
                            final isSelected = stock.symbol == state.activeSymbol;

                            return InkWell(
                              onTap: () {
                                context.read<WatchlistBloc>().add(SelectActiveStockEvent(stock.symbol));
                                context.read<WorkspaceBloc>().add(
                                      ChangeWindowSymbolEvent(
                                        windowId: windowId,
                                        newSymbol: stock.symbol,
                                      ),
                                    );
                              },
                              child: WatchlistStockCard(
                                item: stock,
                                isSelected: isSelected,
                              ),
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
