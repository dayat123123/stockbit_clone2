import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

class StockSearchDialog extends StatefulWidget {
  final int targetSlotIndex;
  final Function(String symbol) onSymbolSelected;

  const StockSearchDialog({
    super.key,
    required this.targetSlotIndex,
    required this.onSymbolSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int targetSlotIndex,
    required Function(String symbol) onSymbolSelected,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StockSearchDialog(
        targetSlotIndex: targetSlotIndex,
        onSymbolSelected: onSymbolSelected,
      ),
    );
  }

  @override
  State<StockSearchDialog> createState() => _StockSearchDialogState();
}

class _StockSearchDialogState extends State<StockSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _allSymbols = [
    {
      'symbol': 'ASII',
      'name': 'Astra International Tbk.',
      'price': '4,790',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'BMRI',
      'name': 'Bank Mandiri (Persero) Tbk.',
      'price': '4,210',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'BBNI',
      'name': 'Bank Negara Indonesia Tbk.',
      'price': '3,710',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'UNTR',
      'name': 'United Tractors Tbk.',
      'price': '24,475',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'GGRM',
      'name': 'Gudang Garam Tbk.',
      'price': '19,650',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'HMSP',
      'name': 'HM Sampoerna Tbk.',
      'price': '745',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'BBRI',
      'name': 'Bank Rakyat Indonesia Tbk.',
      'price': '3,150',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'UNVR',
      'name': 'Unilever Indonesia Tbk.',
      'price': '1,760',
      'change': '0 (0.00%)',
    },
    {
      'symbol': 'BBCA',
      'name': 'Bank Central Asia Tbk.',
      'price': '10,250',
      'change': '+125 (+1.23%)',
    },
    {
      'symbol': 'TLKM',
      'name': 'Telkom Indonesia Tbk.',
      'price': '2,980',
      'change': '-40 (-1.32%)',
    },
    {
      'symbol': 'GOTO',
      'name': 'GoTo Gojek Tokopedia Tbk.',
      'price': '54',
      'change': '+1 (+1.89%)',
    },
    {
      'symbol': 'ADRO',
      'name': 'Adaro Energy Indonesia Tbk.',
      'price': '3,680',
      'change': '+80 (+2.22%)',
    },
    {
      'symbol': 'PTBA',
      'name': 'Bukit Asam Tbk.',
      'price': '2,750',
      'change': '+20 (+0.73%)',
    },
    {
      'symbol': 'TPIA',
      'name': 'Chandra Asri Pacific Tbk.',
      'price': '7,200',
      'change': '+475 (+7.06%)',
    },
    {
      'symbol': 'INET',
      'name': 'Sinergi Inti Andalan Prima Tbk.',
      'price': '350',
      'change': '+22 (+6.71%)',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allSymbols.where((item) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return item['symbol']!.toLowerCase().contains(q) ||
          item['name']!.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Container(
        width: 380,
        height: 440,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Symbol for Slot #${widget.targetSlotIndex + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search input
            TextField(
              controller: _searchController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search ticker e.g. BBCA, BBRI, ASII...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 16,
                  color: AppColors.textMuted,
                ),
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
            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),

            // Symbol List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 28,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No stocks found for "$_query"',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final sym = item['symbol']!;

                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          tileColor: Colors.transparent,
                          hoverColor: AppColors.tableRowHover,
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.badgeBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  sym,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.badgeBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['name']!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            item['price']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          onTap: () {
                            widget.onSymbolSelected(sym);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
