import 'package:flutter/material.dart';

class UsersGrid extends StatelessWidget {
  // Variables
  final ScrollController? gridViewController;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const UsersGrid(
      {Key? key, 
      this.gridViewController,
      required this.itemCount,
      required this.itemBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: gridViewController,
      shrinkWrap: true,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 250 / 320,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
