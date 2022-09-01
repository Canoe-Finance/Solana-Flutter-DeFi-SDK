import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/main.dart';
import 'package:flutter/material.dart';

void showScaffoldMessage({
  BuildContext? context, // removed
  required String message,
  Color? bgcolor,
  Duration? duration,
}) {
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
    content: Text(message, style: const TextStyle(fontSize: 18)),
    duration: duration ?? const Duration(seconds: 5),
    backgroundColor: bgcolor ?? APP_PRIMARY_COLOR,
  ));
}
