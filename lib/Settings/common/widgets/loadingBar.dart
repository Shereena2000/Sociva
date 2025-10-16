// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';

// import '../../utils/p_colors.dart';

// class LoadingBar {
//   static Widget buttonLoad() =>
//       SpinKitWaveSpinner(color: PColors.colorFFFFFF, size: 40);

//   static Widget loading() {
//     return SpinKitWave(
//       size: 30,
//       color: PColors.primaryColor,
//     );
//   }

//   static popUpLoadingBar(BuildContext context) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           elevation: 0,
//           backgroundColor: Colors.white.withOpacity(0),
//           title: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SpinKitFadingCube(
//                 size: 20,
//                 color: Colors.white,
//               ),
//               SizedBox(width: 40),
//               //sconst Text("Loading...")
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static offPopLoadingBar(BuildContext context) {
//     Navigator.pop(context);
//   }
// }

// class LoadingWidget extends StatelessWidget {
//   const LoadingWidget({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.center,
//       child: SizedBox(
//         height: 25,
//         width: 25,
//         child: CircularProgressIndicator(
//           color: PColors.primaryColor,
//         ),
//       ),
//     );
//   }
// }
