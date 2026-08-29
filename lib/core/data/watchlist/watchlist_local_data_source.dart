import 'package:stockbit_clone2/core/data/watchlist/watchlist_item_model.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistItemModel>> getWatchlistItems();
  Future<List<WatchlistGroup>> getWatchlistGroups();
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  @override
  Future<List<WatchlistItemModel>> getWatchlistItems() async {
    return const [
      WatchlistItemModel(
        symbol: 'PACK',
        name: 'Solusi Kemasan Digital Tbk.',
        lastPrice: 510,
        change: 44,
        changePercentage: 9.44,
        badge: '5x',
        sparklinePrices: [460, 470, 465, 480, 495, 490, 505, 510],
      ),
      WatchlistItemModel(
        symbol: 'KETR',
        name: 'Puri Global Sukses Tbk.',
        lastPrice: 860,
        change: 85,
        changePercentage: 10.97,
        badge: '3x',
        sparklinePrices: [775, 780, 800, 790, 820, 840, 850, 860],
      ),
      WatchlistItemModel(
        symbol: 'INET',
        name: 'Sinergi Inti Andalan Prima Tbk.',
        lastPrice: 338,
        change: -12,
        changePercentage: -3.43,
        badge: '2x',
        sparklinePrices: [350, 348, 346, 342, 340, 335, 336, 338],
      ),
      WatchlistItemModel(
        symbol: 'KIJA',
        name: 'Kawasan Industri Jababeka Tbk.',
        lastPrice: 208,
        change: -10,
        changePercentage: -4.59,
        badge: '2x',
        sparklinePrices: [218, 216, 214, 212, 210, 206, 207, 208],
      ),
      WatchlistItemModel(
        symbol: 'CUAN',
        name: 'Petrindo Jaya Kreasi Tbk.',
        lastPrice: 810,
        change: -5,
        changePercentage: -0.61,
        badge: '1x',
        sparklinePrices: [815, 812, 810, 805, 808, 805, 810, 810],
      ),
      WatchlistItemModel(
        symbol: 'BUMI',
        name: 'Bumi Resources Tbk.',
        lastPrice: 190,
        change: -4,
        changePercentage: -2.06,
        badge: '5x',
        sparklinePrices: [194, 193, 192, 191, 189, 188, 189, 190],
      ),
      WatchlistItemModel(
        symbol: 'RANS',
        name: 'Rans Nusantara Entertainment Tbk.',
        lastPrice: 214,
        change: -6,
        changePercentage: -2.73,
        badge: '2x',
        sparklinePrices: [220, 218, 216, 215, 214, 212, 213, 214],
      ),
      WatchlistItemModel(
        symbol: 'BBCA',
        name: 'Bank Central Asia Tbk.',
        lastPrice: 6475,
        change: 75,
        changePercentage: 1.17,
        badge: '5x',
        sparklinePrices: [6400, 6425, 6420, 6450, 6460, 6450, 6470, 6475],
      ),
    ];
  }

  @override
  Future<List<WatchlistGroup>> getWatchlistGroups() async {
    return const [
      WatchlistGroup(
        id: 'g1',
        title: 'Top Movers',
        symbols: ['PACK', 'KETR', 'INET', 'KIJA', 'CUAN', 'BUMI'],
      ),
      WatchlistGroup(
        id: 'g2',
        title: 'Banking Heavyweights',
        symbols: ['BBCA', 'BBRI', 'BMRI', 'BBNI'],
      ),
      WatchlistGroup(
        id: 'g3',
        title: 'Tech & Telco',
        symbols: ['GOTO', 'TLKM', 'ISAT', 'EXCL'],
      ),
    ];
  }
}
