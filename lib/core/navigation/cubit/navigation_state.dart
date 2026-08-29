import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/navigation/models/app_nav_tab.dart';

/// Navigation State supporting flexible and dynamic route arguments.
class NavigationState extends Equatable {
  final AppNavTab tab;
  final Map<String, dynamic> arguments;

  const NavigationState({required this.tab, this.arguments = const {}});

  /// Convenient helper getters to easily extract arguments
  T? getArg<T>(String key) => arguments[key] as T?;
  String? get symbol => arguments['symbol'] as String?;
  bool? get isBuy => arguments['isBuy'] as bool?;
  int? get price => arguments['price'] as int?;
  int? get lot => arguments['lot'] as int?;

  NavigationState copyWith({AppNavTab? tab, Map<String, dynamic>? arguments}) {
    return NavigationState(
      tab: tab ?? this.tab,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  List<Object?> get props => [tab, arguments];
}
