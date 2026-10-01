import 'package:flutter/material.dart';

import 'app_geometry.dart';

/// Shared horizontally scrollable segmented selector.
///
/// Guarantees:
/// - labels use intrinsic width and are never intentionally truncated
/// - narrow viewports scroll horizontally rather than compressing labels
/// - selected/unselected state is supplied by one integer index
/// - the selected capsule is automatically kept visible when selection changes
/// - optional icons and accessibility semantics remain centrally owned
/// - geometry is owned by [AppGeometry]
abstract final class AppHorizontalSelectorBehavior {
  static const ScrollPhysics physics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );
}

class AppSegmentedSelector extends StatefulWidget {
  const AppSegmentedSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.icons,
    this.emphasizedIndices = const <int>{},
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<IconData?>? icons;
  final Set<int> emphasizedIndices;

  @override
  State<AppSegmentedSelector> createState() => _AppSegmentedSelectorState();
}

class _AppSegmentedSelectorState extends State<AppSegmentedSelector> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = _createItemKeys();
    _scheduleSelectedVisibility();
  }

  @override
  void didUpdateWidget(covariant AppSegmentedSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.labels.length != widget.labels.length) {
      _itemKeys = _createItemKeys();
    }

    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.labels.length != widget.labels.length) {
      _scheduleSelectedVisibility();
    }
  }

  List<GlobalKey> _createItemKeys() =>
      List<GlobalKey>.generate(widget.labels.length, (_) => GlobalKey());

  void _scheduleSelectedVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_scrollController.hasClients ||
          widget.selectedIndex < 0 ||
          widget.selectedIndex >= _itemKeys.length) {
        return;
      }

      final itemContext = _itemKeys[widget.selectedIndex].currentContext;
      final viewportContext = _viewportKey.currentContext;
      if (itemContext == null || viewportContext == null) {
        return;
      }

      final itemBox = itemContext.findRenderObject();
      final viewportBox = viewportContext.findRenderObject();
      if (itemBox is! RenderBox || viewportBox is! RenderBox) {
        return;
      }

      final itemLeft = itemBox
          .localToGlobal(Offset.zero, ancestor: viewportBox)
          .dx;
      final itemRight = itemLeft + itemBox.size.width;
      final viewportWidth = viewportBox.size.width;

      double? target;

      if (itemLeft < 0) {
        target = _scrollController.offset + itemLeft;
      } else if (itemRight > viewportWidth) {
        target = _scrollController.offset + (itemRight - viewportWidth);
      }

      if (target == null) {
        return;
      }

      final position = _scrollController.position;
      final boundedTarget = target
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();

      if ((boundedTarget - _scrollController.offset).abs() < 0.5) {
        return;
      }

      _scrollController.animateTo(
        boundedTarget,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.icons == null || widget.icons!.length == widget.labels.length,
      'icons must be null or match labels length',
    );

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      key: _viewportKey,
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: AppHorizontalSelectorBehavior.physics,
      child: Row(
        children: List.generate(widget.labels.length, (index) {
          final selected = index == widget.selectedIndex;
          final emphasized = widget.emphasizedIndices.contains(index);
          final icon = widget.icons == null ? null : widget.icons![index];

          return Padding(
            key: _itemKeys[index],
            padding: EdgeInsets.only(
              right: index == widget.labels.length - 1 ? 0 : 8,
            ),
            child: Semantics(
              button: true,
              selected: selected,
              label: widget.labels[index],
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppGeometry.radiusSm),
                onTap: () => widget.onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppGeometry.radiusSm),
                    border: Border.all(
                      color: selected
                          ? scheme.primary
                          : scheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 16,
                          color: selected
                              ? scheme.onPrimary
                              : emphasized
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.labels[index],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: selected
                              ? scheme.onPrimary
                              : emphasized
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          fontWeight: selected || emphasized
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
