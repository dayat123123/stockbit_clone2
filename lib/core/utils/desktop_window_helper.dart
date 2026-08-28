import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Helper utility for orchestrating frameless/windowless OS desktop window management,
/// custom window controls (minimize, maximize, close), and smooth state transitions.
class DesktopWindowHelper {
  static const Size loginWindowSize = Size(820, 520);
  static const Size terminalMinSize = Size(960, 600);
  static const Size terminalDefaultSize = Size(1024, 640);

  /// Initializes the WindowManager in frameless/windowless mode on desktop platforms.
  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
    }
  }

  /// Sets the window to fixed, non-resizable compact dimensions for the Login page.
  static Future<void> setToLoginMode() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
  }

  /// Expands the window to full resizable workspace terminal mode with a safe minimum size constraint.
  static Future<void> setToTerminalMode() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        await windowManager.setMaximumSize(const Size(4096, 4096));
        await windowManager.setMinimumSize(terminalMinSize);
        await windowManager.setResizable(true);
        await windowManager.setSize(terminalDefaultSize);
        await windowManager.center();
      } catch (_) {}
    }
  }

  /// Minimizes the application window.
  static Future<void> minimize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.minimize();
    }
  }

  /// Toggles between maximized and restored window states.
  static Future<void> toggleMaximize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (await windowManager.isMaximized()) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    }
  }

  /// Closes the application window.
  static Future<void> close() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.close();
    }
  }
}
