import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';

/// Intelligent Neighbor-Aware Magnetic Snapping for workspace windows.
///
/// Features:
/// - Verifies spatial 2D projection/overlap before snapping (prevents false snaps to distant windows).
/// - Automatically aligns flush edges (top/bottom when side-by-side, left/right when stacked).
/// - 24px comfortable snap radius so windows attract naturally without needing to squish/himpit them.
class MagneticSnapHelper {
  static const double snapThreshold = 24.0;
  static const double edgeSpacing = 4.0;
  static const double minWidth = 200.0;
  static const double minHeight = 160.0;
  static const double maxWidth = 1920.0;
  static const double maxHeight = 1920.0;

  /// Helper to check if two intervals overlap or are within snap proximity
  static bool _intervalsOverlapOrNear(
    double start1,
    double length1,
    double start2,
    double length2,
  ) {
    final overlapStart = max(start1, start2);
    final overlapEnd = min(start1 + length1, start2 + length2);
    return (overlapEnd - overlapStart) >= -snapThreshold;
  }

  /// Computes the magnetically snapped position for a moving window.
  static Offset calculateSnap({
    required String activeWindowId,
    required Offset targetPosition,
    required Size windowSize,
    required List<WorkspaceWindowModel> otherWindows,
    required Size canvasSize,
    required bool isScrollable,
  }) {
    double newX = targetPosition.dx;
    double newY = targetPosition.dy;

    final windowW = windowSize.width;
    final windowH = windowSize.height;

    // ── 1. Inter-Window Magnetic Snapping (Neighbor-Aware) ───────────────────
    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;

      final otherL = other.position.dx;
      final otherT = other.position.dy;
      final otherW = other.size.width;
      final otherH = other.size.height;
      final otherR = otherL + otherW;
      final otherB = otherT + otherH;

      // Check if windows are on the same vertical span (Side-by-Side candidates)
      if (_intervalsOverlapOrNear(newY, windowH, otherT, otherH)) {
        // a) Snap left edge to neighbor's right edge (+ spacing)
        if ((newX - (otherR + edgeSpacing)).abs() < snapThreshold) {
          newX = otherR + edgeSpacing;
        }
        // b) Snap right edge to neighbor's left edge (- spacing)
        else if ((newX + windowW - (otherL - edgeSpacing)).abs() < snapThreshold) {
          newX = otherL - edgeSpacing - windowW;
        }
        // c) Snap left edge flush with neighbor's left edge
        else if ((newX - otherL).abs() < snapThreshold) {
          newX = otherL;
        }
        // d) Snap right edge flush with neighbor's right edge
        else if ((newX + windowW - otherR).abs() < snapThreshold) {
          newX = otherR - windowW;
        }

        // Also align vertical top / bottom edges flush if close
        if ((newY - otherT).abs() < snapThreshold) {
          newY = otherT;
        } else if ((newY + windowH - otherB).abs() < snapThreshold) {
          newY = otherB - windowH;
        }
      }

      // Check if windows are on the same horizontal span (Stacked candidates)
      if (_intervalsOverlapOrNear(newX, windowW, otherL, otherW)) {
        // a) Snap top edge to neighbor's bottom edge (+ spacing)
        if ((newY - (otherB + edgeSpacing)).abs() < snapThreshold) {
          newY = otherB + edgeSpacing;
        }
        // b) Snap bottom edge to neighbor's top edge (- spacing)
        else if ((newY + windowH - (otherT - edgeSpacing)).abs() < snapThreshold) {
          newY = otherT - edgeSpacing - windowH;
        }
        // c) Snap top edge flush with neighbor's top edge
        else if ((newY - otherT).abs() < snapThreshold) {
          newY = otherT;
        }
        // d) Snap bottom edge flush with neighbor's bottom edge
        else if ((newY + windowH - otherB).abs() < snapThreshold) {
          newY = otherB - windowH;
        }

        // Also align horizontal left / right edges flush if close
        if ((newX - otherL).abs() < snapThreshold) {
          newX = otherL;
        } else if ((newX + windowW - otherR).abs() < snapThreshold) {
          newX = otherR - windowW;
        }
      }
    }

