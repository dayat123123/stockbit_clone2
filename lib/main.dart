import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/di/injection_container.dart' as di;
import 'package:stockbit_clone2/core/theme/app_theme.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_state.dart';
import 'package:stockbit_clone2/features/auth/presentation/screens/auth_screen.dart';
import 'package:stockbit_clone2/features/layout/presentation/screens/detached_popout_window_screen.dart';
import 'package:stockbit_clone2/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/features/navigation/presentation/screens/desktop_main_shell.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initServiceLocator();

  // Multi-Window Routing for Detached / Pop-Out Windows
  if (args.isNotEmpty && args.first == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    runApp(DetachedPopoutWindowApp(windowId: windowId, argument: argument));
    return;
  }

  // Primary App Initialization (Desktop Login Flow Preserved)
  await DesktopWindowHelper.initialize();
  runApp(const StockbitDesktopApp());
}

class StockbitDesktopApp extends StatelessWidget {
  const StockbitDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
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
