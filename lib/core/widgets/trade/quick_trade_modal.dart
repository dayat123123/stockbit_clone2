import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

class QuickTradeModal extends StatefulWidget {
  final String initialSymbol;
  final double initialPrice;
  final bool isBuyInitial;

  const QuickTradeModal({
    super.key,
    this.initialSymbol = 'BBRI',
    this.initialPrice = 3150,
    this.isBuyInitial = true,
  });

  static Future<void> show(
    BuildContext context, {
    String symbol = 'BBRI',
    double price = 3150,
    bool isBuy = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => QuickTradeModal(
        initialSymbol: symbol,
        initialPrice: price,
        isBuyInitial: isBuy,
      ),
    );
  }

  @override
  State<QuickTradeModal> createState() => _QuickTradeModalState();
}

class _QuickTradeModalState extends State<QuickTradeModal> {
  late bool _isBuy;
  late TextEditingController _symbolController;
  late TextEditingController _priceController;
  late TextEditingController _lotController;
  String _orderType = 'Limit';
  final _numberFormat = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    _isBuy = widget.isBuyInitial;
    _symbolController = TextEditingController(text: widget.initialSymbol);
    _priceController = TextEditingController(
      text: widget.initialPrice.toInt().toString(),
    );
    _lotController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _priceController.dispose();
    _lotController.dispose();
    super.dispose();
  }

  double get _currentPrice =>
      double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0.0;
  int get _currentLot =>
      int.tryParse(_lotController.text.replaceAll(',', '')) ?? 0;
  double get _totalEstimatedValue => _currentPrice * (_currentLot * 100);

  void _adjustPrice(int delta) {
    final current = _currentPrice.toInt();
    final next = (current + delta).clamp(50, 1000000);
    setState(() {
      _priceController.text = next.toString();
    });
  }

  void _adjustLot(int delta) {
    final current = _currentLot;
    final next = (current + delta).clamp(1, 100000);
    setState(() {
      _lotController.text = next.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isBuy ? AppColors.bidGreen : AppColors.offerRed;

    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _isBuy ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                  color: themeColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isBuy ? 'Place BUY Order' : 'Place SELL Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Buy / Sell Switcher
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isBuy = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isBuy
                              ? AppColors.bidGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            fontSize: 12,
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
                    child: GestureDetector(
                      onTap: () => setState(() => _isBuy = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isBuy
                              ? AppColors.offerRed
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'SELL',
                          style: TextStyle(
                            fontSize: 12,
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
            const SizedBox(height: 16),

            // Stock Symbol
            const Text(
              'Stock Code',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _symbolController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Order Type (Limit / Market)
            const Text(
              'Order Type',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Row(
              children: ['Limit', 'Market', 'Auto Order'].map((type) {
                final isSelected = _orderType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    selectedColor: AppColors.badgeBlue.withValues(alpha: 0.3),
                    backgroundColor: AppColors.cardSurface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.badgeBlue
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _orderType = type);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Order Price with + / - buttons
            const Text(
              'Price (IDR)',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove, size: 14),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => _adjustPrice(-25),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add, size: 14),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => _adjustPrice(25),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quantity in Lots with Quick Pills (10, 50, 100, MAX)
            const Text(
              'Quantity (Lots = 100 shares)',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove, size: 14),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => _adjustLot(-5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _lotController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add, size: 14),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => _adjustLot(5),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 50, 100, 500].map((lot) {
                return InkWell(
                  onTap: () =>
                      setState(() => _lotController.text = lot.toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '$lot Lot',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),

            // Estimated Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimated Value:',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  'Rp ${_numberFormat.format(_totalEstimatedValue.toInt())}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: _isBuy ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.cardSurface,
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: themeColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${_isBuy ? "BUY" : "SELL"} order for ${_lotController.text} lot of ${_symbolController.text.toUpperCase()} submitted successfully!',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text(
                'CONFIRM ${_isBuy ? "BUY" : "SELL"} ORDER',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
