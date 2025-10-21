import 'package:flutter/material.dart';
import '../../utils/p_text_styles.dart'; // if you want to style text

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
 final List<Widget>?actions;

  const CustomAppBar({super.key, required this.title,  this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(icon:  Icon(Icons.arrow_back_ios_new_outlined,size: 20,),onPressed: (){Navigator.pop(context);},),
      title: Text(
        title,
        style: PTextStyles.headlineMedium.copyWith(color: Colors.white),
      ),
      elevation: 0,
      centerTitle: true, // optional
      actions: actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
