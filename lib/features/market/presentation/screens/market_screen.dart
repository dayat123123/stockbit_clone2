import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Feature Screen: Displays Market and Sectoral overview.
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          const Text(
            'MAJOR INDICES',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          _buildIndexCard('IHSG', '7,285.50', '+30.42 (+0.42%)', true),
          const SizedBox(height: 4),
          _buildIndexCard('LQ45', '982.14', '+6.25 (+0.64%)', true),
          const SizedBox(height: 4),
          _buildIndexCard('IDX30', '498.70', '+3.10 (+0.62%)', true),

          const SizedBox(height: 12),
          const Text(
            'SECTOR LEADERS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          _buildSectorRow('Financials (IDXFIN)', '+1.12%', true),
          _buildSectorRow('Energy (IDXENERGY)', '+0.85%', true),
          _buildSectorRow('Technology (IDXTECH)', '-1.40%', false),
          _buildSectorRow('Consumer Non-Cyc (IDXNONCYC)', '+0.32%', true),
        ],
      ),
    );
  }

  Widget _buildIndexCard(
    String name,
    String value,
    String change,
    bool isGreen,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isGreen ? AppColors.bidGreen : AppColors.offerRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorRow(String name, String change, bool isGreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isGreen ? AppColors.bidGreen : AppColors.offerRed,
            ),
          ),
        ],
      ),
    );
  }
}
