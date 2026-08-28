import 'package:stockbit_clone2/features/watchlist/data/models/watchlist_item_model.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistGroup>> getWatchlistGroups();
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  @override
  Future<List<WatchlistGroup>> getWatchlistGroups() async {
    final allItems = <WatchlistItemModel>[
      const WatchlistItemModel(
        symbol: 'MDKA',
        name: 'Merdeka Copper Gold',
        badge: '1X',
        lastPrice: 2410,
        change: 70,
        changePercentage: 2.99,
        volume: '42.1M',
        sparklinePrices: [2340, 2350, 2370, 2360, 2390, 2400, 2410],
      ),
      const WatchlistItemModel(
        symbol: 'CBRE',
        name: 'Cakra Buana Resources',
        badge: 'RG',
        lastPrice: 58,
        change: -3,
        changePercentage: -4.92,
        volume: '108.4M',
        sparklinePrices: [62, 61, 60, 59, 60, 58, 58],
      ),
      const WatchlistItemModel(
        symbol: 'ASII',
        name: 'Astra International',
        badge: '1X',
        lastPrice: 4980,
        change: -70,
        changePercentage: -1.39,
        volume: '18.7M',
        sparklinePrices: [5070, 5050, 5020, 5000, 4990, 4980],
      ),
      const WatchlistItemModel(
        symbol: 'BBCA',
        name: 'Bank Central Asia',
        badge: '1X',
        lastPrice: 9850,
        change: 150,
        changePercentage: 1.55,
        volume: '24.2M',
        sparklinePrices: [9700, 9725, 9750, 9800, 9825, 9850],
      ),
      const WatchlistItemModel(
        symbol: 'BBRI',
        name: 'Bank Rakyat Indonesia',
        badge: '1X',
        lastPrice: 4890,
        change: -40,
        changePercentage: -0.81,
        volume: '58.1M',
        sparklinePrices: [4940, 4930, 4910, 4900, 4880, 4890],
      ),
      const WatchlistItemModel(
        symbol: 'BMRI',
        name: 'Bank Mandiri',
        badge: '1X',
        lastPrice: 6500,
        change: 125,
        changePercentage: 1.96,
        volume: '38.9M',
        sparklinePrices: [6375, 6400, 6425, 6450, 6475, 6500],
      ),
      const WatchlistItemModel(
        symbol: 'TLKM',
        name: 'Telkom Indonesia',
        badge: '1X',
        lastPrice: 2940,
        change: 20,
        changePercentage: 0.68,
        volume: '35.3M',
        sparklinePrices: [2920, 2910, 2930, 2920, 2940, 2940],
      ),
      const WatchlistItemModel(
        symbol: 'BBNI',
        name: 'Bank Negara Indonesia',
        badge: '1X',
        lastPrice: 5250,
        change: 50,
        changePercentage: 0.96,
        volume: '19.2M',
        sparklinePrices: [5200, 5200, 5225, 5225, 5250, 5250],
      ),
      const WatchlistItemModel(
        symbol: 'AMMN',
        name: 'Amman Mineral Internasional',
        badge: '1X',
        lastPrice: 9425,
        change: 225,
        changePercentage: 2.45,
        volume: '22.8M',
        sparklinePrices: [9200, 9250, 9300, 9350, 9400, 9425],
      ),
      const WatchlistItemModel(
        symbol: 'BREN',
        name: 'Barito Renewables Energy',
        badge: '1X',
        lastPrice: 8750,
        change: -150,
        changePercentage: -1.69,
        volume: '14.6M',
        sparklinePrices: [8925, 8900, 8850, 8800, 8725, 8750],
      ),
    ];

    final bankingItems = allItems
        .where((e) => e.symbol.startsWith('B'))
        .toList();
    final miningItems = allItems
        .where((e) => ['MDKA', 'CBRE', 'AMMN', 'BREN'].contains(e.symbol))
        .toList();

    return [
      WatchlistGroup(id: 'all', title: 'All Watchlist', items: allItems),
      WatchlistGroup(
        id: 'banking',
        title: 'Banking (Big 4)',
        items: bankingItems,
      ),
      WatchlistGroup(
        id: 'energy_mining',
        title: 'Energy & Mining',
        items: miningItems,
      ),
    ];
  }
}
