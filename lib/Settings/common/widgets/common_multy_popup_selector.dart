import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class MultiSelectPopupSelector<T> extends StatefulWidget {
  final List<T> selectedValues;
  final List<T> options;
  final String Function(T) displayText;
  final void Function(List<T>) onSelectionChanged;
  final double borderRadius;
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  final String hintText;
  final TextStyle? textStyle;
  final Color? arrowDropDownColor;
  final bool readOnly;
  // For MainCategory objects, specify which property to use for comparison
  final dynamic Function(T)? getItemId;

  const MultiSelectPopupSelector({
    super.key,
    required this.selectedValues,
    required this.options,
    required this.displayText,
    required this.onSelectionChanged,
    this.borderRadius = 8.0,
    this.height = 50.0,
    this.borderColor = Colors.red,
    this.backgroundColor = Colors.white,
    this.hintText = 'Select',
    this.textStyle,
    this.arrowDropDownColor,
    this.readOnly = false,
    this.getItemId,
  });

  @override
  State<MultiSelectPopupSelector<T>> createState() =>
      _MultiSelectPopupSelectorState<T>();
}

class _MultiSelectPopupSelectorState<T>
    extends State<MultiSelectPopupSelector<T>> {
  final GlobalKey _key = GlobalKey();
  double _buttonWidth = 0;
  bool _isOpen = false;
  late List<T> _selectedItems;

  void _setWidth() {
    final RenderBox? box =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      setState(() => _buttonWidth = box.size.width);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedValues);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setWidth());

    // Debug: Log the initial selected items
    developer.log(
        'Initial selected items: ${_selectedItems.map((e) => widget.displayText(e)).join(', ')}');
  }

  @override
  void didUpdateWidget(MultiSelectPopupSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Always synchronize with external selectedValues
    _selectedItems = List.from(widget.selectedValues);

    // Debug: Log when selected values are updated
    developer.log(
        'Updated selected items: ${_selectedItems.map((e) => widget.displayText(e)).join(', ')}');
  }

  // Check if two items should be considered equal
  bool _areItemsEqual(T item1, T item2) {
    // If getItemId is provided, use it for comparison
    if (widget.getItemId != null) {
      final id1 = widget.getItemId!(item1);
      final id2 = widget.getItemId!(item2);
      return id1 == id2;
    }

    // Default comparison
    return item1 == item2;
  }

  // Check if an item exists in the selected items list
  bool _isItemSelected(T item) {
    for (var selectedItem in _selectedItems) {
      if (_areItemsEqual(item, selectedItem)) {
        return true;
      }
    }
    return false;
  }

  void _toggleSelection(T item) {
    setState(() {
      if (_isItemSelected(item)) {
        _selectedItems.removeWhere((element) => _areItemsEqual(element, item));
      } else {
        _selectedItems.add(item);
      }
    });
    widget.onSelectionChanged(_selectedItems);

    // Debug: Log when selection changes
    developer.log(
        'Selection changed: ${_selectedItems.map((e) => widget.displayText(e)).join(', ')}');
  }

  String _getDisplayText() {
    if (_selectedItems.isEmpty) {
      return widget.hintText;
    }
    return _selectedItems.map(widget.displayText).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Log during build
    developer
        .log('Building dropdown with ${_selectedItems.length} selected items');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: _key,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color: widget.borderColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.readOnly
                  ? null
                  : () {
                      setState(() {
                        _isOpen = !_isOpen;
                      });
                    },
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getDisplayText(),
                        style: widget.textStyle ??
                            TextStyle(
                              color: _selectedItems.isEmpty
                                  ? Colors.grey.shade900
                                  : Colors.black,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!widget.readOnly)
                      Icon(
                        Icons.arrow_drop_down,
                        color: widget.arrowDropDownColor ?? Colors.black,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isOpen && !widget.readOnly)
          Container(
            width: _buttonWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.options.map((item) {
                  final bool isSelected = _isItemSelected(item);

                  // Debug log for each item
                  developer.log(
                      'Item: ${widget.displayText(item)}, selected: $isSelected');

                  return InkWell(
                    onTap: () => _toggleSelection(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(item),
                            activeColor: Colors.orange,
                          ),
                          Expanded(
                            child: Text(
                              widget.displayText(item),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
