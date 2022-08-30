import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:flutter/material.dart';

class ShowLikeOrDislike extends StatelessWidget {
  // Variables
  final SwiperPosition position;

  const ShowLikeOrDislike({Key? key, required this.position}) : super(key: key);

  Widget _likedUser() {
    return Positioned(
      top: 50,
      left: 20,
      child: RotationTransition(
        turns: const AlwaysStoppedAnimation(-15 / 360),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('LIKE',
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.green,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _dislikedUser() {
    return Positioned(
      top: 50,
      right: 20,
      child: RotationTransition(
        turns: const AlwaysStoppedAnimation(15 / 360),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('DISLIKE',
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Positioned(child: Container());

    /// Control swipe position
    switch (position) {
      case SwiperPosition.None:
        break;
      case SwiperPosition.Left:
        content = _dislikedUser();
        break;
      case SwiperPosition.Right:
        content = _likedUser();
        break;
    }
    return content;
  }
}
