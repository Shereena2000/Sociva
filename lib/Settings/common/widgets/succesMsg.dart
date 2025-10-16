import 'package:flutter/material.dart';

class SuccessMsg {
  static Future showmsg(
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
              borderRadius: BorderRadius.all(Radius.circular(6.0))),
          elevation: 0,
          title: Text(title),
          content: Text(msg),
          actions: actions,
        );
      },
    );
  }
}

class SingleSuccessMsg {
  static Future showmsg(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0))),
          title: Text(title),
          actions: actions,
        );
      },
    );
  }
}
