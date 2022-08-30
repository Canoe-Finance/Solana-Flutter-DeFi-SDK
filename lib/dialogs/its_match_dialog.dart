import 'package:dating_app/datas/user.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:dating_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ItsMatchDialog extends StatelessWidget {
  // Variables
  final GlobalKey<SwipeStackState>? swipeKey;
  final User matchedUser;
  final bool showSwipeButton;

  const ItsMatchDialog(
      {Key? key, required this.matchedUser, this.swipeKey, this.showSwipeButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Material(
      color: Colors.black.withOpacity(.55),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /// Matched User image
              CircleAvatar(
                radius: 75,
                backgroundColor: Theme.of(context).primaryColor,
                backgroundImage: NetworkImage(matchedUser.userProfilePhoto),
              ),
              const SizedBox(height: 10),

              /// Matched User first name
              Text(matchedUser.userFullname.split(" ")[0],
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Text(i18n.translate("likes_you_too"),
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Text(
                  "${i18n.translate("you_and")} "
                  "${matchedUser.userFullname.split(" ")[0]} "
                  "${i18n.translate("liked_each_other")}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 10),

              /// Send a message button
              SizedBox(
                  height: 47,
                  width: double.maxFinite,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          )
                        )
                      ),
                      child: Text(i18n.translate("send_a_message"),
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                      onPressed: () {
                        /// Close it's match dialog  first
                        Navigator.of(context).pop();

                        /// Go to chat screen
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(user: matchedUser)));
                      })),
              const SizedBox(height: 20),

              /// Keep swiping button
              if (showSwipeButton)
                SizedBox(
                  height: 45,
                  width: double.maxFinite,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(color: Colors.white)
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor, width: 2)
                          )
                        )
                      ),
                      child: Text(i18n.translate("keep_passing"),
                          style: const TextStyle(fontSize: 18)),
                      onPressed: () {
                        /// Close it's match dialog 
                        Navigator.of(context).pop();

                        /// Swipe right
                        swipeKey!.currentState!.swipeRight();
                      })),
                  

            ],
          ),
        ),
      ),
    );
  }
}
