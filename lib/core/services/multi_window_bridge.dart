import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';

/// Centralized Multi-Window IPC Bridge & Synchronized Global Memory.
///
/// Features:
/// 1. Synchronized In-Memory Global State (Key-Value Store accessible from all windows).
/// 2. Single-Connection WebSocket & Market Stream Relay (Window 0 holds the connection, relays to sub-windows).
/// 3. Cross-Window Action Dispatcher (Place orders, switch active stocks, broadcast events).
class MultiWindowBridge {
  static int _currentWindowId = 0;
  static bool _isInitialized = false;

  /// In-memory synchronized global state store (Shared across all windows via IPC)
  static final Map<String, dynamic> _sharedMemory = {
    'user': {
      'name': 'Pro Trader',
      'email': 'trader@stockbit.com',
      'buyingPower': 45200000.0,
      'isLoggedIn': true,
    },
    'activeSymbol': 'BBCA',
    'theme': 'dark',
  };

  /// Registered Sub-Window IDs connected to Window 0 (Main Master Window)
  static final Set<int> _connectedSubWindows = {};

  /// StreamController for incoming market data packets
  static final StreamController<Map<String, dynamic>> _marketDataStream =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of market ticks & orderbook updates
  static Stream<Map<String, dynamic>> get marketDataStream =>
      _marketDataStream.stream;

  /// StreamController for cross-window actions (e.g. order placed, symbol switched)
  static final StreamController<Map<String, dynamic>> _crossWindowEvents =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get crossWindowEvents =>
      _crossWindowEvents.stream;

  /// Current Window ID (0 is Master Window, >=1 are Pop-Out Sub-Windows)
  static int get currentWindowId => _currentWindowId;
  static bool get isMasterWindow => _currentWindowId == 0;

  // ─── INITIALIZATION ────────────────────────────────────────────────────────

  /// Initializes the Multi-Window Bridge.
  /// Call this in `main()` for both Main Window (windowId = 0) and Detached Windows (windowId >= 1).
  static Future<void> initialize({int windowId = 0}) async {
    if (!DesktopWindowHelper.isDesktop) return;
    _currentWindowId = windowId;

    if (_isInitialized) return;
    _isInitialized = true;

    DesktopMultiWindow.setMethodHandler(_handleIpcMethodCall);

    if (!isMasterWindow) {
      // Sub-Window: Register to Window 0 and fetch synced global memory
      try {
        final result = await DesktopMultiWindow.invokeMethod(
          0,
          'register_sub_window',
          {'windowId': _currentWindowId},
        );

        if (result is Map) {
          _sharedMemory.addAll(Map<String, dynamic>.from(result));
        }
      } catch (e) {
        debugPrint('Sub-window failed to register with master: $e');
      }
    }
  }

  // ─── SHARED MEMORY / GLOBAL VARIABLES ─────────────────────────────────────

  /// Reads a global variable from synchronized shared memory.
  static T? getGlobal<T>(String key) {
    final val = _sharedMemory[key];
    if (val is T) return val;
    return null;
  }

  /// Writes a global variable to shared memory and broadcasts the update to all other windows.
  static Future<void> setGlobal(String key, dynamic value) async {
    _sharedMemory[key] = value;

    if (DesktopWindowHelper.isDesktop) {
      if (isMasterWindow) {
        // Broadcast memory change to all connected sub-windows
        _broadcastToSubWindows('on_global_memory_updated', {
          'key': key,
          'value': value,
        });
      } else {
        // Send memory change to Master Window (Window 0), which will broadcast it
        try {
          await DesktopMultiWindow.invokeMethod(0, 'set_global_memory', {
            'key': key,
            'value': value,
          });
        } catch (_) {}
      }
    }
  }

  // ─── CENTRALIZED WEBSOCKET & MARKET STREAM ────────────────────────────────

  /// Broadcasts market tick or orderbook update from Master Window to all sub-windows.
  static void broadcastMarketData(String symbol, Map<String, dynamic> data) {
    final payload = {
      'symbol': symbol,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    };

    // Emit locally in master window
    _marketDataStream.add(payload);

    // Relay to all active sub-windows
    if (isMasterWindow) {
      _broadcastToSubWindows('on_market_data', payload);
    }
  }

