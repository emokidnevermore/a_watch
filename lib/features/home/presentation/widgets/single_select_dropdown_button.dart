import 'package:flutter/material.dart';

class SingleSelectDropdownButton extends StatefulWidget {
  final String hint;
  final String? selectedValue;
  final List<DropdownMenuItem<String>> allItems;
  final ValueChanged<String?> onChanged;

  const SingleSelectDropdownButton({
    super.key,
    required this.hint,
    required this.selectedValue,
    required this.allItems,
    required this.onChanged,
  });

  @override
  State<SingleSelectDropdownButton> createState() => _SingleSelectDropdownButtonState();
}

class _SingleSelectDropdownButtonState extends State<SingleSelectDropdownButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _hideOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
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
                        children: widget.allItems.map((item) {
                          final isSelected = widget.selectedValue == item.value;
                          return InkWell(
                            onTap: () {
                              widget.onChanged(item.value);
                              _hideOverlay();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                child: item.child,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _getDisplayText() {
    if (widget.selectedValue == null) return widget.hint;
    final selectedItem = widget.allItems.firstWhere(
      (item) => item.value == widget.selectedValue,
      orElse: () => DropdownMenuItem(child: Text(widget.selectedValue ?? '')),
    );
    if (selectedItem.child is Text) {
      return (selectedItem.child as Text).data ?? widget.hint;
    }
    return widget.hint;
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
          child: Text(_getDisplayText(), overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
