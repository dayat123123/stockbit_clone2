import 'package:stockbit_clone2/features/orderbook/data/models/orderbook_data_model.dart';
import 'package:stockbit_clone2/features/orderbook/data/models/orderbook_entry_model.dart';
import 'package:stockbit_clone2/features/orderbook/data/models/stock_summary_model.dart';

abstract class OrderbookLocalDataSource {
  Future<List<OrderbookDataModel>> getCachedOrderbooks();
  Future<void> cacheOrderbooks(List<OrderbookDataModel> orderbooks);
  Future<OrderbookDataModel> getStockBySymbol(String symbol);
  Future<List<String>> getAvailableSymbols();
}

class OrderbookLocalDataSourceImpl implements OrderbookLocalDataSource {
  List<OrderbookDataModel>? _cachedList;

  @override
  Future<List<OrderbookDataModel>> getCachedOrderbooks() async {
    if (_cachedList != null) {
      return _cachedList!;
    }
    _cachedList = _generateInitialStockbitData();
    return _cachedList!;
  }

  @override
  Future<void> cacheOrderbooks(List<OrderbookDataModel> orderbooks) async {
    _cachedList = orderbooks;
  }

  @override
  Future<List<String>> getAvailableSymbols() async {
    return _allStocksDatabase.keys.toList();
  }

  @override
  Future<OrderbookDataModel> getStockBySymbol(String symbol) async {
    final sym = symbol.toUpperCase();
    if (_allStocksDatabase.containsKey(sym)) {
      return _allStocksDatabase[sym]!;
    }
    // Generate fallback model for unknown symbol
    return _createSyntheticOrderbook(sym, 1000, 15, '3x');
  }

  List<OrderbookDataModel> _generateInitialStockbitData() {
    return [
      _allStocksDatabase['ASII']!,
      _allStocksDatabase['BMRI']!,
      _allStocksDatabase['BBNI']!,
      _allStocksDatabase['UNTR']!,
      _allStocksDatabase['GGRM']!,
      _allStocksDatabase['HMSP']!,
      _allStocksDatabase['BBRI']!,
      _allStocksDatabase['UNVR']!,
    ];
  }

