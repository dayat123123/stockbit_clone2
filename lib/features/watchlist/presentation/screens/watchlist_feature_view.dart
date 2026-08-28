import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/navigation/domain/entities/app_nav_tab.dart';
import 'package:stockbit_clone2/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_entry.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_state.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/widgets/watchlist_stock_card.dart';

/// Stockbit Pro Watchlist & Stock Analytics Terminal.
/// Styled 100% with standard [AppColors] dark theme palette.
/// When user clicks BUY/Order, it navigates directly to the dedicated Orders tab.
class WatchlistFeatureView extends StatefulWidget {
  const WatchlistFeatureView({super.key});

  @override
  State<WatchlistFeatureView> createState() => _WatchlistFeatureViewState();
}

class _WatchlistFeatureViewState extends State<WatchlistFeatureView> {
  int _selectedSubTabIndex = 0;
  String _selectedTimeframe = '1D';

  final List<String> _subTabs = [
    'Chart',
    'Keystats',
    'Analysis',
    'Financials',
    'Comparison',
    'Seasonality',
    'Corp. Action',
    'Insider',
    'Profile',
    'Stream',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        String activeSymbol = 'PACK';
        if (state is WatchlistLoadedState && state.activeSymbol != null) {
          activeSymbol = state.activeSymbol!;
        }

        return Container(
          color: AppColors.background,
          child: Column(
            children: [
              // ── 1. Top Stock Details Sub-Header Bar ───────────────────────
              _buildTopStockSubHeader(activeSymbol),

              // ── 2. Main 3-Column Layout ───────────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    // Column 1: Left Watchlist Stock List Panel (~250px)
                    _buildLeftWatchlistPanel(state, activeSymbol),

                    const VerticalDivider(color: AppColors.border, width: 1),

                    // Column 2: Center Pro Chart & Tabs (~Flex 6)
                    Expanded(
                      flex: 6,
                      child: _buildCenterChartSection(activeSymbol),
                    ),

                    const VerticalDivider(color: AppColors.border, width: 1),

                    // Column 3: Right Live Orderbook & Running Trades (~290px)
                    SizedBox(
                      width: 290,
                      child: _buildRightOrderbookAndTrades(activeSymbol),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── 1. Top Stock Header Bar ───────────────────────────────────────────────
  Widget _buildTopStockSubHeader(String symbol) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.cardHeader,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Circular Logo Emblem
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 1),
            ),
            child: Center(
              child: Text(
                symbol.length >= 2 ? symbol.substring(0, 2) : symbol,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Symbol & Company Name
          Text(
            symbol,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _getCompanyName(symbol),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 10),

          // Badges
          _buildGreenPill('Barang Baku'),
          const SizedBox(width: 4),
          _buildGreenPill('Syariah'),
          const SizedBox(width: 4),
          _buildGreenPill('Papan Akselerasi'),

          const Spacer(),

          // Action Buttons: Alert & Watchlist
          _buildHeaderActionBtn(Icons.alarm, 'Alert'),
          const SizedBox(width: 6),
          _buildHeaderActionBtn(Icons.star_border, 'Watchlist'),
          const SizedBox(width: 10),

          // Grid View Icon
          const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 10),

          // Quick BUY Button (Navigates to Orders tab)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(60, 26),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              elevation: 0,
            ),
            onPressed: () {
              context.read<NavigationCubit>().selectTab(AppNavTab.order);
            },
            child: const Text('BUY', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),

          // Open Trading Account Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primaryGreen, width: 1),
            ),
            child: const Text(
              'Open Trading Account',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreenPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.35), width: 0.6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
      ),
    );
  }

  Widget _buildHeaderActionBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ─── 2. Left Watchlist Panel ───────────────────────────────────────────────
  Widget _buildLeftWatchlistPanel(WatchlistState state, String activeSymbol) {
    if (state is! WatchlistLoadedState) {
      return Container(
        width: 250,
        color: AppColors.cardBg,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2),
        ),
      );
    }

    final groups = state.groups;
    final currentGroup = state.selectedGroup;
    final items = state.filteredItems;

    return Container(
      width: 250,
      color: AppColors.cardBg,
      child: Column(
        children: [
          // Header Bar
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: AppColors.cardHeader,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              children: [
                // Group selector pill
                PopupMenuButton<WatchlistGroup>(
                  color: AppColors.cardSurface,
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentGroup.title,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 13, color: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => groups.map((g) {
                    return PopupMenuItem<WatchlistGroup>(
                      value: g,
                      child: Text(
                        g.title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: g.id == currentGroup.id ? FontWeight.bold : FontWeight.normal,
                          color: g.id == currentGroup.id ? AppColors.primaryGreen : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onSelected: (selected) {
                    context.read<WatchlistBloc>().add(SelectWatchlistGroupEvent(selected.id));
                  },
                ),
                const Spacer(),
                const Icon(Icons.add, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Icon(Icons.swap_vert, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),

          // Watchlist Stock Items List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final stock = items[index];
                return WatchlistStockCard(
                  item: stock,
                  isSelected: stock.symbol == activeSymbol,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. Center Pro Chart & Tabs ────────────────────────────────────────────
  Widget _buildCenterChartSection(String symbol) {
    return Column(
      children: [
        // Sub-tabs Bar (Chart, Keystats, Analysis, Financials, etc.)
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: AppColors.cardHeader,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _subTabs.length,
            itemBuilder: (context, idx) {
              final isSelected = idx == _selectedSubTabIndex;
              return InkWell(
                onTap: () => setState(() => _selectedSubTabIndex = idx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _subTabs[idx],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Interactive Pro Chart Body
        Expanded(
          flex: 6,
          child: Row(
            children: [
              // Left Drawing Tools Rail
              _buildChartToolsRail(),

              // Chart Canvas & Controls
              Expanded(
                child: Column(
                  children: [
                    // Top Chart Options Bar
                    _buildChartOptionsBar(symbol),

                    // Chart Graph Area with clean green area curve
                    Expanded(
                      child: Container(
                        color: AppColors.cardBg,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _ProAreaChartPainter(symbol: symbol),
                        ),
                      ),
                    ),

                    // Bottom Timeframe Selector & Time Bar
                    _buildChartBottomTimeBar(),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(color: AppColors.border, height: 1),

        // Bottom Portfolio & Orders Drawer
        SizedBox(
          height: 140,
          child: _buildBottomPortfolioDrawer(),
        ),
      ],
    );
  }

  Widget _buildChartToolsRail() {
    final icons = [
      Icons.add,
      Icons.show_chart,
      Icons.timeline,
      Icons.brush,
      Icons.text_fields,
      Icons.category_outlined,
      Icons.straighten,
      Icons.zoom_in,
      Icons.lock_outline,
    ];

    return Container(
      width: 32,
      color: AppColors.cardHeader,
      child: ListView.builder(
        itemCount: icons.length,
        itemBuilder: (context, idx) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(icons[idx], size: 14, color: AppColors.textSecondary),
          );
        },
      ),
    );
  }

  Widget _buildChartOptionsBar(String symbol) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.cardSurface,
      child: Row(
        children: [
          Text(
            '$symbol · 1D · IDX',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 6),
          const Text(
            '510 +44 (+9.44%)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.bidGreen),
          ),
          const Spacer(),
          const Icon(Icons.tune, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          const Icon(Icons.fullscreen, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          const Icon(Icons.camera_alt_outlined, size: 12, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildChartBottomTimeBar() {
    final timeframes = ['1D', '5D', '1M', '3M', '6M', '1Y', '5Y', 'All'];

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.cardHeader,
      child: Row(
        children: [
          ...timeframes.map((tf) {
            final isSelected = tf == _selectedTimeframe;
            return InkWell(
              onTap: () => setState(() => _selectedTimeframe = tf),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  tf,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Text(
            '09:40:44 UTC',
            style: TextStyle(fontSize: 9, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          const Text(
            '%  log  auto',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPortfolioDrawer() {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Stocks ▾', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 14),
              InkWell(
                onTap: () => context.read<NavigationCubit>().selectTab(AppNavTab.order),
                child: const Text('Order', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 14),
              const Text('History', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.borderLight),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => context.read<NavigationCubit>().selectTab(AppNavTab.order),
            child: const Text(
              'Go to Orders Management',
              style: TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ─── 4. Right Live Orderbook & Running Trades ──────────────────────────────
  Widget _buildRightOrderbookAndTrades(String symbol) {
    return Container(
      color: AppColors.cardBg,
      child: Column(
        children: [
          // Orderbook Mini Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: AppColors.cardHeader,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(symbol, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const Text(
                  '510 ↗ 44 (+9.44%)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bidGreen),
                ),
              ],
            ),
          ),

          // Orderbook Depth Mini Table (Top half)
          Expanded(
            flex: 5,
            child: _buildOrderbookDepthTable(),
          ),

          const Divider(color: AppColors.border, height: 1),

          // Running Trades Section Header (Bottom half)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: AppColors.cardHeader,
            child: Row(
              children: const [
                Text('Running Trade ↗', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Spacer(),
                Icon(Icons.pause, size: 12, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Icon(Icons.filter_list, size: 12, color: AppColors.textSecondary),
              ],
            ),
          ),

          Expanded(
            flex: 4,
            child: _buildRunningTradesStream(symbol),
          ),

          // Full-width Bottom Buy Button (Navigates to Orders tab)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bidGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<NavigationCubit>().selectTab(AppNavTab.order);
                },
                child: const Text('Buy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderbookDepthTable() {
    final bids = [
      const OrderbookEntry(bidPrice: 510, offerPrice: 515, bidLot: 182865, offerLot: 41200, bidFreq: 159, offerFreq: 290),
      const OrderbookEntry(bidPrice: 505, offerPrice: 520, bidLot: 72153, offerLot: 78900, bidFreq: 90, offerFreq: 430),
      const OrderbookEntry(bidPrice: 500, offerPrice: 525, bidLot: 102799, offerLot: 49000, bidFreq: 251, offerFreq: 310),
      const OrderbookEntry(bidPrice: 498, offerPrice: 530, bidLot: 122148, offerLot: 89500, bidFreq: 140, offerFreq: 520),
      const OrderbookEntry(bidPrice: 496, offerPrice: 535, bidLot: 187469, offerLot: 32000, bidFreq: 181, offerFreq: 220),
      const OrderbookEntry(bidPrice: 494, offerPrice: 540, bidLot: 22717, offerLot: 110000, bidFreq: 102, offerFreq: 680),
      const OrderbookEntry(bidPrice: 492, offerPrice: 545, bidLot: 21595, offerLot: 21500, bidFreq: 71, offerFreq: 150),
      const OrderbookEntry(bidPrice: 490, offerPrice: 550, bidLot: 31306, offerLot: 17800, bidFreq: 177, offerFreq: 125),
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bids.length,
      itemBuilder: (context, idx) {
        final b = bids[idx];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
          child: Row(
            children: [
              Expanded(child: Text('${b.bidFreq}', style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted))),
              Expanded(
                flex: 2,
                child: Text(
                  NumberFormat('#,###').format(b.bidLot),
                  style: const TextStyle(fontSize: 8.5, color: AppColors.textPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  '${b.bidPrice.toInt()}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.bidGreen),
                ),
              ),
              const Expanded(child: Text('-', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted))),
              const Expanded(child: Text('-', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRunningTradesStream(String symbol) {
    final trades = [
      {'time': '16:14:50', 'price': '510 (+9.44%)', 'lot': '1,263', 'val': '64.4M'},
      {'time': '16:14:50', 'price': '510 (+9.44%)', 'lot': '10', 'val': '510.0K'},
      {'time': '16:14:50', 'price': '510 (+9.44%)', 'lot': '20', 'val': '1.0M'},
      {'time': '16:14:50', 'price': '510 (+9.44%)', 'lot': '201', 'val': '10.3M'},
      {'time': '16:14:50', 'price': '510 (+9.44%)', 'lot': '10', 'val': '510.0K'},
      {'time': '16:14:50', 'price': '510 (+9.44%)', 'lot': '1', 'val': '51.0K'},
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: trades.length,
      itemBuilder: (context, idx) {
        final t = trades[idx];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t['time']!, style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted)),
              Text(symbol, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(t['price']!, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.bidGreen)),
              Text(t['lot']!, style: const TextStyle(fontSize: 8.5, color: AppColors.textPrimary)),
              Text(t['val']!, style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted)),
            ],
          ),
        );
      },
    );
  }

  String _getCompanyName(String symbol) {
    switch (symbol) {
      case 'PACK':
        return 'Abadi Nusantara Hijau Investama Tbk';
      case 'BBCA':
        return 'Bank Central Asia Tbk';
      case 'BBRI':
        return 'Bank Rakyat Indonesia Tbk';
      case 'BMRI':
        return 'Bank Mandiri Tbk';
      case 'TLKM':
        return 'Telkom Indonesia Tbk';
      case 'ASII':
        return 'Astra International Tbk';
      case 'MDKA':
        return 'Merdeka Copper Gold Tbk';
      case 'CBRE':
        return 'Cakra Buana Resources Tbk';
      case 'INTP':
        return 'Indocement Tunggal Prakarsa Tbk';
      case 'ANTM':
        return 'Aneka Tambang Tbk';
      case 'INCO':
        return 'Vale Indonesia Tbk';
      case 'SMGR':
        return 'Semen Indonesia Tbk';
      case 'BRPT':
        return 'Barito Pacific Tbk';
      default:
        return '$symbol Corporation Tbk';
    }
  }
}

/// Area Chart Painter styled with [AppColors.primaryGreen]
class _ProAreaChartPainter extends CustomPainter {
  final String symbol;

  const _ProAreaChartPainter({required this.symbol});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 5; i++) {
      final y = h * (i / 6.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }
    for (int i = 1; i <= 6; i++) {
      final x = w * (i / 7.0);
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Pro Area Curve Path
    final path = Path();
    path.moveTo(0, h * 0.78);
    path.lineTo(w * 0.35, h * 0.78);
    path.quadraticBezierTo(w * 0.42, h * 0.78, w * 0.45, h * 0.70);
    path.lineTo(w * 0.50, h * 0.55);
    path.lineTo(w * 0.54, h * 0.65);
    path.lineTo(w * 0.58, h * 0.45);
    path.lineTo(w * 0.62, h * 0.58);
    path.lineTo(w * 0.65, h * 0.20);
    path.lineTo(w * 0.67, h * 0.50);
    path.lineTo(w * 0.70, h * 0.42);
    path.lineTo(w * 0.74, h * 0.35);

    // Stroke in Primary Green
    final strokePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Gradient Fill under curve
    final fillPath = Path.from(path)
      ..lineTo(w * 0.74, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryGreen.withValues(alpha: 0.35),
          AppColors.primaryGreen.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(fillPath, fillPaint);

    // Active price tag indicator on right (510)
    final priceBadgePaint = Paint()..color = AppColors.primaryGreenDark;
    final badgeRect = Rect.fromLTWH(w - 38, h * 0.35 - 9, 38, 18);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(2)), priceBadgePaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '510',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(w - 30, h * 0.35 - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
