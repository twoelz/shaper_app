import 'package:flutter/material.dart';
import 'package:shaper_app/main.dart';

// generic OK button (for Alerts)
Widget genericOkButton = TextButton(
  child: Text("OK"),
  onPressed: () {
    navigatorKey.currentState.pop();
    // Navigator.of(navigatorKey.currentContext).pop(); // dismiss dialog
  },
);
