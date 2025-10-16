import 'package:flutter/material.dart';

import '../../constants/text_styles.dart';

class ErrorPage extends StatelessWidget {
  final String errorMsg;
  final String? errorMsgTitle;
  const ErrorPage({super.key, required this.errorMsg, this.errorMsgTitle});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 35),
            const SizedBox(height: 15),
            SizedBox(
              width: size.width / 1.3,
              child: Text(
                errorMsg ==
                        "Please check your internet connection and try again."
                    ? 'No Internet Connection'
                    : errorMsgTitle ?? '',
                textAlign: TextAlign.center,
                style: getTextStyle(fontWeight: FontWeight.w500, fontSize: 26),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: size.width / 1.5,
              child: Text(
                errorMsg,
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontWeight: FontWeight.w500,
                  // fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
