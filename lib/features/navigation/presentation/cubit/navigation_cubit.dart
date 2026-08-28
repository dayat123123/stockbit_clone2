import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/features/navigation/domain/entities/app_nav_tab.dart';

class NavigationCubit extends Cubit<AppNavTab> {
  NavigationCubit() : super(AppNavTab.layout);

  void selectTab(AppNavTab tab) => emit(tab);
}
