import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/di/injection_container.dart' as di;
import 'package:stockbit_clone2/core/theme/app_theme.dart';
import 'package:stockbit_clone2/features/navigation/presentation/screens/desktop_main_shell.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Clean Architecture Dependency Injection (GetIt)
  await di.initServiceLocator();

  runApp(const StockbitDesktopApp());
}

class StockbitDesktopApp extends StatelessWidget {
  const StockbitDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderbookBloc>(
          create: (context) => di.sl<OrderbookBloc>()
            ..add(const LoadMultiOrderbooksEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Stockbit Desktop Pro - Multi-Orderbook Workspace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const DesktopMainShell(),
      ),
    );
  }
}
