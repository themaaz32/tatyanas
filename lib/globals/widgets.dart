import 'package:flutter/material.dart';

class AppWidgets {
  static Future<bool> confirm(context, String confirmMessage) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text(confirmMessage),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("YES"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("NO"),
            )
          ],
        );
      },
    );
  }
}