    // ── 2. Canvas Boundary Snapping ──────────────────────────────────────────
    // Left boundary
    if ((newX - edgeSpacing).abs() < snapThreshold || newX < edgeSpacing) {
      newX = edgeSpacing;
    }
    // Right boundary
    final rightEdge = canvasSize.width - edgeSpacing;
    if ((newX + windowW - rightEdge).abs() < snapThreshold || (newX + windowW) > rightEdge) {
      newX = max(edgeSpacing, rightEdge - windowW);
    }
    // Top boundary
    if ((newY - edgeSpacing).abs() < snapThreshold || newY < edgeSpacing) {
      newY = edgeSpacing;
    }
    // Bottom boundary (if not scrollable)
    if (!isScrollable) {
      final bottomEdge = canvasSize.height - edgeSpacing;
      if ((newY + windowH - bottomEdge).abs() < snapThreshold || (newY + windowH) > bottomEdge) {
        newY = max(edgeSpacing, bottomEdge - windowH);
      }
    }

    // ── 3. Clamping ──────────────────────────────────────────────────────────
    final clampedX = newX.clamp(0.0, max(0.0, canvasSize.width - 60)).toDouble();
    final maxY = isScrollable ? 5000.0 : max(0.0, canvasSize.height - 40);
    final clampedY = newY.clamp(0.0, maxY).toDouble();

    return Offset(clampedX, clampedY);
  }

  /// Computes the magnetically snapped size and position during/after window resizing.
  static ({Size size, Offset position}) calculateResizeSnap({
    required String activeWindowId,
    required Offset position,
    required Size targetSize,
    required List<WorkspaceWindowModel> otherWindows,
    required Size canvasSize,
  }) {
    double posX = position.dx;
    double posY = position.dy;
    double width = targetSize.width.clamp(minWidth, maxWidth);
    double height = targetSize.height.clamp(minHeight, maxHeight);

    final right = posX + width;
    final bottom = posY + height;

    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;
      final otherL = other.position.dx;
      final otherT = other.position.dy;
      final otherW = other.size.width;
      final otherH = other.size.height;
      final otherR = otherL + otherW;
      final otherB = otherT + otherH;

      // 1. Right Edge Snapping (if vertically adjacent)
      if (_intervalsOverlapOrNear(posY, height, otherT, otherH)) {
        if ((right - (otherL - edgeSpacing)).abs() < snapThreshold) {
          width = (otherL - edgeSpacing) - posX;
        } else if ((right - otherR).abs() < snapThreshold) {
          width = otherR - posX;
        }
      }

      // 2. Bottom Edge Snapping (if horizontally adjacent)
      if (_intervalsOverlapOrNear(posX, width, otherL, otherW)) {
        if ((bottom - (otherT - edgeSpacing)).abs() < snapThreshold) {
          height = (otherT - edgeSpacing) - posY;
        } else if ((bottom - otherB).abs() < snapThreshold) {
          height = otherB - posY;
        }
      }

      // 3. Left Edge Snapping (if vertically adjacent)
      if (_intervalsOverlapOrNear(posY, height, otherT, otherH)) {
        if ((posX - (otherR + edgeSpacing)).abs() < snapThreshold) {
          final delta = (otherR + edgeSpacing) - posX;
          posX = otherR + edgeSpacing;
          width -= delta;
        } else if ((posX - otherL).abs() < snapThreshold) {
          final delta = otherL - posX;
          posX = otherL;
          width -= delta;
        }
      }

      // 4. Top Edge Snapping (if horizontally adjacent)
      if (_intervalsOverlapOrNear(posX, width, otherL, otherW)) {
        if ((posY - (otherB + edgeSpacing)).abs() < snapThreshold) {
          final delta = (otherB + edgeSpacing) - posY;
          posY = otherB + edgeSpacing;
          height -= delta;
        } else if ((posY - otherT).abs() < snapThreshold) {
          final delta = otherT - posY;
          posY = otherT;
          height -= delta;
        }
      }
    }

    // Canvas Edge Snaps on Resize
    final canvasRight = canvasSize.width - edgeSpacing;
    if ((posX + width - canvasRight).abs() < snapThreshold) {
      width = canvasRight - posX;
    }
    final canvasBottom = canvasSize.height - edgeSpacing;
    if ((posY + height - canvasBottom).abs() < snapThreshold) {
      height = canvasBottom - posY;
    }

    return (
      size: Size(
        width.clamp(minWidth, maxWidth),
        height.clamp(minHeight, maxHeight),
      ),
      position: Offset(max(0.0, posX), max(0.0, posY)),
    );
  }
}
