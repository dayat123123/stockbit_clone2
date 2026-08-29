import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Feature Screen: Displays user investment portfolio and unrealized P&L.
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Rp 128,450,000',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Unrealized P&L',
                      style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '+Rp 8,350,000 (+6.94%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bidGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'HOLDINGS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),

          Expanded(
            child: ListView(
              children: [
                _buildHoldingRow('BBCA', '50 Lot', 'Rp 9,850', '+12.4%', true),
                const Divider(color: AppColors.border, height: 1),
                _buildHoldingRow('BMRI', '80 Lot', 'Rp 6,500', '+8.2%', true),
                const Divider(color: AppColors.border, height: 1),
                _buildHoldingRow('TLKM', '100 Lot', 'Rp 2,940', '-3.1%', false),
                const Divider(color: AppColors.border, height: 1),
                _buildHoldingRow('ASII', '40 Lot', 'Rp 4,980', '+2.5%', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(
    String sym,
    String lot,
    String price,
    String pnl,
    bool isGreen,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                sym,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lot,
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                pnl,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isGreen ? AppColors.bidGreen : AppColors.offerRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
