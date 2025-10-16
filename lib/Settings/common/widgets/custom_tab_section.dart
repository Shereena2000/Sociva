// import 'package:buttons_tabbar/buttons_tabbar.dart';
// import 'package:flutter/material.dart';

// import '../../constants/text_styles.dart';
// import '../../utils/p_colors.dart';

// class CustomTabSection extends StatelessWidget {
//   final List<String> tabTitles;
//   final List<Widget> tabContents;
// final double? fontSize;
// final double contentHPadding;
//   const CustomTabSection({
//     super.key,
//     required this.tabTitles,
//     required this.tabContents, this.contentHPadding=30, this.fontSize,

//   }) : assert(
//          tabTitles.length == tabContents.length,
//          "Tabs and contents must be the same length",
//        );

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: tabTitles.length,
//       child: Column(
//         children: [
//           ButtonsTabBar(
//             backgroundColor: PColors.primaryColor,
//             unselectedBackgroundColor: Colors.white,
//             unselectedLabelStyle: getTextStyle(
//               color: PColors.darkGray,
//               fontSize:fontSize?? 14,
//             ),
//             labelStyle: getTextStyle(color: Colors.white, fontSize:fontSize?? 14),
//             borderWidth: 1.5,
//             borderColor: PColors.primaryColor,
//             radius: 30,

//             contentPadding:   EdgeInsets.symmetric(horizontal: contentHPadding),
//             tabs: tabTitles.map((title) => Tab(text: title)).toList(),
//           ),
//           Expanded(child: TabBarView(children: tabContents),),
//         ],
//       ),
//     );
//   }
// }
