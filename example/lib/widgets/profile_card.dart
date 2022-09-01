
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/report_dialog.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/swipe_stack/swipe_stack.dart';
import 'package:dating_app/widgets/badge.dart';
import 'package:dating_app/widgets/default_card_border.dart';
import 'package:dating_app/widgets/show_like_or_dislike.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/helpers/app_helper.dart';

class ProfileCard extends StatelessWidget {
  /// User object
  final User user;

  /// Screen to be checked
  final String? page;

  /// Swiper position
  final SwiperPosition? position;

  ProfileCard({Key? key, this.page, this.position, required this.user})
      : super(key: key);

  // Local variables
  final AppHelper _appHelper = AppHelper();

  @override
  Widget build(BuildContext context) {
    // Variables
    final bool requireVip =
        page == 'require_vip' && !UserModel().userIsVip;
    late ImageProvider userPhoto;
    // Check user vip status
    if (requireVip) {
       userPhoto = const AssetImage('assets/images/crow_badge.png');
    } else {
       userPhoto = NetworkImage(user.userProfilePhoto);
    }

    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(
        UserModel().user.userBirthYear,
        UserModel().user.userBirthMonth, 
        UserModel().user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    // Build profile card
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.all(9.0),
      child: Stack(
        children: [
          /// User Card
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            margin: const EdgeInsets.all(0),
            shape: defaultCardBorder(),
            child: Container(
              decoration: BoxDecoration(
                /// User profile image
                image: DecorationImage(
                    /// Show VIP icon if user is not vip member
                    image: userPhoto,
                    fit: requireVip ? BoxFit.contain : BoxFit.cover),
              ),
              child: Container(
                /// BoxDecoration to make user info visible
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Colors.transparent
                      ]),
                ),

                /// User info container
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User fullname
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user.userFullname}, '
                              '${userAge.toString()}',
                              style: TextStyle(
                                  fontSize: page == 'discover' ? 20 : 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8.0),

                      // User location
                      Row(
                        children: [
                          // Icon
                          const SvgIcon(
                            "assets/icons/location_point_icon.svg",
                            color: Color(0xffFFFFFF), width: 24, height: 24),

                         const SizedBox(width: 5),

                          // Locality & Country
                          Expanded(
                            child: Text(
                              "${user.userLocality}, ${user.userCountry}",
                              style: const TextStyle(
                                color: Colors.white, fontSize: 16,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      /// User education
                      
                      // Note: Uncoment the code below if you want to show the education

                      // Row(
                      //   children: [
                      //     const SvgIcon("assets/icons/university_icon.svg",
                      //         color: Colors.white, width: 20, height: 20),
                      //     const SizedBox(width: 5),
                      //     Expanded(
                      //       child: Text(
                      //         user.userSchool,
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //         ),
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // const SizedBox(height: 3),

                      // User job title
                      // Note: Uncoment the code below if you want to show the job title

                      // Row(
                      //   children: [
                      //     const SvgIcon("assets/icons/job_bag_icon.svg",
                      //         color: Colors.white, width: 17, height: 17),
                      //     const SizedBox(width: 5),
                      //     Expanded(
                      //       child: Text(
                      //         user.userJobTitle,
                      //         style: const TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //         ),
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      page == 'discover'
                          ? const SizedBox(height: 70)
                          : const SizedBox(width: 0, height: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Show location distance
          Positioned(
            top: 10,
            left: page == 'discover' ? 8 : 5,
            child: Badge(
                icon: page == 'discover'
                    ? const SvgIcon("assets/icons/location_point_icon.svg",
                        color: Colors.white, width: 15, height: 15)
                    : null,
                text:
                    '${_appHelper.getDistanceBetweenUsers(userLat: user.userGeoPoint.latitude, userLong: user.userGeoPoint.longitude)}km'),
          ),

          /// Show Like or Dislike
          page == 'discover'
              ? ShowLikeOrDislike(position: position!)
              : const SizedBox(width: 0, height: 0),

          /// Show message icon
          page == 'matches'
              ? Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SvgIcon("assets/icons/message_icon.svg",
                          color: Colors.white, width: 30, height: 30)),
                )
              : const SizedBox(width: 0, height: 0),

          // Show Report/Block profile button
          page == 'discover'
            ? Positioned(
                right: 0,
                child: IconButton(
                    icon: Icon(Icons.flag,
                        color: Theme.of(context).primaryColor, size: 32),
                    onPressed: () => ReportDialog(userId: user.userId).show()))
            : const SizedBox(width: 0, height: 0),
        ],
      ),
    );
  }
}
