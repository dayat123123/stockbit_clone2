import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';

/// Helper utility providing smooth magnetic snapping calculations for workspace windows
/// during both movement (drag-and-drop) and resizing.
class MagneticSnapHelper {
  static const double snapThreshold = 16.0;
  static const double edgeSpacing = 4.0;
  static const double minWidth = 180.0;
  static const double minHeight = 140.0;
  static const double maxWidth = 1600.0;
  static const double maxHeight = 1600.0;

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

    // ── 1. Canvas Boundary Snapping ──────────────────────────────────────────
    // Left boundary
    if ((newX - edgeSpacing).abs() < snapThreshold) {
      newX = edgeSpacing;
    }
    // Right boundary
    final rightEdge = canvasSize.width - edgeSpacing;
    if ((newX + windowW - rightEdge).abs() < snapThreshold) {
      newX = rightEdge - windowW;
    }
    // Top boundary
    if ((newY - edgeSpacing).abs() < snapThreshold) {
      newY = edgeSpacing;
    }
    // Bottom boundary (if not scrollable)
    if (!isScrollable) {
      final bottomEdge = canvasSize.height - edgeSpacing;
      if ((newY + windowH - bottomEdge).abs() < snapThreshold) {
        newY = bottomEdge - windowH;
      }
    }

    // ── 2. Inter-Window Magnetic Snapping ────────────────────────────────────
    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;

      final otherL = other.position.dx;
      final otherT = other.position.dy;
      final otherR = other.position.dx + other.size.width;
      final otherB = other.position.dy + other.size.height;

      // X-Axis Snapping:
      // a) Snap to other window's right edge
      if ((newX - (otherR + edgeSpacing)).abs() < snapThreshold) {
        newX = otherR + edgeSpacing;
      }
      // b) Snap to other window's left edge (flush)
      else if ((newX - otherL).abs() < snapThreshold) {
        newX = otherL;
      }
      // c) Snap right edge to other window's left edge
      else if ((newX + windowW - (otherL - edgeSpacing)).abs() <
          snapThreshold) {
        newX = otherL - edgeSpacing - windowW;
      }
      // d) Snap right edge to other window's right edge (flush)
      else if ((newX + windowW - otherR).abs() < snapThreshold) {
        newX = otherR - windowW;
      }

      // Y-Axis Snapping:
      // a) Snap to other window's bottom edge
      if ((newY - (otherB + edgeSpacing)).abs() < snapThreshold) {
        newY = otherB + edgeSpacing;
      }
      // b) Snap to other window's top edge (flush)
      else if ((newY - otherT).abs() < snapThreshold) {
        newY = otherT;
      }
      // c) Snap bottom edge to other window's top edge
      else if ((newY + windowH - (otherT - edgeSpacing)).abs() <
          snapThreshold) {
        newY = otherT - edgeSpacing - windowH;
      }
      // d) Snap bottom edge to other window's bottom edge (flush)
      else if ((newY + windowH - otherB).abs() < snapThreshold) {
        newY = otherB - windowH;
      }
    }

    // ── 3. Clamping ──────────────────────────────────────────────────────────
    final clampedX = newX
        .clamp(0.0, max(0.0, canvasSize.width - 60))
        .toDouble();
    final maxY = max(0.0, canvasSize.height - 40);
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

    // ── 1. Right Edge Snapping ───────────────────────────────────────────────
    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;
      final otherL = other.position.dx;
      final otherR = other.position.dx + other.size.width;

      // Snap right edge to other's left edge
      if ((right - (otherL - edgeSpacing)).abs() < snapThreshold) {
        width = (otherL - edgeSpacing) - posX;
      }
      // Snap right edge to other's right edge (flush)
      else if ((right - otherR).abs() < snapThreshold) {
        width = otherR - posX;
      }
    }

    // ── 2. Bottom Edge Snapping ──────────────────────────────────────────────
    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;
      final otherT = other.position.dy;
      final otherB = other.position.dy + other.size.height;

      // Snap bottom edge to other's top edge
      if ((bottom - (otherT - edgeSpacing)).abs() < snapThreshold) {
        height = (otherT - edgeSpacing) - posY;
      }
      // Snap bottom edge to other's bottom edge (flush)
      else if ((bottom - otherB).abs() < snapThreshold) {
        height = otherB - posY;
      }
    }

    // ── 3. Left Edge Snapping ────────────────────────────────────────────────
    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;
      final otherL = other.position.dx;
      final otherR = other.position.dx + other.size.width;

      // Snap left edge to other's right edge
      if ((posX - (otherR + edgeSpacing)).abs() < snapThreshold) {
        final delta = (otherR + edgeSpacing) - posX;
        posX = otherR + edgeSpacing;
        width -= delta;
      }
      // Snap left edge to other's left edge (flush)
      else if ((posX - otherL).abs() < snapThreshold) {
        final delta = otherL - posX;
        posX = otherL;
        width -= delta;
      }
    }

    // ── 4. Top Edge Snapping ─────────────────────────────────────────────────
    for (final other in otherWindows) {
      if (other.id == activeWindowId) continue;
      final otherT = other.position.dy;
      final otherB = other.position.dy + other.size.height;

      // Snap top edge to other's bottom edge
      if ((posY - (otherB + edgeSpacing)).abs() < snapThreshold) {
        final delta = (otherB + edgeSpacing) - posY;
        posY = otherB + edgeSpacing;
        height -= delta;
      }
      // Snap top edge to other's top edge (flush)
      else if ((posY - otherT).abs() < snapThreshold) {
        final delta = otherT - posY;
        posY = otherT;
        height -= delta;
      }
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
