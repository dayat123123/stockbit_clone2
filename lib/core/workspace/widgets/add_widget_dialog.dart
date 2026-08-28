import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';

/// A dialog that shows all available [WindowWidgetType] options.
/// The user taps one to add a new window of that type to the workspace.
class AddWidgetDialog extends StatelessWidget {
  final void Function(WindowWidgetType type) onSelected;

  const AddWidgetDialog({super.key, required this.onSelected});

  /// Convenience method to show the dialog.
  static Future<WindowWidgetType?> show(BuildContext context) {
    return showDialog<WindowWidgetType>(
      context: context,
      builder: (_) => AddWidgetDialog(
        onSelected: (type) => Navigator.of(context).pop(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.add_circle_outline,
                      size: 20, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Widget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih widget yang ingin ditambahkan ke workspace',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Grid of widget types
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: WindowWidgetType.values.map((type) {
                  final isAvailable =
                      type == WindowWidgetType.orderbook;

                  return InkWell(
                    onTap: () => onSelected(type),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 110,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAvailable
                              ? AppColors.primaryGreen.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            type.icon,
                            size: 28,
                            color: isAvailable
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            type.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (!isAvailable) ...[
                            const SizedBox(height: 2),
                            const Text(
                              'Coming Soon',
                              style: TextStyle(
                                fontSize: 8,
                                color: AppColors.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
