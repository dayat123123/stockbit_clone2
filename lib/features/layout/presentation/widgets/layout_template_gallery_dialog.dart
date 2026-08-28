import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';

/// Modal dialog showing the Layout Template Gallery (matching Stockbit Pro Desktop reference design).
class LayoutTemplateGalleryDialog extends StatefulWidget {
  final Size canvasSize;

  const LayoutTemplateGalleryDialog({super.key, required this.canvasSize});

  static Future<void> show(BuildContext context, Size canvasSize) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => BlocProvider.value(
        value: context.read<WorkspaceBloc>(),
        child: LayoutTemplateGalleryDialog(canvasSize: canvasSize),
      ),
    );
  }

  @override
  State<LayoutTemplateGalleryDialog> createState() =>
      _LayoutTemplateGalleryDialogState();
}

class _LayoutTemplateGalleryDialogState
    extends State<LayoutTemplateGalleryDialog> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Template', 'Saved'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        width: 1040,
        height: 620,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppColors.windowShadow,
        ),
        child: Column(
          children: [
            // ── 1. Dialog Header (Categories Tabs + Close) ─────────────────
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.headerBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  // Category Tabs (All, Template, Saved)
                  ..._categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final title = entry.value;
                    final isSelected = index == _selectedCategoryIndex;

                    return InkWell(
                      onTap: () =>
                          setState(() => _selectedCategoryIndex = index),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),

                  // Close Dialog Button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── 2. Templates Grid Gallery ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 20,
                  children: [
                    // + New Layout Card
                    _buildNewLayoutCard(context),

                    // Predefined Template Cards
                    ...WorkspaceLayoutTemplate.values
                        .where((t) => t != WorkspaceLayoutTemplate.newLayout)
                        .map((tpl) => _buildTemplateCard(context, tpl)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewLayoutCard(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<WorkspaceBloc>().add(
          CreateTemplateLayoutEvent(
            template: WorkspaceLayoutTemplate.newLayout,
            canvasSize: widget.canvasSize,
          ),
        );
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Placeholder
            Container(
              height: 126,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                ),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 26,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'New Layout',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Add widgets and customize your way.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WorkspaceLayoutTemplate template,
  ) {
    return InkWell(
      onTap: () {
        context.read<WorkspaceBloc>().add(
          CreateTemplateLayoutEvent(
            template: template,
            canvasSize: widget.canvasSize,
          ),
        );
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stylized Mini Preview Mockup
            Container(
              height: 126,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.canvasBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: _buildMiniTemplatePreview(template),
            ),

            // Text Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          template.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgePurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Template',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.badgePurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTemplatePreview(WorkspaceLayoutTemplate template) {
    switch (template) {
      case WorkspaceLayoutTemplate.multiOrderbook:
        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(6, (i) => _miniOrderbookBox()),
        );

      case WorkspaceLayoutTemplate.multiChart:
        return Row(
          children: [
            Expanded(child: _miniChartBox()),
            const SizedBox(width: 4),
            Expanded(child: _miniChartBox()),
          ],
        );

      case WorkspaceLayoutTemplate.classic:
        return Row(
          children: [
            Container(width: 40, color: AppColors.sidebarBg),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _miniChartBox()),
                  const SizedBox(height: 3),
                  Expanded(child: _miniOrderbookBox()),
                ],
              ),
            ),
          ],
        );

      case WorkspaceLayoutTemplate.multiStock:
      case WorkspaceLayoutTemplate.singleStock:
      case WorkspaceLayoutTemplate.fastOrder:
      default:
        return Row(
          children: [
            Expanded(child: _miniOrderbookBox()),
            const SizedBox(width: 4),
            Expanded(child: _miniChartBox()),
          ],
        );
    }
  }

  Widget _miniOrderbookBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 16, height: 3, color: AppColors.bidGreen),
              Container(width: 16, height: 3, color: AppColors.offerRed),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 12,
                height: 3,
                color: AppColors.bidGreen.withValues(alpha: 0.6),
              ),
              Container(
                width: 14,
                height: 3,
                color: AppColors.offerRed.withValues(alpha: 0.6),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 18,
                height: 3,
                color: AppColors.bidGreen.withValues(alpha: 0.4),
              ),
              Container(
                width: 10,
                height: 3,
                color: AppColors.offerRed.withValues(alpha: 0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniChartBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(width: 3, height: 18, color: AppColors.bidGreen),
          Container(width: 3, height: 32, color: AppColors.bidGreen),
          Container(width: 3, height: 24, color: AppColors.offerRed),
          Container(width: 3, height: 42, color: AppColors.bidGreen),
          Container(width: 3, height: 28, color: AppColors.offerRed),
          Container(width: 3, height: 36, color: AppColors.bidGreen),
        ],
      ),
    );
  }
}
