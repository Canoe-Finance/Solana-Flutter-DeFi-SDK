import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  // Variable
  final double? width;
  final double? height;

  const AppLogo({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset("assets/images/app_logo.png",
            width: width ?? 120, height: height ?? 120));
  }
}
