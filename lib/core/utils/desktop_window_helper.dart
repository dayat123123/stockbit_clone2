import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Helper utility for orchestrating frameless/windowless OS desktop window management,
/// custom window controls (minimize, maximize, close), and smooth state transitions.
/// Safe for cross-platform execution (Web, Windows, macOS, Linux).
class DesktopWindowHelper {
  static const Size loginWindowSize = Size(820, 520);
  static const Size terminalMinSize = Size(960, 600);
  static const Size terminalDefaultSize = Size(1024, 640);

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Initializes the WindowManager in frameless/windowless mode on desktop platforms.
  static Future<void> initialize() async {
    if (!isDesktop) return;

    try {
      await windowManager.ensureInitialized();
      final windowOptions = WindowOptions(
        size: loginWindowSize,
        minimumSize: loginWindowSize,
        maximumSize: loginWindowSize,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden, // Windowless frameless design
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setResizable(false);
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (_) {}
  }

  /// Sets the window to fixed, non-resizable compact dimensions for the Login page.
  static Future<void> setToLoginMode() async {
    if (!isDesktop) return;

    try {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
      }
      await windowManager.setResizable(false);
      await windowManager.setMinimumSize(loginWindowSize);
      await windowManager.setMaximumSize(loginWindowSize);
      await windowManager.setSize(loginWindowSize);
      await windowManager.center();
    } catch (_) {}
  }

  /// Expands the window to full resizable workspace terminal mode with a safe minimum size constraint.
  static Future<void> setToTerminalMode() async {
    if (!isDesktop) return;

    try {
      await windowManager.setMaximumSize(const Size(4096, 4096));
      await windowManager.setMinimumSize(terminalMinSize);
      await windowManager.setResizable(true);
      await windowManager.setSize(terminalDefaultSize);
      await windowManager.center();
    } catch (_) {}
  }

  /// Minimizes the application window.
  static Future<void> minimize() async {
    if (!isDesktop) return;

    try {
      await windowManager.minimize();
    } catch (_) {}
  }

  /// Toggles between maximized and restored window states.
  static Future<void> toggleMaximize() async {
    if (!isDesktop) return;

    try {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (_) {}
  }

  /// Closes the application window.
  static Future<void> close() async {
    if (!isDesktop) return;

    try {
      await windowManager.close();
    } catch (_) {}
  }
}