  static final Map<String, OrderbookDataModel> _allStocksDatabase = {
    'ASII': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'ASII',
        companyName: 'Astra International Tbk.',
        price: 4790,
        change: 0,
        changePercent: 0.0,
        open: 4790,
        high: 4790,
        low: 4790,
        prev: 4790,
        ara: 5975,
        arb: 4080,
        lot: 184520,
        value: 88.4,
        avg: 4805,
        leverage: '3x',
        logoIcon: 'ASII',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 142, bidLot: 12450, bidPrice: 4780, offerPrice: 4790, offerLot: 8520, offerFreq: 98),
        OrderbookEntryModel(bidFreq: 98, bidLot: 8900, bidPrice: 4770, offerPrice: 4800, offerLot: 15400, offerFreq: 165),
        OrderbookEntryModel(bidFreq: 215, bidLot: 24500, bidPrice: 4760, offerPrice: 4810, offerLot: 11200, offerFreq: 110),
        OrderbookEntryModel(bidFreq: 76, bidLot: 6200, bidPrice: 4750, offerPrice: 4820, offerLot: 9400, offerFreq: 84),
        OrderbookEntryModel(bidFreq: 189, bidLot: 18300, bidPrice: 4740, offerPrice: 4830, offerLot: 22100, offerFreq: 201),
        OrderbookEntryModel(bidFreq: 112, bidLot: 14100, bidPrice: 4730, offerPrice: 4840, offerLot: 13500, offerFreq: 128),
        OrderbookEntryModel(bidFreq: 84, bidLot: 9600, bidPrice: 4720, offerPrice: 4850, offerLot: 31000, offerFreq: 310),
        OrderbookEntryModel(bidFreq: 65, bidLot: 5400, bidPrice: 4710, offerPrice: 4860, offerLot: 7800, offerFreq: 67),
        OrderbookEntryModel(bidFreq: 143, bidLot: 19800, bidPrice: 4700, offerPrice: 4870, offerLot: 18900, offerFreq: 176),
        OrderbookEntryModel(bidFreq: 52, bidLot: 4200, bidPrice: 4690, offerPrice: 4880, offerLot: 6300, offerFreq: 55),
      ],
      totalBidLot: 123450,
      totalOfferLot: 144120,
    ),
    'BMRI': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'BMRI',
        companyName: 'Bank Mandiri (Persero) Tbk.',
        price: 4210,
        change: 0,
        changePercent: 0.0,
        open: 4210,
        high: 4210,
        low: 4210,
        prev: 4210,
        ara: 5250,
        arb: 3580,
        lot: 310240,
        value: 130.8,
        avg: 4225,
        leverage: '5x',
        logoIcon: 'BMRI',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 231, bidLot: 31200, bidPrice: 4200, offerPrice: 4210, offerLot: 18400, offerFreq: 180),
        OrderbookEntryModel(bidFreq: 184, bidLot: 22100, bidPrice: 4190, offerPrice: 4220, offerLot: 27900, offerFreq: 240),
        OrderbookEntryModel(bidFreq: 310, bidLot: 45000, bidPrice: 4180, offerPrice: 4230, offerLot: 19300, offerFreq: 195),
        OrderbookEntryModel(bidFreq: 95, bidLot: 14200, bidPrice: 4170, offerPrice: 4240, offerLot: 16800, offerFreq: 145),
        OrderbookEntryModel(bidFreq: 140, bidLot: 20400, bidPrice: 4160, offerPrice: 4250, offerLot: 38200, offerFreq: 320),
        OrderbookEntryModel(bidFreq: 88, bidLot: 11500, bidPrice: 4150, offerPrice: 4260, offerLot: 14100, offerFreq: 118),
        OrderbookEntryModel(bidFreq: 64, bidLot: 8900, bidPrice: 4140, offerPrice: 4270, offerLot: 9800, offerFreq: 89),
        OrderbookEntryModel(bidFreq: 120, bidLot: 17300, bidPrice: 4130, offerPrice: 4280, offerLot: 12500, offerFreq: 110),
        OrderbookEntryModel(bidFreq: 50, bidLot: 6100, bidPrice: 4120, offerPrice: 4290, offerLot: 8200, offerFreq: 75),
        OrderbookEntryModel(bidFreq: 175, bidLot: 28000, bidPrice: 4110, offerPrice: 4300, offerLot: 41000, offerFreq: 390),
      ],
      totalBidLot: 204700,
      totalOfferLot: 206200,
    ),
    'BBNI': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'BBNI',
        companyName: 'Bank Negara Indonesia Tbk.',
        price: 3710,
        change: 0,
        changePercent: 0.0,
        open: 3710,
        high: 3710,
        low: 3710,
        prev: 3710,
        ara: 4630,
        arb: 3160,
        lot: 95400,
        value: 35.4,
        avg: 3715,
        leverage: '5x',
        logoIcon: 'BBNI',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 88, bidLot: 9400, bidPrice: 3700, offerPrice: 3710, offerLot: 12100, offerFreq: 105),
        OrderbookEntryModel(bidFreq: 112, bidLot: 14500, bidPrice: 3690, offerPrice: 3720, offerLot: 18200, offerFreq: 160),
        OrderbookEntryModel(bidFreq: 94, bidLot: 11800, bidPrice: 3680, offerPrice: 3730, offerLot: 9400, offerFreq: 88),
        OrderbookEntryModel(bidFreq: 145, bidLot: 21000, bidPrice: 3670, offerPrice: 3740, offerLot: 15300, offerFreq: 140),
        OrderbookEntryModel(bidFreq: 78, bidLot: 8200, bidPrice: 3660, offerPrice: 3750, offerLot: 28900, offerFreq: 260),
        OrderbookEntryModel(bidFreq: 56, bidLot: 6100, bidPrice: 3650, offerPrice: 3760, offerLot: 7500, offerFreq: 65),
        OrderbookEntryModel(bidFreq: 40, bidLot: 4800, bidPrice: 3640, offerPrice: 3770, offerLot: 5400, offerFreq: 48),
        OrderbookEntryModel(bidFreq: 95, bidLot: 12900, bidPrice: 3630, offerPrice: 3780, offerLot: 8900, offerFreq: 79),
        OrderbookEntryModel(bidFreq: 34, bidLot: 3900, bidPrice: 3620, offerPrice: 3790, offerLot: 4200, offerFreq: 38),
        OrderbookEntryModel(bidFreq: 120, bidLot: 17500, bidPrice: 3610, offerPrice: 3800, offerLot: 22000, offerFreq: 195),
      ],
      totalBidLot: 110100,
      totalOfferLot: 131900,
    ),
    'UNTR': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'UNTR',
        companyName: 'United Tractors Tbk.',
        price: 24475,
        change: 0,
        changePercent: 0.0,
        open: 24475,
        high: 24475,
        low: 24475,
        prev: 24475,
        ara: 29350,
        arb: 20825,
        lot: 18900,
        value: 46.2,
        avg: 24510,
        leverage: '4x',
        logoIcon: 'UNTR',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 45, bidLot: 1250, bidPrice: 24450, offerPrice: 24475, offerLot: 890, offerFreq: 38),
        OrderbookEntryModel(bidFreq: 62, bidLot: 2100, bidPrice: 24425, offerPrice: 24500, offerLot: 3400, offerFreq: 110),
        OrderbookEntryModel(bidFreq: 38, bidLot: 950, bidPrice: 24400, offerPrice: 24525, offerLot: 1450, offerFreq: 52),
        OrderbookEntryModel(bidFreq: 54, bidLot: 1800, bidPrice: 24375, offerPrice: 24550, offerLot: 2200, offerFreq: 76),
        OrderbookEntryModel(bidFreq: 89, bidLot: 3100, bidPrice: 24350, offerPrice: 24575, offerLot: 1900, offerFreq: 64),
        OrderbookEntryModel(bidFreq: 29, bidLot: 820, bidPrice: 24325, offerPrice: 24600, offerLot: 4800, offerFreq: 142),
        OrderbookEntryModel(bidFreq: 41, bidLot: 1350, bidPrice: 24300, offerPrice: 24625, offerLot: 1100, offerFreq: 40),
        OrderbookEntryModel(bidFreq: 22, bidLot: 610, bidPrice: 24275, offerPrice: 24650, offerLot: 2950, offerFreq: 95),
        OrderbookEntryModel(bidFreq: 35, bidLot: 1050, bidPrice: 24250, offerPrice: 24675, offerLot: 880, offerFreq: 31),
        OrderbookEntryModel(bidFreq: 70, bidLot: 2400, bidPrice: 24225, offerPrice: 24700, offerLot: 3600, offerFreq: 118),
      ],
      totalBidLot: 15430,
      totalOfferLot: 23170,
    ),
    'GGRM': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'GGRM',
        companyName: 'Gudang Garam Tbk.',
        price: 19650,
        change: 0,
        changePercent: 0.0,
        open: 19650,
        high: 19650,
        low: 19650,
        prev: 19650,
        ara: 23575,
        arb: 16725,
        lot: 8400,
        value: 16.5,
        avg: 19675,
        leverage: '3x',
        logoIcon: 'GGRM',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 24, bidLot: 420, bidPrice: 19625, offerPrice: 19650, offerLot: 680, offerFreq: 31),
        OrderbookEntryModel(bidFreq: 38, bidLot: 890, bidPrice: 19600, offerPrice: 19675, offerLot: 1100, offerFreq: 49),
        OrderbookEntryModel(bidFreq: 52, bidLot: 1450, bidPrice: 19575, offerPrice: 19700, offerLot: 2400, offerFreq: 88),
        OrderbookEntryModel(bidFreq: 19, bidLot: 310, bidPrice: 19550, offerPrice: 19725, offerLot: 850, offerFreq: 37),
        OrderbookEntryModel(bidFreq: 44, bidLot: 980, bidPrice: 19525, offerPrice: 19750, offerLot: 1750, offerFreq: 72),
        OrderbookEntryModel(bidFreq: 15, bidLot: 240, bidPrice: 19500, offerPrice: 19775, offerLot: 620, offerFreq: 28),
        OrderbookEntryModel(bidFreq: 31, bidLot: 670, bidPrice: 19475, offerPrice: 19800, offerLot: 3100, offerFreq: 120),
        OrderbookEntryModel(bidFreq: 12, bidLot: 180, bidPrice: 19450, offerPrice: 19825, offerLot: 430, offerFreq: 20),
        OrderbookEntryModel(bidFreq: 28, bidLot: 590, bidPrice: 19425, offerPrice: 19850, offerLot: 920, offerFreq: 41),
        OrderbookEntryModel(bidFreq: 60, bidLot: 1650, bidPrice: 19400, offerPrice: 19875, offerLot: 1450, offerFreq: 64),
      ],
      totalBidLot: 7380,
      totalOfferLot: 13300,
    ),
    'HMSP': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'HMSP',
        companyName: 'HM Sampoerna Tbk.',
        price: 745,
        change: 0,
        changePercent: 0.0,
        open: 745,
        high: 745,
        low: 745,
        prev: 745,
        ara: 930,
        arb: 635,
        lot: 89400,
        value: 6.7,
        avg: 748,
        leverage: '4x',
        logoIcon: 'HMSP',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 120, bidLot: 18400, bidPrice: 740, offerPrice: 745, offerLot: 12200, offerFreq: 95),
        OrderbookEntryModel(bidFreq: 185, bidLot: 32000, bidPrice: 735, offerPrice: 750, offerLot: 45000, offerFreq: 310),
        OrderbookEntryModel(bidFreq: 94, bidLot: 14500, bidPrice: 730, offerPrice: 755, offerLot: 21000, offerFreq: 160),
        OrderbookEntryModel(bidFreq: 140, bidLot: 24800, bidPrice: 725, offerPrice: 760, offerLot: 34000, offerFreq: 240),
        OrderbookEntryModel(bidFreq: 65, bidLot: 9100, bidPrice: 720, offerPrice: 765, offerLot: 11500, offerFreq: 85),
        OrderbookEntryModel(bidFreq: 48, bidLot: 6700, bidPrice: 715, offerPrice: 770, offerLot: 18900, offerFreq: 130),
        OrderbookEntryModel(bidFreq: 82, bidLot: 12400, bidPrice: 710, offerPrice: 775, offerLot: 8400, offerFreq: 62),
        OrderbookEntryModel(bidFreq: 33, bidLot: 4500, bidPrice: 705, offerPrice: 780, offerLot: 15200, offerFreq: 110),
        OrderbookEntryModel(bidFreq: 110, bidLot: 19800, bidPrice: 700, offerPrice: 785, offerLot: 6100, offerFreq: 45),
        OrderbookEntryModel(bidFreq: 45, bidLot: 7200, bidPrice: 695, offerPrice: 790, offerLot: 9800, offerFreq: 70),
      ],
      totalBidLot: 149400,
      totalOfferLot: 182100,
    ),
    'BBRI': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'BBRI',
        companyName: 'Bank Rakyat Indonesia Tbk.',
        price: 3150,
        change: 0,
        changePercent: 0.0,
        open: 3150,
        high: 3150,
        low: 3150,
        prev: 3150,
        ara: 3930,
        arb: 2680,
        lot: 642000,
        value: 202.5,
        avg: 3155,
        leverage: '5x',
        logoIcon: 'BBRI',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 340, bidLot: 64200, bidPrice: 3140, offerPrice: 3150, offerLot: 41200, offerFreq: 290),
        OrderbookEntryModel(bidFreq: 410, bidLot: 82100, bidPrice: 3130, offerPrice: 3160, offerLot: 78900, offerFreq: 430),
        OrderbookEntryModel(bidFreq: 280, bidLot: 51000, bidPrice: 3120, offerPrice: 3170, offerLot: 49000, offerFreq: 310),
        OrderbookEntryModel(bidFreq: 390, bidLot: 94000, bidPrice: 3110, offerPrice: 3180, offerLot: 89500, offerFreq: 520),
        OrderbookEntryModel(bidFreq: 195, bidLot: 38200, bidPrice: 3100, offerPrice: 3190, offerLot: 32000, offerFreq: 220),
        OrderbookEntryModel(bidFreq: 160, bidLot: 29500, bidPrice: 3090, offerPrice: 3200, offerLot: 110000, offerFreq: 680),
        OrderbookEntryModel(bidFreq: 110, bidLot: 18400, bidPrice: 3080, offerPrice: 3210, offerLot: 21500, offerFreq: 150),
        OrderbookEntryModel(bidFreq: 85, bidLot: 14200, bidPrice: 3070, offerPrice: 3220, offerLot: 17800, offerFreq: 125),
        OrderbookEntryModel(bidFreq: 210, bidLot: 42000, bidPrice: 3060, offerPrice: 3230, offerLot: 25400, offerFreq: 180),
        OrderbookEntryModel(bidFreq: 95, bidLot: 16500, bidPrice: 3050, offerPrice: 3240, offerLot: 19100, offerFreq: 135),
      ],
      totalBidLot: 450100,
      totalOfferLot: 484400,
    ),
    'UNVR': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'UNVR',
        companyName: 'Unilever Indonesia Tbk.',
        price: 1760,
        change: 0,
        changePercent: 0.0,
        open: 1760,
        high: 1760,
        low: 1760,
        prev: 1760,
        ara: 2200,
        arb: 1500,
        lot: 74200,
        value: 13.1,
        avg: 1758,
        leverage: '4x',
        logoIcon: 'UNVR',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 75, bidLot: 8900, bidPrice: 1755, offerPrice: 1760, offerLot: 11200, offerFreq: 92),
        OrderbookEntryModel(bidFreq: 98, bidLot: 14200, bidPrice: 1750, offerPrice: 1765, offerLot: 16800, offerFreq: 135),
        OrderbookEntryModel(bidFreq: 64, bidLot: 7500, bidPrice: 1745, offerPrice: 1770, offerLot: 22400, offerFreq: 180),
        OrderbookEntryModel(bidFreq: 120, bidLot: 19100, bidPrice: 1740, offerPrice: 1775, offerLot: 14500, offerFreq: 115),
        OrderbookEntryModel(bidFreq: 50, bidLot: 5800, bidPrice: 1735, offerPrice: 1780, offerLot: 28900, offerFreq: 210),
        OrderbookEntryModel(bidFreq: 42, bidLot: 4900, bidPrice: 1730, offerPrice: 1785, offerLot: 7600, offerFreq: 60),
        OrderbookEntryModel(bidFreq: 78, bidLot: 11200, bidPrice: 1725, offerPrice: 1790, offerLot: 9400, offerFreq: 75),
        OrderbookEntryModel(bidFreq: 31, bidLot: 3400, bidPrice: 1720, offerPrice: 1795, offerLot: 5100, offerFreq: 42),
        OrderbookEntryModel(bidFreq: 89, bidLot: 15600, bidPrice: 1715, offerPrice: 1800, offerLot: 34000, offerFreq: 260),
        OrderbookEntryModel(bidFreq: 36, bidLot: 4100, bidPrice: 1710, offerPrice: 1805, offerLot: 4800, offerFreq: 38),
      ],
      totalBidLot: 94700,
      totalOfferLot: 154700,
    ),
    'BBCA': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'BBCA',
        companyName: 'Bank Central Asia Tbk.',
        price: 10250,
        change: 125,
        changePercent: 1.23,
        open: 10150,
        high: 10300,
        low: 10125,
        prev: 10125,
        ara: 12650,
        arb: 8625,
        lot: 524000,
        value: 537.1,
        avg: 10225,
        leverage: '5x',
        logoIcon: 'BBCA',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 420, bidLot: 45200, bidPrice: 10225, offerPrice: 10250, offerLot: 38900, offerFreq: 310),
        OrderbookEntryModel(bidFreq: 380, bidLot: 61000, bidPrice: 10200, offerPrice: 10275, offerLot: 42100, offerFreq: 290),
        OrderbookEntryModel(bidFreq: 290, bidLot: 34500, bidPrice: 10175, offerPrice: 10300, offerLot: 89000, offerFreq: 540),
        OrderbookEntryModel(bidFreq: 180, bidLot: 28400, bidPrice: 10150, offerPrice: 10325, offerLot: 21000, offerFreq: 180),
        OrderbookEntryModel(bidFreq: 210, bidLot: 39000, bidPrice: 10125, offerPrice: 10350, offerLot: 31500, offerFreq: 240),
      ],
      totalBidLot: 320000,
      totalOfferLot: 290000,
    ),
    'TLKM': OrderbookDataModel(
      summary: const StockSummaryModel(
        symbol: 'TLKM',
        companyName: 'Telkom Indonesia Tbk.',
        price: 2980,
        change: -40,
        changePercent: -1.32,
        open: 3020,
        high: 3040,
        low: 2970,
        prev: 3020,
        ara: 3770,
        arb: 2570,
        lot: 412000,
        value: 123.4,
        avg: 2995,
        leverage: '4x',
        logoIcon: 'TLKM',
      ),
      entries: const [
        OrderbookEntryModel(bidFreq: 180, bidLot: 24500, bidPrice: 2970, offerPrice: 2980, offerLot: 31200, offerFreq: 210),
        OrderbookEntryModel(bidFreq: 210, bidLot: 38900, bidPrice: 2960, offerPrice: 2990, offerLot: 45000, offerFreq: 310),
        OrderbookEntryModel(bidFreq: 140, bidLot: 18200, bidPrice: 2950, offerPrice: 3000, offerLot: 82000, offerFreq: 520),
      ],
      totalBidLot: 198000,
      totalOfferLot: 240000,
    ),
  };

  static OrderbookDataModel _createSyntheticOrderbook(String sym, double basePrice, double tick, String leverage) {
    return OrderbookDataModel(
      summary: StockSummaryModel(
        symbol: sym,
        companyName: '$sym Corporation Tbk.',
        price: basePrice,
        change: 0,
        changePercent: 0.0,
        open: basePrice,
        high: basePrice + tick * 2,
        low: basePrice - tick * 2,
        prev: basePrice,
        ara: basePrice * 1.25,
        arb: basePrice * 0.85,
        lot: 50000,
        value: 25.0,
        avg: basePrice,
        leverage: leverage,
        logoIcon: sym,
      ),
      entries: [
        OrderbookEntryModel(bidFreq: 50, bidLot: 5000, bidPrice: basePrice - tick, offerPrice: basePrice, offerLot: 4500, offerFreq: 40),
        OrderbookEntryModel(bidFreq: 70, bidLot: 8000, bidPrice: basePrice - (tick * 2), offerPrice: basePrice + tick, offerLot: 7800, offerFreq: 60),
        OrderbookEntryModel(bidFreq: 90, bidLot: 12000, bidPrice: basePrice - (tick * 3), offerPrice: basePrice + (tick * 2), offerLot: 11000, offerFreq: 80),
      ],
      totalBidLot: 45000,
      totalOfferLot: 52000,
    );
  }
}
