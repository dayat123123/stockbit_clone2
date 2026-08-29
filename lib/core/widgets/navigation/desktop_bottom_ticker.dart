import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/navigation/models/app_nav_tab.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_bloc.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';

/// Responsive Fixed Bottom Status Bar & Market Running Ticker.
/// - Left: IHSG & Trending indices stay permanently stationary / pinned.
/// - Middle: Ultra-smooth 60/120 FPS Marquee. Pauses on hover, clicks to open Watchlist with stock pre-selected across the entire width.
/// - Right: Network latency indicator & real-time clock.
class DesktopBottomTicker extends StatelessWidget {
  const DesktopBottomTicker({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.headerBg,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            // ── 1. Left (Static / Stationary): IHSG & Trending ──────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IHSG
                InkWell(
                  onTap: () {
                    context.read<WatchlistBloc>().add(
                      const SelectActiveStockEvent('IHSG'),
                    );
                    try {
                      context.read<WorkspaceBloc>().add(
                        const GlobalSearchSymbolEvent('IHSG'),
                      );
                    } catch (_) {}
                    context.read<NavigationCubit>().selectTab(
                      AppNavTab.watchlist,
                      symbol: 'IHSG',
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'IHSG ',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '6,523.69 ',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppColors.bidGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '1.94(+0.03%)',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: AppColors.bidGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
                const Text(
                  '|',
                  style: TextStyle(fontSize: 9, color: AppColors.borderLight),
                ),
                const SizedBox(width: 12),

                // Trending
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Trending ',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '25(+1.28%)',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: AppColors.bidGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),
                const Text(
                  '|',
                  style: TextStyle(fontSize: 9, color: AppColors.borderLight),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── 2. Middle: Ultra-smooth Marquee (100% Clickable Across Entire Width) ─
            const Expanded(child: _SmoothMarqueeTickerList()),

            const SizedBox(width: 12),
            const Text(
              '|',
              style: TextStyle(fontSize: 9, color: AppColors.borderLight),
            ),
            const SizedBox(width: 12),

            // ── 3. Right (Static): Latency & Isolated Clock ─────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 11,
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: 8),
                _RealtimeClockWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ultra-smooth Marquee Ticker running via ScrollController and frame-synced Ticker.
/// Ensures 100% accurate gesture and click detection across the entire width of the screen.
class _SmoothMarqueeTickerList extends StatefulWidget {
  const _SmoothMarqueeTickerList();

  @override
  State<_SmoothMarqueeTickerList> createState() =>
      _SmoothMarqueeTickerListState();
}

class _SmoothMarqueeTickerListState extends State<_SmoothMarqueeTickerList>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  final GlobalKey _singleSetKey = GlobalKey();
  double _singleSetWidth = 1400.0;
  bool _isHovered = false;
  Duration _lastElapsed = Duration.zero;

  final List<Map<String, dynamic>> _tickers = [
    {
      'symbol': 'INET',
      'price': '338',
      'change': '12(-3.43%)',
      'isGreen': false,
    },
    {
      'symbol': 'KIJA',
      'price': '208',
      'change': '10(-4.59%)',
      'isGreen': false,
    },
    {'symbol': 'CUAN', 'price': '810', 'change': '5(-0.61%)', 'isGreen': false},
    {'symbol': 'BUMI', 'price': '190', 'change': '4(-2.06%)', 'isGreen': false},
    {'symbol': 'RANS', 'price': '214', 'change': '6(-2.73%)', 'isGreen': false},
    {'symbol': 'PACK', 'price': '510', 'change': '44(+9.44%)', 'isGreen': true},
    {
      'symbol': 'BBCA',
      'price': '6,475',
      'change': '75(+1.17%)',
      'isGreen': true,
    },
    {
      'symbol': 'KETR',
      'price': '860',
      'change': '85(+10.97%)',
      'isGreen': true,
    },
    {'symbol': 'KOTA', 'price': '161', 'change': '9(-5.29%)', 'isGreen': false},
    {'symbol': 'VKTR', 'price': '965', 'change': '11(+1.15%)', 'isGreen': true},
    {
      'symbol': 'BBRI',
      'price': '4,890',
      'change': '40(-0.81%)',
      'isGreen': false,
    },
    {
      'symbol': 'BMRI',
      'price': '6,500',
      'change': '100(-1.51%)',
      'isGreen': false,
    },
    {
      'symbol': 'TLKM',
      'price': '2,940',
      'change': '20(+0.68%)',
      'isGreen': true,
    },
    {
      'symbol': 'ASII',
      'price': '4,980',
      'change': '60(-1.19%)',
      'isGreen': false,
    },
    {
      'symbol': 'MDKA',
      'price': '2,410',
      'change': '60(+2.55%)',
      'isGreen': true,
    },
    {
      'symbol': 'BRPT',
      'price': '1,830',
      'change': '10(-0.54%)',
      'isGreen': false,
    },
    {
      'symbol': 'AMMN',
      'price': '9,250',
      'change': '150(+1.65%)',
      'isGreen': true,
    },
    {'symbol': 'GOTO', 'price': '54', 'change': '1(+1.89%)', 'isGreen': true},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_onTick)..start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureWidth();
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final deltaSeconds = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (_isHovered || !_scrollController.hasClients) {
      return;
    }

    if (deltaSeconds <= 0 || deltaSeconds > 0.1) return;

    const double pixelsPerSecond = 40.0;
    final double moveDelta = pixelsPerSecond * deltaSeconds;
    final double newOffset = _scrollController.offset + moveDelta;

    if (newOffset >= _singleSetWidth && _singleSetWidth > 50) {
      _scrollController.jumpTo(newOffset - _singleSetWidth);
    } else {
      _scrollController.jumpTo(newOffset);
    }
  }

  void _measureWidth() {
    if (!mounted) return;
    final renderBox =
        _singleSetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.size.width > 50) {
      if ((renderBox.size.width - _singleSetWidth).abs() > 2) {
        setState(() {
          _singleSetWidth = renderBox.size.width;
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSingleItemSet({Key? key}) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: _tickers.map((item) {
        final sym = item['symbol'] as String;
        final isGreen = item['isGreen'] as bool;
        final color = isGreen ? AppColors.bidGreen : AppColors.offerRed;

        return InkWell(
          onTap: () {
            context.read<WatchlistBloc>().add(SelectActiveStockEvent(sym));
            try {
              context.read<WorkspaceBloc>().add(GlobalSearchSymbolEvent(sym));
            } catch (_) {}
            context.read<NavigationCubit>().navigateToWatchlist(symbol: sym);
          },
          borderRadius: BorderRadius.circular(3),
          hoverColor: AppColors.tableRowHover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sym,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item['price']!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  item['change']!,
                  style: TextStyle(fontSize: 8.5, color: color),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSingleItemSet(key: _singleSetKey),
            _buildSingleItemSet(),
            _buildSingleItemSet(),
            _buildSingleItemSet(),
          ],
        ),
      ),
    );
  }
}

/// Isolated Clock Widget ensuring that per-second setState() calls only rebuild
/// the 20px clock subtree, leaving the rest of the workspace untouched.
class _RealtimeClockWidget extends StatefulWidget {
  const _RealtimeClockWidget();

  @override
  State<_RealtimeClockWidget> createState() => _RealtimeClockWidgetState();
}

class _RealtimeClockWidgetState extends State<_RealtimeClockWidget> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = _formatTime(DateTime.now());
        });
      }
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm:ss a').format(time);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: const TextStyle(
        fontSize: 9.5,
        color: AppColors.textSecondary,
        fontFamily: 'monospace',
      ),
    );
  }
}
