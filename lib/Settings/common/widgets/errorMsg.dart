import 'package:flutter/material.dart';

class ErrorMsg {
  static showSnakError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  static Future showPopUpError(
    BuildContext context, {
    required String title,
    required String msg,
    List<Widget>? actions,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
          title: Text(title),
          content: Text(msg),
          actions: actions,
        );
      },
    );
  }
}
