import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class BuildTitle extends StatelessWidget {
  final String? svgIconName;
  final String title;

  const BuildTitle({Key? key, this.svgIconName, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Title
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Display SVG icon
          if (svgIconName != null) 
          SvgIcon("assets/icons/$svgIconName.svg",
              color: Theme.of(context).primaryColor, width: 30, height: 30),
  
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title,
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
