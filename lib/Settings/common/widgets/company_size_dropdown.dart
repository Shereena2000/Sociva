import 'package:flutter/material.dart';
import '../../constants/text_styles.dart';
import '../../utils/p_colors.dart';

class CompanySizeDropdown extends StatefulWidget {
  final String? value;
  final Function(String?) onChanged;
  final String? textHead;
  final String hintText;

  const CompanySizeDropdown({
    super.key,
    this.value,
    required this.onChanged,
    this.textHead,
    this.hintText = "Select Company Size",
  });

  @override
  State<CompanySizeDropdown> createState() => _CompanySizeDropdownState();
}

class _CompanySizeDropdownState extends State<CompanySizeDropdown> {
  final List<String> _companySizes = [
    "1-10 employees",
    "11-50 employees", 
    "51-200 employees",
    "201-500 employees",
    "501-1000 employees",
    "1001-5000 employees",
    "5000+ employees",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.textHead != null) ...[
          Text(
            widget.textHead!,
            style: getTextStyle(
              fontSize: 14,
              color: PColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: PColors.white, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: widget.value?.isNotEmpty == true ? widget.value : null,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              hintText: widget.hintText,
              hintStyle: getTextStyle(
                fontSize: 13,
                color: PColors.lightGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            dropdownColor: PColors.darkGray,
            style: getTextStyle(
              fontSize: 13,
              color: PColors.white,
              fontWeight: FontWeight.w400,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: PColors.white,
            ),
            items: _companySizes.map((String size) {
              return DropdownMenuItem<String>(
                value: size,
                child: Text(
                  size,
                  style: getTextStyle(
                    fontSize: 13,
                    color: PColors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
