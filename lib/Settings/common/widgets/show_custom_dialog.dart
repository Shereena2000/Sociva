import 'package:flutter/material.dart';

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  String confirmText = "OK",
  String cancelText = "Cancel",
  
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        ElevatedButton(
         
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            onConfirm(); // Run confirm action
          },
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
