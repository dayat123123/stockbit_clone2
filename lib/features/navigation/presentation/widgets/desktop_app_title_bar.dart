import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/widgets/custom_window_caption_buttons.dart';

/// Topmost Frameless Window Title Bar spanning 100% full width of the desktop application.
/// Automatically hides itself on Web / Mobile browsers.
class DesktopAppTitleBar extends StatelessWidget {
  final bool showMaximize;
  final String title;

  const DesktopAppTitleBar({
    super.key,
    this.showMaximize = true,
    this.title = 'Stockbit Desktop Pro',
  });

  @override
  Widget build(BuildContext context) {
    // Hide completely on Web / Non-Desktop platforms
    if (!DesktopWindowHelper.isDesktop) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: AppColors.systemBackgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          // ── Left: Subtle App / Window Title ───────────────────────────────
          const SizedBox(width: 10),
          const Icon(Icons.trending_up, size: 13, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),

          // ── Center: Full Drag Area to Move Window ─────────────────────────
          const Expanded(child: DragToMoveArea(child: SizedBox(height: 30))),

          // ── Right: Custom Window Control Buttons (Minimize, Maximize, Close)
          CustomWindowCaptionButtons(showMaximize: showMaximize, height: 30),
        ],
      ),
    );
  }
}
