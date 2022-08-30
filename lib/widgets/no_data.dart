import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  // Variables
  final String? svgName;
  final Widget? icon;
  final String text;

  const NoData(
      {Key? key, 
      this.svgName,
      this.icon,
      required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle icon
    late Widget _icon;
    // Check svgName
    if (svgName != null) {
        // Get SVG icon
        _icon = SvgIcon("assets/icons/$svgName.svg",
            width: 100, height: 100, color: Theme.of(context).primaryColor);
    } else {
      _icon = icon!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Show icon
          _icon,
          Text(text,
              style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
