import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';

/// Sleek custom window control buttons (Minimize, Maximize/Restore, Close)
/// designed specifically for windowless/frameless desktop applications.
/// Automatically hides itself on Web / Mobile browsers.
class CustomWindowCaptionButtons extends StatefulWidget {
  final bool showMaximize;
  final double height;

  const CustomWindowCaptionButtons({
    super.key,
    this.showMaximize = true,
    this.height = 30,
  });

  @override
  State<CustomWindowCaptionButtons> createState() =>
      _CustomWindowCaptionButtonsState();
}

class _CustomWindowCaptionButtonsState extends State<CustomWindowCaptionButtons>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (DesktopWindowHelper.isDesktop) {
      windowManager.addListener(this);
      _checkMaximizedState();
    }
  }

  @override
  void dispose() {
    if (DesktopWindowHelper.isDesktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _checkMaximizedState() async {
    if (!DesktopWindowHelper.isDesktop) return;
    try {
      final isMax = await windowManager.isMaximized();
      if (mounted) {
        setState(() => _isMaximized = isMax);
      }
    } catch (_) {}
  }

  @override
  void onWindowMaximize() {
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _isMaximized = false);
  }

  @override
  void onWindowRestore() {
    setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely on Web / Non-Desktop
    if (!DesktopWindowHelper.isDesktop) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minimize Button
        _buildCaptionButton(
          icon: Icons.remove,
          tooltip: 'Minimize',
          hoverColor: AppColors.cardSurface,
          iconColor: AppColors.textSecondary,
          onTap: DesktopWindowHelper.minimize,
        ),

        // Maximize / Restore Button (Dynamic toggle icon & tooltip)
        if (widget.showMaximize)
          _buildCaptionButton(
            icon: _isMaximized
                ? Icons
                      .filter_none_outlined // Dual-box icon for Restore
                : Icons.crop_square_outlined, // Single-box icon for Maximize
            tooltip: _isMaximized ? 'Restore Down' : 'Maximize',
            hoverColor: AppColors.cardSurface,
            iconColor: AppColors.textSecondary,
            iconSize: _isMaximized ? 11.5 : 13,
            onTap: () async {
              await DesktopWindowHelper.toggleMaximize();
              await _checkMaximizedState();
            },
          ),

        // Close Button (Red hover highlight)
        _buildCaptionButton(
          icon: Icons.close,
          tooltip: 'Close',
          hoverColor: AppColors.offerRed,
          iconColor: AppColors.textSecondary,
          hoverIconColor: Colors.white,
          onTap: DesktopWindowHelper.close,
        ),
      ],
    );
  }

  Widget _buildCaptionButton({
    required IconData icon,
    required String tooltip,
    required Color hoverColor,
    required Color iconColor,
    Color? hoverIconColor,
    double iconSize = 14,
    required VoidCallback onTap,
  }) {
    return _CaptionHoverButton(
      icon: icon,
      tooltip: tooltip,
      hoverColor: hoverColor,
      iconColor: iconColor,
      hoverIconColor: hoverIconColor,
      iconSize: iconSize,
      height: widget.height,
      onTap: onTap,
    );
  }
}

class _CaptionHoverButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color hoverColor;
  final Color iconColor;
  final Color? hoverIconColor;
  final double iconSize;
  final double height;
  final VoidCallback onTap;

  const _CaptionHoverButton({
    required this.icon,
    required this.tooltip,
    required this.hoverColor,
    required this.iconColor,
    this.hoverIconColor,
    required this.iconSize,
    required this.height,
    required this.onTap,
  });

  @override
  State<_CaptionHoverButton> createState() => _CaptionHoverButtonState();
}

class _CaptionHoverButtonState extends State<_CaptionHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: widget.height,
            color: _isHovered ? widget.hoverColor : Colors.transparent,
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: _isHovered && widget.hoverIconColor != null
                    ? widget.hoverIconColor
                    : widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
