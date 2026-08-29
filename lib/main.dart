import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/di/injection_container.dart' as di;
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/services/multi_window_bridge.dart';
import 'package:stockbit_clone2/core/theme/app_theme.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_bloc.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_state.dart';
import 'package:stockbit_clone2/core/blocs/orderbook/orderbook_bloc.dart';
import 'package:stockbit_clone2/core/blocs/orderbook/orderbook_event.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_bloc.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_event.dart';
import 'package:stockbit_clone2/features/auth/auth_screen.dart';
import 'package:stockbit_clone2/features/layout/detached_popout_window_screen.dart';
import 'package:stockbit_clone2/features/navigation/desktop_main_shell.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initServiceLocator();

  // Multi-Window Routing for Detached / Pop-Out Windows
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    await MultiWindowBridge.initialize(windowId: windowId);
    runApp(DetachedPopoutWindowApp(windowId: windowId, argument: argument));
    return;
  }

  // Primary App Initialization (Desktop Login Flow Preserved)
  await MultiWindowBridge.initialize(windowId: 0);
  await DesktopWindowHelper.initialize();
  runApp(const StockbitDesktopApp());
}

class StockbitDesktopApp extends StatelessWidget {
  const StockbitDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<NavigationCubit>(create: (_) => di.sl<NavigationCubit>()),
        BlocProvider<WorkspaceBloc>(
          create: (context) =>
              di.sl<WorkspaceBloc>()..add(const InitializeWorkspaceEvent()),
        ),
        BlocProvider<WatchlistBloc>(
          create: (context) =>
              di.sl<WatchlistBloc>()..add(const LoadWatchlistEvent()),
        ),
        BlocProvider<OrderbookBloc>(
          create: (context) =>
              di.sl<OrderbookBloc>()..add(const LoadMultiOrderbooksEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Stockbit Desktop Pro - Modular Trading Workspace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticatedState) {
              return const DesktopMainShell();
            }
            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
