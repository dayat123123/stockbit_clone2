import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window.dart';

/// The chrome/shell for every floating window: header bar, resize handle.
/// Content is provided by [contentBuilder].
///
/// This widget does NOT contain drag logic — drag is handled by the canvas
/// Listener in [FloatingWorkspaceCanvas] via [CanvasDragController].
class FloatingWindowShell extends StatelessWidget {
  final WorkspaceWindow window;
  final bool isActive;
  final Size canvasSize;

  /// Builds the body content for this window's widget type.
  final Widget Function(WorkspaceWindow window) contentBuilder;

  /// Builds the header title area for this window.
  final Widget Function(WorkspaceWindow window)? headerBuilder;

  const FloatingWindowShell({
    super.key,
    required this.window,
    required this.isActive,
    required this.contentBuilder,
    this.headerBuilder,
    this.canvasSize = const Size(1400, 800),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: window.position.dx,
      top: window.position.dy,
      width: window.size.width,
      height: window.size.height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isActive ? AppColors.borderActive : AppColors.border,
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: isActive ? AppColors.activeGlow : AppColors.windowShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            MouseRegion(
              cursor: SystemMouseCursors.move,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen.withValues(alpha: 0.12)
                      : AppColors.cardHeader,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppColors.primaryGreen.withValues(alpha: 0.3)
                          : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),

                    // Widget type icon
                    Icon(
                      window.widgetType.icon,
                      size: 14,
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),

                    // Custom header content or default label
                    Expanded(
                      child: headerBuilder != null
                          ? headerBuilder!(window)
                          : Text(
                              window.widgetType.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),

                    // Close button
                    InkWell(
                      onTap: () => context
                          .read<WorkspaceBloc>()
                          .add(RemoveWindowEvent(window.id)),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.close,
                            size: 12, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(child: contentBuilder(window)),

            // ── Resize Handle ─────────────────────────────────────────────
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onPanUpdate: (d) {
                  final newW =
                      (window.size.width + d.delta.dx).clamp(260.0, 800.0);
                  final newH =
                      (window.size.height + d.delta.dy).clamp(280.0, 900.0);
                  context.read<WorkspaceBloc>().add(ResizeWindowEvent(
                      windowId: window.id, newSize: Size(newW, newH)));
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeDownRight,
                  child: Container(
                    width: 14,
                    height: 14,
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.south_east,
                        size: 9, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
