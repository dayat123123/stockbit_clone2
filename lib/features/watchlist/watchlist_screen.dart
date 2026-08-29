import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/di/injection_container.dart' as di;
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_bloc.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_event.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_state.dart';
import 'package:stockbit_clone2/core/widgets/watchlist/watchlist_stock_card.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';

/// Feature Screen: Displays Watchlist inside a modular workspace window slot.
/// Fully responsive with zero RenderFlex overflow and high-aesthetic Stockbit dark styling.
class WatchlistScreen extends StatelessWidget {
  final String windowId;

  const WatchlistScreen({super.key, required this.windowId});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        try {
          ctx.read<WatchlistBloc>();
          return _WatchlistContent(windowId: windowId);
        } catch (_) {
          return BlocProvider<WatchlistBloc>(
            create: (_) =>
                di.sl<WatchlistBloc>()..add(const LoadWatchlistEvent()),
            child: _WatchlistContent(windowId: windowId),
          );
        }
      },
    );
  }
}

class _WatchlistContent extends StatefulWidget {
  final String windowId;

  const _WatchlistContent({required this.windowId});

  @override
  State<_WatchlistContent> createState() => _WatchlistContentState();
}

class _WatchlistContentState extends State<_WatchlistContent> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 220;

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
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 20,
                        color: AppColors.offerRed,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.offerRed,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => context.read<WatchlistBloc>().add(
                          const LoadWatchlistEvent(),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is WatchlistLoadedState) {
              final groups = state.groups;
              final currentGroup = state.activeGroup;
              final rawItems = currentGroup.symbols
                  .map((sym) => WatchlistBloc.resolveStockItem(sym))
                  .toList();

              // Apply local search filter if active
              final query = _searchController.text.trim().toUpperCase();
              final items = query.isEmpty
                  ? rawItems
                  : rawItems
                        .where(
                          (item) =>
                              item.symbol.toUpperCase().contains(query) ||
                              item.name.toUpperCase().contains(query),
                        )
                        .toList();

              return Container(
                color: AppColors.cardBg,
                child: Column(
                  children: [
                    // ── 1. Top Group Selector & Search Bar ─────────────────
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.cardHeader,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: _isSearching
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 13,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: 'Filter ticker...',
                                      hintStyle: TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.textMuted,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Group selector dropdown
                                Flexible(
                                  child: PopupMenuButton<WatchlistGroup>(
                                    tooltip: 'Select Watchlist Group',
                                    color: const Color(0xFF1B2028),
                                    padding: EdgeInsets.zero,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.bookmark_outline,
                                          size: 13,
                                          color: AppColors.primaryGreen,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            currentGroup.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
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
                                ),

                                // Search Icon & Count Badge
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          setState(() => _isSearching = true),
                                      borderRadius: BorderRadius.circular(3),
                                      child: const Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.search,
                                          size: 13,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    if (!isNarrow) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardSurface,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          '${items.length}',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                    ),

                    // ── 2. Table Column Header Bar ─────────────────────────
                    Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xFF101317),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 5,
                            child: Text(
                              'STOCK',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (constraints.maxWidth >= 230)
                            const Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  'CHART',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B7280),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          const Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'LAST / CHG%',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── 3. Table Stock List ────────────────────────────────
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                query.isEmpty
                                    ? 'No items in this watchlist'
                                    : 'No matching stocks found',
                                style: const TextStyle(
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

                                return InkWell(
                                  onTap: () {
                                    context.read<WatchlistBloc>().add(
                                      SelectActiveStockEvent(stock.symbol),
                                    );
                                    try {
                                      context.read<WorkspaceBloc>().add(
                                        ChangeWindowSymbolEvent(
                                          windowId: widget.windowId,
                                          newSymbol: stock.symbol,
                                        ),
                                      );
                                    } catch (_) {}
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
      },
    );
  }
}
