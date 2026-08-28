import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/di/injection_container.dart' as di;
import 'package:stockbit_clone2/core/theme/app_theme.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/factory/workspace_widget_factory.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';

/// Standalone Flutter App Shell rendered exclusively inside a detached Pop-Out Window.
class DetachedPopoutWindowApp extends StatelessWidget {
  final int windowId;
  final Map<String, dynamic> argument;

  const DetachedPopoutWindowApp({
    super.key,
    required this.windowId,
    required this.argument,
  });

  @override
  Widget build(BuildContext context) {
    final typeName = argument['type'] as String? ?? 'orderbook';
    final symbol = argument['symbol'] as String? ?? 'BBCA';
    final title = argument['title'] as String? ?? '$symbol Trading Window';

    final widgetType = WorkspaceWidgetType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => WorkspaceWidgetType.orderbook,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<WatchlistBloc>(
          create: (_) => di.sl<WatchlistBloc>()..add(const LoadWatchlistEvent()),
        ),
        BlocProvider<OrderbookBloc>(
          create: (_) => di.sl<OrderbookBloc>()..add(const LoadMultiOrderbooksEvent()),
        ),
      ],
      child: MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: DetachedPopoutWindowScreen(
          windowId: windowId,
          widgetType: widgetType,
          symbol: symbol,
        ),
      ),
    );
  }
}

/// Standalone Screen inside a detached pop-out window with its own controls.
class DetachedPopoutWindowScreen extends StatelessWidget {
  final int windowId;
  final WorkspaceWidgetType widgetType;
  final String symbol;

  const DetachedPopoutWindowScreen({
    super.key,
    required this.windowId,
    required this.widgetType,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final controller = WindowController.fromWindowId(windowId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── 1. Frameless Custom Window Title Bar ───────────────────────────
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              children: [
                Icon(widgetType.icon, size: 13, color: widgetType.color),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: widgetType.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    widgetType.label,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: widgetType.color,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),

                // Quick BUY Button
                InkWell(
                  onTap: () => QuickTradeModal.show(context, symbol: symbol, isBuy: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'BUY',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Minimize/Hide Button
                _buildHeaderIcon(
                  icon: Icons.remove,
                  onTap: () => controller.hide(),
                ),

                // Close Button
                _buildHeaderIcon(
                  icon: Icons.close,
                  hoverColor: AppColors.offerRed,
                  onTap: () => controller.close(),
                ),
              ],
            ),
          ),

          // ── 2. Feature Screen Widget Body ─────────────────────────────────
          Expanded(
            child: ClipRect(
              child: WorkspaceWidgetFactory.build(
                type: widgetType,
                symbol: symbol,
                windowId: 'popout_$windowId',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color? hoverColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Icon(icon, size: 13, color: AppColors.textSecondary),
      ),
    );
  }
}
