import 'package:flutter/material.dart';

class CustomPopupSelector<T> extends StatefulWidget {
  final T? selectedValue;
  final List<T> options;
  final String Function(T) displayText;
  final void Function(T) onSelected;

  final double borderRadius;
  final double height;
  final Color borderColor;
  final Color backgroundColor;
  final String hintText;
  final TextStyle? textStyle;

  const CustomPopupSelector({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.displayText,
    required this.onSelected,
    this.borderRadius = 8.0,
    this.height = 50.0,
    this.borderColor = Colors.green,
    this.backgroundColor = Colors.white,
    this.hintText = 'Select',
    this.textStyle,
  });

  @override
  State<CustomPopupSelector<T>> createState() => _CustomPopupSelectorState<T>();
}

class _CustomPopupSelectorState<T> extends State<CustomPopupSelector<T>> {
  final GlobalKey _key = GlobalKey();
  double _buttonWidth = 0;
  bool _isOpen = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _setWidth());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color: _isOpen ? widget.borderColor : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: PopupMenuButton<T>(
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        onOpened: () => setState(() => _isOpen = true),
        onCanceled: () => setState(() => _isOpen = false),
        onSelected: (val) {
          widget.onSelected(val);
          setState(() => _isOpen = false);
        },
        constraints: BoxConstraints(
          minWidth: _buttonWidth,
          maxWidth: _buttonWidth,
        ),
        itemBuilder: (context) => widget.options
            .map((item) => PopupMenuItem<T>(
                  value: item,
                  child: Text(widget.displayText(item)),
                ))
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selectedValue != null
                    ? widget.displayText(widget.selectedValue as T)
                    : widget.hintText,
                style: widget.textStyle ??
                    TextStyle(
                      color: widget.selectedValue == null
                          ? Colors.grey
                          : Colors.black,
                    ),
              ),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isOpen ? 0.5 : 0.0,
                child: const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//** Usage */
// Consumer<RootAddressViewModel>(
//                   builder: (context, model, _) {
//                     return CustomPopupSelector<String>(
//                       backgroundColor: PColors.black.withOpacity(0.06),
//                       selectedValue: model.selectedSlot,
//                       options: const ['Morning', 'Evening'],
//                       displayText: (slot) => slot,
//                       onSelected: (val) {
//                         model.updateSelectedSlot(val);
//                       },
//                       borderColor: PColors.seed,
//                       hintText: "Select slot",
//                     );
//                   },
//                 ),
