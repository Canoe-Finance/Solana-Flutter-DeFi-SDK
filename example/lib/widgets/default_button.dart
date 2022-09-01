import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  // Variables
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const DefaultButton(
      {Key? key, required this.child, required this.onPressed, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 45,
      child: ElevatedButton(
        child: child,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(color: Colors.white)
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            )
          )
        ),
        onPressed: onPressed,
      ),
    );
  }
}