  /// Sub-window requests master window to subscribe to a symbol's live socket feed.
  static Future<void> subscribeSymbol(String symbol) async {
    if (isMasterWindow) {
      // Already on master, subscribe directly in local service
    } else {
      try {
        await DesktopMultiWindow.invokeMethod(0, 'subscribe_symbol', {
          'symbol': symbol,
          'fromWindowId': _currentWindowId,
        });
      } catch (_) {}
    }
  }

  /// Send an order or message through the centralized WebSocket connection.
  static Future<void> sendWebSocketMessage(Map<String, dynamic> message) async {
    if (isMasterWindow) {
      // Process / send via master socket channel
      debugPrint('[Master WS Socket Send] $message');
    } else {
      // Relay to master window to send through the master socket
      try {
        await DesktopMultiWindow.invokeMethod(0, 'send_ws_message', message);
      } catch (_) {}
    }
  }

  // ─── CROSS-WINDOW EVENT DISPATCH ──────────────────────────────────────────

  /// Dispatches an event (e.g. 'order_created', 'stock_selected') to all open windows.
  static Future<void> dispatchCrossWindowEvent(
    String eventName,
    Map<String, dynamic> data,
  ) async {
    final payload = {'event': eventName, 'data': data};
    _crossWindowEvents.add(payload);

    if (DesktopWindowHelper.isDesktop) {
      if (isMasterWindow) {
        _broadcastToSubWindows('on_cross_window_event', payload);
      } else {
        try {
          await DesktopMultiWindow.invokeMethod(0, 'dispatch_event', payload);
        } catch (_) {}
      }
    }
  }

  // ─── INTERNAL IPC HANDLER ─────────────────────────────────────────────────

  static Future<dynamic> _handleIpcMethodCall(
    MethodCall call,
    int fromWindowId,
  ) async {
    switch (call.method) {
      // Master Window receives registration from a new sub-window
      case 'register_sub_window':
        final subId = call.arguments['windowId'] as int;
        _connectedSubWindows.add(subId);
        return _sharedMemory;

      // Master Window receives unregistration
      case 'unregister_sub_window':
        final subId = call.arguments['windowId'] as int;
        _connectedSubWindows.remove(subId);
        return true;

      // Master receives global memory update from sub-window
      case 'set_global_memory':
        final key = call.arguments['key'] as String;
        final value = call.arguments['value'];
        _sharedMemory[key] = value;
        _broadcastToSubWindows('on_global_memory_updated', {
          'key': key,
          'value': value,
        }, excludeWindowId: fromWindowId);
        return true;

      // Sub-window receives global memory update from master
      case 'on_global_memory_updated':
        final key = call.arguments['key'] as String;
        final value = call.arguments['value'];
        _sharedMemory[key] = value;
        return true;

      // Sub-window receives market data packet from master
      case 'on_market_data':
        final data = Map<String, dynamic>.from(call.arguments as Map);
        _marketDataStream.add(data);
        return true;

      // Master receives subscribe request from sub-window
      case 'subscribe_symbol':
        final symbol = call.arguments['symbol'] as String;
        debugPrint(
          '[Master IPC] Sub-window $fromWindowId subscribed to $symbol',
        );
        return true;

      // Master receives WS message to send out
      case 'send_ws_message':
        final msg = Map<String, dynamic>.from(call.arguments as Map);
        debugPrint(
          '[Master WS Relay] Forwarding message from Window $fromWindowId: $msg',
        );
        return true;

      // Cross-window event broadcast
      case 'dispatch_event':
        final payload = Map<String, dynamic>.from(call.arguments as Map);
        _crossWindowEvents.add(payload);
        if (isMasterWindow) {
          _broadcastToSubWindows(
            'on_cross_window_event',
            payload,
            excludeWindowId: fromWindowId,
          );
        }
        return true;

      case 'on_cross_window_event':
        final payload = Map<String, dynamic>.from(call.arguments as Map);
        _crossWindowEvents.add(payload);
        return true;

      default:
        return null;
    }
  }

  static void _broadcastToSubWindows(
    String method,
    dynamic arguments, {
    int? excludeWindowId,
  }) {
    for (final subId in _connectedSubWindows.toList()) {
      if (excludeWindowId != null && subId == excludeWindowId) continue;
      try {
        DesktopMultiWindow.invokeMethod(subId, method, arguments);
      } catch (_) {
        _connectedSubWindows.remove(subId);
      }
    }
  }
}
