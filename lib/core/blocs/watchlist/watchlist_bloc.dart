import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_event.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_state.dart';
import 'package:stockbit_clone2/core/domain/watchlist/get_watchlist_items_usecase.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_item.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistItemsUseCase getWatchlistItemsUseCase;

  static const List<WatchlistGroup> defaultGroups = [
    WatchlistGroup(
      id: 'g1',
      title: 'Top Movers',
      symbols: ['PACK', 'KETR', 'INET', 'KIJA', 'CUAN', 'BUMI', 'RANS'],
    ),
    WatchlistGroup(
      id: 'g2',
      title: 'Banking Heavyweights',
      symbols: ['BBCA', 'BBRI', 'BMRI', 'BBNI'],
    ),
    WatchlistGroup(
      id: 'g3',
      title: 'Tech & Telco',
      symbols: ['GOTO', 'TLKM', 'INET', 'VKTR'],
    ),
    WatchlistGroup(
      id: 'g4',
      title: 'Mining & Energy',
      symbols: ['AMMN', 'MDKA', 'BRPT', 'CUAN', 'BUMI'],
    ),
    WatchlistGroup(
      id: 'g5',
      title: 'Blue Chips LQ45',
      symbols: ['BBCA', 'BBRI', 'BMRI', 'TLKM', 'ASII', 'BBNI', 'AMMN'],
    ),
  ];

  static const Map<String, Map<String, dynamic>> stockDirectory = {
    'PACK': {
      'name': 'Abadi Nusantara Hijau Investama Tbk',
      'price': 510.0,
      'change': 44.0,
      'changePct': 9.44,
      'badge': '5x',
      'sparkline': [460.0, 470.0, 480.0, 495.0, 510.0],
    },
    'KETR': {
      'name': 'Puri Global Sukses Tbk',
      'price': 860.0,
      'change': 85.0,
      'changePct': 10.97,
      'badge': '3x',
      'sparkline': [770.0, 790.0, 810.0, 840.0, 860.0],
    },
    'INET': {
      'name': 'Sinergi Inti Andalan Prima Tbk',
      'price': 338.0,
      'change': -12.0,
      'changePct': -3.43,
      'badge': '2x',
      'sparkline': [355.0, 350.0, 345.0, 340.0, 338.0],
    },
    'KIJA': {
      'name': 'Kawasan Industri Jababeka Tbk',
      'price': 208.0,
      'change': -10.0,
      'changePct': -4.59,
      'badge': '2x',
      'sparkline': [220.0, 218.0, 214.0, 210.0, 208.0],
    },
    'CUAN': {
      'name': 'Petrindo Jaya Kreasi Tbk',
      'price': 810.0,
      'change': -5.0,
      'changePct': -0.61,
      'badge': '1x',
      'sparkline': [820.0, 815.0, 815.0, 810.0, 810.0],
    },
    'BUMI': {
      'name': 'Bumi Resources Tbk',
      'price': 190.0,
      'change': -4.0,
      'changePct': -2.06,
      'badge': '5x',
      'sparkline': [196.0, 194.0, 192.0, 191.0, 190.0],
    },
    'RANS': {
      'name': 'Rans Nusantara Visual Tbk',
      'price': 214.0,
      'change': -6.0,
      'changePct': -2.73,
      'badge': '2x',
      'sparkline': [222.0, 220.0, 218.0, 215.0, 214.0],
    },
    'BBCA': {
      'name': 'Bank Central Asia Tbk',
      'price': 6475.0,
      'change': 75.0,
      'changePct': 1.17,
      'badge': '5x',
      'sparkline': [6375.0, 6400.0, 6425.0, 6450.0, 6475.0],
    },
    'BBRI': {
      'name': 'Bank Rakyat Indonesia Tbk',
      'price': 4890.0,
      'change': -40.0,
      'changePct': -0.81,
      'badge': '4x',
      'sparkline': [4950.0, 4920.0, 4900.0, 4880.0, 4890.0],
    },
    'BMRI': {
      'name': 'Bank Mandiri (Persero) Tbk',
      'price': 6500.0,
      'change': -100.0,
      'changePct': -1.51,
      'badge': '3x',
      'sparkline': [6625.0, 6575.0, 6550.0, 6525.0, 6500.0],
    },
    'TLKM': {
      'name': 'Telkom Indonesia (Persero) Tbk',
      'price': 2940.0,
      'change': 20.0,
      'changePct': 0.68,
      'badge': '5x',
      'sparkline': [2900.0, 2910.0, 2920.0, 2930.0, 2940.0],
    },
    'ASII': {
      'name': 'Astra International Tbk',
      'price': 4980.0,
      'change': -60.0,
      'changePct': -1.19,
      'badge': '4x',
      'sparkline': [5050.0, 5020.0, 5000.0, 4990.0, 4980.0],
    },
    'BBNI': {
      'name': 'Bank Negara Indonesia (Persero) Tbk',
      'price': 5350.0,
      'change': 50.0,
      'changePct': 0.94,
      'badge': '3x',
      'sparkline': [5275.0, 5300.0, 5325.0, 5325.0, 5350.0],
    },
    'MDKA': {
      'name': 'Merdeka Copper Gold Tbk',
      'price': 2410.0,
      'change': 60.0,
      'changePct': 2.55,
      'badge': '2x',
      'sparkline': [2340.0, 2360.0, 2380.0, 2400.0, 2410.0],
    },
    'BRPT': {
      'name': 'Barito Pacific Tbk',
      'price': 1830.0,
      'change': -10.0,
      'changePct': -0.54,
      'badge': '2x',
      'sparkline': [1850.0, 1840.0, 1835.0, 1830.0, 1830.0],
    },
    'AMMN': {
      'name': 'Amman Mineral Internasional Tbk',
      'price': 9250.0,
      'change': 150.0,
      'changePct': 1.65,
      'badge': '5x',
      'sparkline': [9050.0, 9100.0, 9150.0, 9200.0, 9250.0],
    },
    'GOTO': {
      'name': 'GoTo Gojek Tokopedia Tbk',
      'price': 54.0,
      'change': 1.0,
      'changePct': 1.89,
      'badge': '1x',
      'sparkline': [52.0, 53.0, 53.0, 54.0, 54.0],
    },
    'KOTA': {
      'name': 'DMS Propertindo Tbk',
      'price': 161.0,
      'change': -9.0,
      'changePct': -5.29,
      'badge': '1x',
      'sparkline': [172.0, 168.0, 165.0, 163.0, 161.0],
    },
    'VKTR': {
      'name': 'VKTR Teknologi Mobilitas Tbk',
      'price': 965.0,
      'change': 11.0,
      'changePct': 1.15,
      'badge': '2x',
      'sparkline': [945.0, 950.0, 955.0, 960.0, 965.0],
    },
    'IHSG': {
      'name': 'Indeks Harga Saham Gabungan',
      'price': 6523.69,
      'change': 1.94,
      'changePct': 0.03,
      'badge': 'Indeks',
      'sparkline': [6515.0, 6518.0, 6520.0, 6522.0, 6523.69],
    },
  };

  WatchlistBloc({required this.getWatchlistItemsUseCase})
    : super(const WatchlistInitialState()) {
    on<LoadWatchlistEvent>(_onLoadWatchlist);
    on<SelectWatchlistGroupEvent>(_onSelectWatchlistGroup);
    on<SelectActiveStockEvent>(_onSelectActiveStock);
    on<ToggleWatchlistStockEvent>(_onToggleWatchlistStock);
    on<AddStockToWatchlistEvent>(_onAddStockToWatchlist);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoadingState());
    final result = await getWatchlistItemsUseCase(const NoParams());
    result.when(
      success: (data) {
        final groups = data.groups.isNotEmpty ? data.groups : defaultGroups;
        final initialGroup = groups.first;
        final initialSymbol = initialGroup.symbols.isNotEmpty
            ? initialGroup.symbols.first
            : 'PACK';

        emit(
          WatchlistLoadedState(
            groups: groups,
            activeGroupId: initialGroup.id,
            activeSymbol: initialSymbol,
          ),
        );
      },
      failure: (_) {
        emit(
          const WatchlistLoadedState(
            groups: defaultGroups,
            activeGroupId: 'g1',
            activeSymbol: 'PACK',
          ),
        );
      },
    );
  }

  void _onSelectWatchlistGroup(
    SelectWatchlistGroupEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      final targetGroup = current.groups.firstWhere(
        (g) => g.id == event.groupId,
        orElse: () => current.groups.first,
      );

      // Select first stock of the newly selected group
      final nextSymbol = targetGroup.symbols.isNotEmpty
          ? targetGroup.symbols.first
          : current.activeSymbol;

      emit(current.copyWith(
        activeGroupId: targetGroup.id,
        activeSymbol: nextSymbol,
      ));
    }
  }

  void _onSelectActiveStock(
    SelectActiveStockEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      final sym = event.symbol.toUpperCase();

      // Only switch active symbol, DO NOT alter the group's saved symbols list
      emit(current.copyWith(activeSymbol: sym));
    }
  }

  void _onToggleWatchlistStock(
    ToggleWatchlistStockEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      final sym = event.symbol.toUpperCase();

      final currentGroup = current.activeGroup;
      final isExisting = currentGroup.symbols.any((s) => s.toUpperCase() == sym);

      List<String> updatedSymbols;
      if (isExisting) {
        // Remove from current group (keep at least 1 symbol)
        if (currentGroup.symbols.length > 1) {
          updatedSymbols = currentGroup.symbols.where((s) => s.toUpperCase() != sym).toList();
        } else {
          updatedSymbols = currentGroup.symbols;
        }
      } else {
        // Add to current group at the top
        updatedSymbols = [sym, ...currentGroup.symbols];
      }

      final updatedGroups = current.groups.map((g) {
        if (g.id == currentGroup.id) {
          return g.copyWith(symbols: updatedSymbols);
        }
        return g;
      }).toList();

      emit(current.copyWith(groups: updatedGroups, activeSymbol: sym));
    }
  }

  void _onAddStockToWatchlist(
    AddStockToWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      final sym = event.symbol.toUpperCase();

      final currentGroup = current.activeGroup;
      if (!currentGroup.symbols.any((s) => s.toUpperCase() == sym)) {
        final updatedSymbols = [sym, ...currentGroup.symbols];
        final updatedGroups = current.groups.map((g) {
          if (g.id == currentGroup.id) {
            return g.copyWith(symbols: updatedSymbols);
          }
          return g;
        }).toList();

        emit(current.copyWith(groups: updatedGroups, activeSymbol: sym));
      }
    }
  }

  /// Resolves any stock symbol into a complete, typed WatchlistItem entity
  static WatchlistItem resolveStockItem(String symbol) {
    final sym = symbol.toUpperCase();
    final info = stockDirectory[sym] ?? {
      'name': '$sym Tbk',
      'price': 1000.0,
      'change': 10.0,
      'changePct': 1.0,
      'badge': '1x',
      'sparkline': [980.0, 985.0, 990.0, 995.0, 1000.0],
    };

    return WatchlistItem(
      symbol: sym,
      name: info['name'] as String,
      lastPrice: (info['price'] as num).toDouble(),
      change: (info['change'] as num).toDouble(),
      changePercentage: (info['changePct'] as num).toDouble(),
      badge: info['badge'] as String,
      sparklinePrices: (info['sparkline'] as List<num>).map((e) => e.toDouble()).toList(),
    );
  }
}
