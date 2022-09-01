import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/edit_profile_screen.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/screens/settings_screen.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class ProfileBasicInfoCard extends StatelessWidget {
  const ProfileBasicInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization
    final i18n = AppLocalizations.of(context);
    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(UserModel().user.userBirthYear,
        UserModel().user.userBirthMonth, UserModel().user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ScrollPhysics(),
      child: Card(
        color: Theme.of(context).primaryColor,
        elevation: 4.0,
        shape: defaultCardBorder(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width - 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile image
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 40,
                      backgroundImage:
                          NetworkImage(UserModel().user.userProfilePhoto),
                      onBackgroundImageError: (e, s) => { debugPrint(e.toString()) },
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// Profile details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${UserModel().user.userFullname.split(' ')[0]}, "
                        "${userAge.toString()}",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 5),

                      /// Location
                      Row(
                        children: [
                          const SvgIcon("assets/icons/location_point_icon.svg",
                              color: Colors.white),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // City
                              Text("${UserModel().user.userLocality},",
                                  style: const TextStyle(color: Colors.white)),
                              // Country
                              Text(UserModel().user.userCountry,
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                        icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                        label: Text(i18n.translate("view"),
                            style: const TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                            side: MaterialStateProperty.all<BorderSide>(
                                const BorderSide(color: Colors.white)),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ))),
                        onPressed: () {
                          /// Go to profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  user: UserModel().user, showButtons: false)));
                        }),
                  ),
                  cicleButton(
                    bgColor: APP_ACCENT_COLOR,
                    padding: 13,
                    icon: const SvgIcon("assets/icons/settings_icon.svg",
                        color: Colors.white, width: 30, height: 30),
                    onTap: () {
                      /// Go to profile settings
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                    },
                  ),
                  SizedBox(
                    height: 35,
                    child: TextButton.icon(
                        icon: Icon(Icons.edit,
                            color: Theme.of(context).primaryColor),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ))),
                        label: Text(i18n.translate("edit"),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          /// Go to edit profile screen
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const EditProfileScreen()));
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
