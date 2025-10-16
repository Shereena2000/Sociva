import 'package:flutter/material.dart';
import '../../utils/p_colors.dart'; // adjust path
import '../../utils/p_text_styles.dart'; // if you want to style text

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
 final List<Widget>?actions;

  const CustomAppBar({super.key, required this.title,  this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: PTextStyles.displaySmall.copyWith(color: Colors.white),
      ),
      backgroundColor: PColors.primaryColor,
      elevation: 4,
      centerTitle: false, // optional
      actions: actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
