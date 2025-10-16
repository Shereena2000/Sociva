// import 'dart:io';

// import 'package:flutter/material.dart';

// import '../../constants/sized_box.dart';
// import 'flutter_toast.dart';

// class NoInternetWidget extends StatelessWidget {
//   const NoInternetWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.wifi_off,
//                 color: Colors.red.withOpacity(.9),
//                 size: 70,
//               ),
//               const SizeBoxH(10),
//               const Text(
//                 "Check your Internet connectivity!!!",
//                 style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               GestureDetector(
//                   onTap: () async {
//                     bool isConnected = await checking();
//                     if (isConnected) {
//                       Navigator.of(context).pop();
//                     } else {
//                       FlutterToastClass.toast(
//                         "No Internet Connection",
//                       );
//                     }
//                   },
//                   child: Icon(
//                     Icons.refresh,
//                     size: 30,
//                     color: Colors.red,
//                   ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   //internet checking
//   Future<bool> checking() async {
//     try {
//       final result = await InternetAddress.lookup('www.google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return true;
//       } else {
//         FlutterToastClass.toast("Please enable internet");
//         return false;
//       }
//     } on SocketException catch (_) {
//       FlutterToastClass.toast("Please enable internet");
//       return false;
//     }
//   }
// }
