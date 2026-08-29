import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/widgets/navigation/desktop_top_header.dart';
import 'package:stockbit_clone2/core/workspace/widgets/workspace_canvas_view.dart';

/// Layout Feature Screen: The Multi-Terminal interactive workspace.
///
/// Features:
/// - Exclusive multi-window modular trading terminal with tabs.
/// - Fluid drag & drop with smooth Magnetic Snapping.
/// - Grid presets (2x4, 2x3, 2x2, etc.) & Auto Arrange.
/// - Fixed Full-Screen and Scrollable Grid layout modes.
class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Workspace Toolbar (Tabs, Grid Presets, LayoutMode, Add Window)
          DesktopTopHeader(),

          // Multi-Terminal Interactive Workspace Canvas
          Expanded(child: RepaintBoundary(child: WorkspaceCanvasView())),
        ],
      ),
    );
  }
}
