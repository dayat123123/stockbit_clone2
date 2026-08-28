import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

class DesktopBottomTicker extends StatefulWidget {
  const DesktopBottomTicker({super.key});

  @override
  State<DesktopBottomTicker> createState() => _DesktopBottomTickerState();
}

class _DesktopBottomTickerState extends State<DesktopBottomTicker> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Weather / IDX Status
          const Icon(
            Icons.wb_sunny_outlined,
            size: 12,
            color: AppColors.araYellow,
          ),
          const SizedBox(width: 4),
          const Text(
            '26°C Cerah',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),

          const SizedBox(width: 16),
          const VerticalDivider(
            color: AppColors.border,
            width: 1,
            indent: 4,
            endIndent: 4,
          ),
          const SizedBox(width: 16),

          // Main Index: IHSG
          const Text(
            'IHSG',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '6,521.75',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '+12.40 (+0.19%)',
            style: TextStyle(fontSize: 10, color: AppColors.bidGreen),
          ),

          const SizedBox(width: 16),
          const VerticalDivider(
            color: AppColors.border,
            width: 1,
            indent: 4,
            endIndent: 4,
          ),
          const SizedBox(width: 16),

          // Trending Stocks Marquee / List
          const Text(
            'Trending:',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          _buildTickerItem('INET', '350', '+2.45%', AppColors.bidGreen),
          const SizedBox(width: 12),
          _buildTickerItem('KIJA', '218', '-0.91%', AppColors.offerRed),
          const SizedBox(width: 12),
          _buildTickerItem('DSSA', '1,140', '+0.00%', AppColors.neutral),
          const SizedBox(width: 12),
          _buildTickerItem('TPIA', '7,200', '+1.12%', AppColors.bidGreen),

          const Spacer(),

          // Connection status & Clock
          const Icon(Icons.wifi, size: 11, color: AppColors.primaryGreen),
          const SizedBox(width: 4),
          const Text(
            'Connected',
            style: TextStyle(fontSize: 10, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Text(
            _currentTime,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerItem(
    String symbol,
    String price,
    String change,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(change, style: TextStyle(fontSize: 9, color: color)),
      ],
    );
  }
}
