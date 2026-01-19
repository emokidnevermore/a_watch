import 'package:flutter/material.dart';

class MultiSelectDropdownButton extends StatefulWidget {
  final String hint;
  final String displayText;
  final List<String> selectedValues;
  final List<String> allOptions;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectDropdownButton({
    super.key,
    required this.hint,
    required this.displayText,
    required this.selectedValues,
    required this.allOptions,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdownButton> createState() => _MultiSelectDropdownButtonState();
}

class _MultiSelectDropdownButtonState extends State<MultiSelectDropdownButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(MultiSelectDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update overlay when selectedValues change - defer to avoid build phase issues
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    // Get the button's width for proper sizing
    final renderBox = context.findRenderObject() as RenderBox?;
    final buttonWidth = renderBox?.size.width ?? 200;

    _overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: _hideOverlay,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 0), // Position right below the button
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: buttonWidth, // Match the button's width
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Select All/None option
                            InkWell(
                              onTap: () {
                                final newValues = widget.selectedValues.length == widget.allOptions.length
                                    ? <String>[]
                                    : List<String>.from(widget.allOptions);
                                widget.onChanged(newValues);
                                // Don't hide overlay so user can continue selecting
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: widget.selectedValues.length == widget.allOptions.length
                                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                                      : null,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  widget.selectedValues.length == widget.allOptions.length
                                      ? 'Снять все'
                                      : 'Выбрать все',
                                  style: TextStyle(
                                    color: widget.selectedValues.length == widget.allOptions.length
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            // Individual options
                            ...widget.allOptions.map((option) {
                              final isSelected = widget.selectedValues.contains(option);
                              return InkWell(
                                onTap: () {
                                  final newSelected = List<String>.from(widget.selectedValues);
                                  if (isSelected) {
                                    newSelected.remove(option);
                                  } else {
                                    newSelected.add(option);
                                  }
                                  widget.onChanged(newSelected);
                                  // Don't hide overlay so user can continue selecting
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                                        : null,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: () {
          if (_overlayEntry == null) {
            _showOverlay();
          } else {
            _hideOverlay();
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: widget.hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(widget.displayText, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
