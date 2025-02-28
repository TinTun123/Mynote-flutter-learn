import 'package:flutter/material.dart';

Future<void> showErrorDialog (BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            }, 
            child: const Text("Close"))
        ],
      );
    }
  );
}