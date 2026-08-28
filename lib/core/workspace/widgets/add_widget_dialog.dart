import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';

/// Modal dialog shown when clicking "Add Window" / "Add Widget" on the top header.
/// Allows selecting the [WorkspaceWidgetType] and entering/picking an initial symbol.
class AddWidgetDialog extends StatefulWidget {
  final Size canvasSize;

  const AddWidgetDialog({super.key, required this.canvasSize});

  static Future<void> show(BuildContext context, Size canvasSize) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AddWidgetDialog(canvasSize: canvasSize),
    );
  }

  @override
  State<AddWidgetDialog> createState() => _AddWidgetDialogState();
}

class _AddWidgetDialogState extends State<AddWidgetDialog> {
  WorkspaceWidgetType _selectedType = WorkspaceWidgetType.orderbook;
  final TextEditingController _symbolController = TextEditingController(
    text: 'BBCA',
  );

  final List<String> _popularSymbols = [
    'BBCA',
    'BBRI',
    'BMRI',
    'TLKM',
    'ASII',
    'BBNI',
    'UNTR',
    'GGRM',
  ];

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.add_to_photos_outlined,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add New Window Panel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),

            // Select Widget Type
            const Text(
              'SELECT WIDGET TYPE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.2,
              physics: const NeverScrollableScrollPhysics(),
              children: WorkspaceWidgetType.values.map((type) {
                final isSelected = _selectedType == type;
                return InkWell(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.color.withValues(alpha: 0.16)
                          : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? type.color : AppColors.border,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(type.icon, size: 20, color: type.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                type.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Symbol Selection (if applicable)
            if (_selectedType.requiresSymbol) ...[
              const Text(
                'TARGET STOCK SYMBOL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _symbolController,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'e.g. BBCA, BBRI, BMRI...',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _popularSymbols.map((sym) {
                  return InkWell(
                    onTap: () => setState(() => _symbolController.text = sym),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _symbolController.text == sym
                            ? AppColors.badgeBlue.withValues(alpha: 0.25)
                            : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: _symbolController.text == sym
                              ? AppColors.badgeBlue
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        sym,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _symbolController.text == sym
                              ? AppColors.badgeBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    final sym = _symbolController.text.trim().toUpperCase();
                    context.read<WorkspaceBloc>().add(
                      AddNewWindowToWorkspaceEvent(
                        type: _selectedType,
                        symbol: sym.isNotEmpty ? sym : 'BBCA',
                        canvasSize: widget.canvasSize,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    'Add to Workspace',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
