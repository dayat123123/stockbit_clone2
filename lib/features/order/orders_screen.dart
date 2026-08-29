import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_state.dart';
import 'package:stockbit_clone2/core/navigation/models/app_nav_tab.dart';

/// Professional Institutional Order & Trade Management Screen.
/// Provides:
/// - Fast Order Entry Form (Buy/Sell, Limit/Market, Lot sizing & quick percentages)
/// - Live Order Book Status Table (Open, Matched, Rejected, History) with Amend & Withdraw actions.
/// - Dynamic navigation parameters via [NavigationCubit].
class OrdersScreen extends StatefulWidget {
  final String? initialSymbol;
  final bool initialIsBuy;
  final int? initialPrice;
  final int? initialLot;

  const OrdersScreen({
    super.key,
    this.initialSymbol,
    this.initialIsBuy = true,
    this.initialPrice,
    this.initialLot,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late bool _isBuy;
  late TextEditingController _symbolController;
  late TextEditingController _priceController;
  late TextEditingController _lotController;

  int _selectedFilterTab = 0; // 0: All, 1: Open, 2: Matched, 3: Trade History
  String _orderType = 'Limit';

  final List<Map<String, dynamic>> _orders = [
    {
      'time': '16:14:50',
      'id': 'ORD-982101',
      'symbol': 'PACK',
      'action': 'BUY',
      'price': 510,
      'orderLot': 50,
      'doneLot': 50,
      'status': 'Matched',
    },
    {
      'time': '15:42:10',
      'id': 'ORD-982045',
      'symbol': 'BBCA',
      'action': 'BUY',
      'price': 9850,
      'orderLot': 20,
      'doneLot': 20,
      'status': 'Matched',
    },
    {
      'time': '15:10:02',
      'id': 'ORD-981992',
      'symbol': 'BBRI',
      'action': 'BUY',
      'price': 4890,
      'orderLot': 30,
      'doneLot': 0,
      'status': 'Open',
    },
    {
      'time': '14:35:18',
      'id': 'ORD-981840',
      'symbol': 'BMRI',
      'action': 'SELL',
      'price': 6550,
      'orderLot': 40,
      'doneLot': 0,
      'status': 'Open',
    },
    {
      'time': '11:20:45',
      'id': 'ORD-980712',
      'symbol': 'TLKM',
      'action': 'BUY',
      'price': 2940,
      'orderLot': 100,
      'doneLot': 100,
      'status': 'Matched',
    },
    {
      'time': '10:05:30',
      'id': 'ORD-980119',
      'symbol': 'ASII',
      'action': 'BUY',
      'price': 4900,
      'orderLot': 15,
      'doneLot': 0,
      'status': 'Rejected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _isBuy = widget.initialIsBuy;
    _symbolController = TextEditingController(
      text: widget.initialSymbol ?? 'BBCA',
    );
    _priceController = TextEditingController(
      text:
          (widget.initialPrice ??
                  _getDefaultPriceFor(widget.initialSymbol ?? 'BBCA'))
              .toString(),
    );
    _lotController = TextEditingController(
      text: (widget.initialLot ?? 10).toString(),
    );
  }

  int _getDefaultPriceFor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BBCA':
        return 9850;
      case 'BBRI':
        return 4890;
      case 'BMRI':
        return 6550;
      case 'BBNI':
        return 5350;
      case 'TLKM':
        return 2940;
      case 'ASII':
        return 4900;
      case 'GOTO':
        return 54;
      case 'PACK':
        return 510;
      case 'INET':
        return 350;
      case 'KIJA':
        return 145;
      default:
        return 1000;
    }
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSymbol != null &&
        widget.initialSymbol != oldWidget.initialSymbol) {
      _symbolController.text = widget.initialSymbol!;
      _priceController.text =
          (widget.initialPrice ?? _getDefaultPriceFor(widget.initialSymbol!))
              .toString();
    }
    if (widget.initialLot != null &&
        widget.initialLot != oldWidget.initialLot) {
      _lotController.text = widget.initialLot.toString();
    }
    if (widget.initialIsBuy != oldWidget.initialIsBuy) {
      setState(() {
        _isBuy = widget.initialIsBuy;
      });
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _priceController.dispose();
    _lotController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    final sym = _symbolController.text.trim().toUpperCase();
    final p = int.tryParse(_priceController.text) ?? 500;
    final l = int.tryParse(_lotController.text) ?? 1;

    if (sym.isEmpty || p <= 0 || l <= 0) return;

    final now = DateFormat('HH:mm:ss').format(DateTime.now());
    final newId = 'ORD-${100000 + _orders.length + 1}';

    setState(() {
      _orders.insert(0, {
        'time': now,
        'id': newId,
        'symbol': sym,
        'action': _isBuy ? 'BUY' : 'SELL',
        'price': p,
        'orderLot': l,
        'doneLot': 0,
        'status': 'Open',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isBuy ? AppColors.bidGreen : AppColors.offerRed,
        content: Text(
          '${_isBuy ? 'Buy' : 'Sell'} order placed: $l Lot $sym @ Rp ${NumberFormat('#,###').format(p)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final p = int.tryParse(_priceController.text) ?? 0;
    final l = int.tryParse(_lotController.text) ?? 0;
    final totalVal = p * l * 100;
    final fee = (totalVal * 0.0015).round(); // 0.15% broker fee
    final grandTotal = _isBuy ? (totalVal + fee) : (totalVal - fee);

    final openCount = _orders.where((o) => o['status'] == 'Open').length;
    final matchedCount = _orders.where((o) => o['status'] == 'Matched').length;

    return BlocListener<NavigationCubit, NavigationState>(
      listener: (context, state) {
        if (state.tab == AppNavTab.order) {
          final symArg = state.getArg<String>('symbol');
          final isBuyArg = state.getArg<bool>('isBuy');
          final priceArg = state.getArg<int>('price');
          final lotArg = state.getArg<int>('lot');

          if (symArg != null) {
            _symbolController.text = symArg;
            if (priceArg == null) {
              _priceController.text = _getDefaultPriceFor(symArg).toString();
            }
          }
          if (isBuyArg != null) {
            _isBuy = isBuyArg;
          }
          if (priceArg != null) {
            _priceController.text = priceArg.toString();
          }
          if (lotArg != null) {
            _lotController.text = lotArg.toString();
          }
          setState(() {});
        }
      },
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            // ── 1. Top Summary Banner ──────────────────────────────────────────
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.cardHeader,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Order & Trade Management',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildSummaryPill(
                    'Open Orders',
                    '$openCount',
                    AppColors.araYellow,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    'Matched',
                    '$matchedCount',
                    AppColors.bidGreen,
                  ),
                  const SizedBox(width: 14),
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        const Text(
                          'Buying Power: ',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          'Rp 45,200,000',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Main Body Split: Order Form (Left) & Order List (Right) ─────
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left: Fast Place Order Form (~330px) ────────────────────
                  Container(
                    width: 330,
                    color: AppColors.cardBg,
                    padding: const EdgeInsets.all(14),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Buy / Sell Segmented Switch
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _isBuy = true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isBuy
                                            ? AppColors.bidGreen
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'BUY',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _isBuy
                                              ? Colors.black
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _isBuy = false),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !_isBuy
                                            ? AppColors.offerRed
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'SELL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: !_isBuy
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Stock Symbol Input
                          const Text(
                            'STOCK CODE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _symbolController,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.cardSurface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Order Type
                          const Text(
                            'ORDER TYPE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _orderType,
                                dropdownColor: AppColors.cardSurface,
                                isExpanded: true,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                                items: ['Limit', 'Market', 'Stop Loss', 'GTC']
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _orderType = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price Input
                          const Text(
                            'PRICE (IDR)',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  final cur =
                                      int.tryParse(_priceController.text) ??
                                      500;
                                  if (cur > 1) {
                                    setState(
                                      () =>
                                          _priceController.text = '${cur - 5}',
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.cardSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: _priceController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.cardSurface,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  final cur =
                                      int.tryParse(_priceController.text) ??
                                      500;
                                  setState(
                                    () => _priceController.text = '${cur + 5}',
                                  );
                                },
                                icon: const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.cardSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Quantity (Lot)
                          const Text(
                            'QUANTITY (LOT)',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _lotController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.cardSurface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Quick Percentage Buttons
                          Row(
                            children: [25, 50, 75, 100].map((pct) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      final lotVal = (100 * (pct / 100.0))
                                          .round();
                                      setState(
                                        () => _lotController.text = '$lotVal',
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardSurface,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$pct%',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Cost Estimation Breakdown
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                _buildCostRow(
                                  'Shares',
                                  '${fmt.format(l * 100)} Lembar',
                                ),
                                const SizedBox(height: 4),
                                _buildCostRow(
                                  'Order Value',
                                  'Rp ${fmt.format(totalVal)}',
                                ),
                                const SizedBox(height: 4),
                                _buildCostRow(
                                  'Estimated Fee',
                                  'Rp ${fmt.format(fee)}',
                                ),
                                const Divider(
                                  color: AppColors.border,
                                  height: 12,
                                ),
                                _buildCostRow(
                                  'Grand Total',
                                  'Rp ${fmt.format(grandTotal)}',
                                  isBold: true,
                                  valueColor: _isBuy
                                      ? AppColors.bidGreen
                                      : AppColors.offerRed,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Submit Order Button
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isBuy
                                    ? AppColors.bidGreen
                                    : AppColors.offerRed,
                                foregroundColor: _isBuy
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _submitOrder,
                              child: Text(
                                _isBuy
                                    ? 'SUBMIT BUY ORDER'
                                    : 'SUBMIT SELL ORDER',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const VerticalDivider(color: AppColors.border, width: 1),

                  // ── Right: Live Orders Table (~Flex 1) ──────────────────────
                  Expanded(
                    child: Column(
                      children: [
                        // Sub-tabs bar (All Orders, Open, Matched, History)
                        Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: const BoxDecoration(
                            color: AppColors.cardHeader,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildFilterTab(
                                0,
                                'All Orders (${_orders.length})',
                              ),
                              const SizedBox(width: 14),
                              _buildFilterTab(1, 'Open ($openCount)'),
                              const SizedBox(width: 14),
                              _buildFilterTab(2, 'Matched ($matchedCount)'),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(() {}),
                              ),
                            ],
                          ),
                        ),

                        // Column Headers
                        Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          color: AppColors.cardSurface,
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'TIME',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'ORDER ID',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'SYMBOL',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'ACTION',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'PRICE',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'ORDER LOT',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'DONE LOT',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'STATUS',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'ACTIONS',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Orders List
                        Expanded(child: _buildOrdersList(fmt)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String label, String value, Color valColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    String val, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 10.5 : 9.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 11 : 9.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(int index, String title) {
    final isSelected = _selectedFilterTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(NumberFormat fmt) {
    List<Map<String, dynamic>> filtered = _orders;
    if (_selectedFilterTab == 1) {
      filtered = _orders.where((o) => o['status'] == 'Open').toList();
    } else if (_selectedFilterTab == 2) {
      filtered = _orders.where((o) => o['status'] == 'Matched').toList();
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No orders in this view',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final o = filtered[idx];
        final isBuyAction = o['action'] == 'BUY';
        final status = o['status'] as String;

        Color statusColor = AppColors.textSecondary;
        if (status == 'Matched') statusColor = AppColors.bidGreen;
        if (status == 'Open') statusColor = AppColors.araYellow;
        if (status == 'Rejected') statusColor = AppColors.offerRed;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  o['time'],
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  o['id'],
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  o['symbol'],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isBuyAction
                                    ? AppColors.bidGreen
                                    : AppColors.offerRed)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                      child: Text(
                        o['action'],
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: isBuyAction
                              ? AppColors.bidGreen
                              : AppColors.offerRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  fmt.format(o['price']),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${o['orderLot']}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${o['doneLot']}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: status == 'Open'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _symbolController.text = o['symbol'];
                                  _priceController.text = '${o['price']}';
                                  _lotController.text = '${o['orderLot']}';
                                  _isBuy = isBuyAction;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Text(
                                  'Amend',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _orders.removeWhere(
                                    (item) => item['id'] == o['id'],
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.offerRed.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: AppColors.offerRed.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: AppColors.offerRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          '-',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
