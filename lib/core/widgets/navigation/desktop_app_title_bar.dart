import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/widgets/custom_window_caption_buttons.dart';
import 'package:window_manager/window_manager.dart';

/// Top Title Bar styled cleanly with Custom Flat Windows Control Buttons.
/// - Left: Stockbit Pro Logo + Brand Text.
/// - Right: Clean integrated Flat Minimize, Maximize/Restore, and Close buttons.
/// - Drag Area: Double-click to maximize/restore, drag to move window.
class DesktopAppTitleBar extends StatelessWidget {
  final String? title;
  final bool showMaximize;

  const DesktopAppTitleBar({super.key, this.title, this.showMaximize = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.titleBarBg,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          // ── Brand Logo & Text (Left) ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.trending_up,
                      color: AppColors.background,
                      size: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'STOCKBIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Center Draggable Title Region ─────────────────────────────────
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              onDoubleTap: () async {
                await DesktopWindowHelper.toggleMaximize();
              },
              child: const SizedBox.expand(),
            ),
          ),

          // ── Right: Custom Flat Windows Control Buttons ───────────────────
          const CustomWindowCaptionButtons(),
        ],
      ),
    );
  }
}
