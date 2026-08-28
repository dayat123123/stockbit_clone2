/// Defines the canvas layout behavior for a workspace tab.
enum LayoutMode {
  /// 1-screen fixed viewport (non-scrollable), best for multi-monitor / terminal layouts.
  fixed(
    label: 'Fixed Full-Screen',
    shortLabel: 'Fixed',
  ),

  /// Vertically scrollable grid, allows unlimited rows of widgets.
  scrollable(
    label: 'Scrollable Grid',
    shortLabel: 'Scroll',
  );

  final String label;
  final String shortLabel;

  const LayoutMode({
    required this.label,
    required this.shortLabel,
  });
}
