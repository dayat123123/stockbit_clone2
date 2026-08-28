import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';

/// Service to handle opening separate/detached windows in Flutter Desktop
/// (using `desktop_multi_window`) and web browser pop-outs.
class PopOutWindowService {
  /// Spawns an independent native OS sub-window on Desktop or browser window on Web.
  static Future<void> openPopOutWindow({
    required WorkspaceWidgetType type,
    required String symbol,
    Size size = const Size(540, 480),
    String? title,
  }) async {
    final windowTitle = title ?? '$symbol - ${type.label} (Stockbit Pro)';
    final payload = jsonEncode({
      'type': type.name,
      'symbol': symbol,
      'title': windowTitle,
    });

    if (DesktopWindowHelper.isDesktop) {
      try {
        final window = await DesktopMultiWindow.createWindow(payload);
        window
          ..setFrame(const Offset(120, 120) & size)
          ..center()
          ..setTitle(windowTitle)
          ..show();
      } catch (e) {
        debugPrint('Failed to open desktop sub-window: $e');
      }
    } else if (kIsWeb) {
      debugPrint('Web pop-out triggered for $symbol - $type');
      // Web can handle popup routing / multi-tab
    }
  }
}
