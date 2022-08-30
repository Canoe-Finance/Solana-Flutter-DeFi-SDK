import 'package:dating_app/api/dislikes_api.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/matches_api.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/its_match_dialog.dart';
import 'package:dating_app/dialogs/report_dialog.dart';
import 'package:dating_app/helpers/app_ad_helper.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/plugins/carousel_pro/carousel_pro.dart';
import 'package:dating_app/widgets/badge.dart';
import 'package:dating_app/widgets/cicle_button.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  /// Params
  final User user;
  final bool showButtons;
  final bool hideDislikeButton;
  final bool fromDislikesScreen;

  // Constructor
  const ProfileScreen(
      {Key? key, required this.user,
      this.showButtons = true,
      this.hideDislikeButton = false,
      this.fromDislikesScreen = false}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Local variables
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppHelper _appHelper = AppHelper();
  final LikesApi _likesApi = LikesApi();
  final DislikesApi _dislikesApi = DislikesApi();
  final MatchesApi _matchesApi = MatchesApi();
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    AppAdHelper().showInterstitialAd();
  }

  @override
  void dispose() {
    AppAdHelper().disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    //
    // Get User Birthday
    final DateTime userBirthday = DateTime(
        widget.user.userBirthYear,
        widget.user.userBirthMonth, 
        widget.user.userBirthDay);
    // Get User Current Age
    final int userAge = UserModel().calculateUserAge(userBirthday);

    return Scaffold(
        key: _scaffoldKey,
        body: ScopedModelDescendant<UserModel>(
            builder: (context, child, userModel) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    /// Carousel Profile images
                    AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Carousel(
                          autoplay: false,
                          dotBgColor: Colors.transparent,
                          dotIncreasedColor: Theme.of(context).primaryColor,
                          images: UserModel()
                              .getUserProfileImages(widget.user)
                              .map((url) => NetworkImage(url))
                              .toList()),
                    ),

                    /// Profile details
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Full Name
                              Expanded(
                                child: Text(
                                  '${widget.user.userFullname}, '
                                  '${userAge.toString()}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              /// Show verified badge
                              widget.user.userIsVerified
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                          'assets/images/verified_badge.png',
                                          width: 30,
                                          height: 30))
                                  : const SizedBox(width: 0, height: 0),

                              /// Show VIP badge for current user
                              UserModel().user.userId == widget.user.userId &&
                                      UserModel().userIsVip
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                          'assets/images/crow_badge.png',
                                          width: 25,
                                          height: 25))
                                  : const SizedBox(width: 0, height: 0),

                              /// Location distance
                              Badge(
                                  icon: const SvgIcon(
                                      "assets/icons/location_point_icon.svg",
                                      color: Colors.white,
                                      width: 15,
                                      height: 15),
                                  text:
                                      '${_appHelper.getDistanceBetweenUsers(userLat: widget.user.userGeoPoint.latitude, userLong: widget.user.userGeoPoint.longitude)}km')
                            ],
                          ),

                          const SizedBox(height: 5),

                          /// Home location
                          _rowProfileInfo(
                            context,
                            icon: SvgIcon(
                                "assets/icons/location_point_icon.svg",
                                color: Theme.of(context).primaryColor,
                                width: 24,
                                height: 24),
                            title:
                                "${widget.user.userLocality}, ${widget.user.userCountry}",
                          ),

                          const SizedBox(height: 5),

                          /// Job title
                          _rowProfileInfo(context,
                              icon: SvgIcon("assets/icons/job_bag_icon.svg",
                                  color: Theme.of(context).primaryColor,
                                  width: 27,
                                  height: 27),
                              title: widget.user.userJobTitle),

                          const SizedBox(height: 5),

                          /// Education
                          _rowProfileInfo(context,
                              icon: SvgIcon("assets/icons/university_icon.svg",
                                  color: Theme.of(context).primaryColor,
                                  width: 34,
                                  height: 34),
                              title: widget.user.userSchool),

                          /// Birthday
                          _rowProfileInfo(context,
                              icon: SvgIcon("assets/icons/gift_icon.svg",
                                  color: Theme.of(context).primaryColor,
                                  width: 28,
                                  height: 28),
                              title:
                                  '${_i18n.translate('birthday')} ${widget.user.userBirthYear}/${widget.user.userBirthMonth}/${widget.user.userBirthDay}'),

                          /// Join date
                          _rowProfileInfo(context,
                              icon: SvgIcon("assets/icons/info_icon.svg",
                                  color: Theme.of(context).primaryColor,
                                  width: 28,
                                  height: 28),
                              title:
                                  '${_i18n.translate('join_date')} ${timeago.format(widget.user.userRegDate)}'),

                          const Divider(),

                          /// Profile bio
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_i18n.translate("bio"),
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Theme.of(context).primaryColor)),
                          ),
                          Text(widget.user.userBio,
                              style:
                                  const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// AppBar to return back
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme:
                      IconThemeData(color: Theme.of(context).primaryColor),
                  actions: <Widget>[
                    // Check the current User ID
                    if (UserModel().user.userId != widget.user.userId)
                      IconButton(
                        icon: Icon(Icons.flag,
                          color: Theme.of(context).primaryColor, size: 32),
                        // Report/Block profile dialog
                        onPressed: () =>
                            ReportDialog(userId: widget.user.userId).show(),
                      )
                  ],
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar:
            widget.showButtons ? _buildButtons(context) : null);
  }

  Widget _rowProfileInfo(BuildContext context,
      {required Widget icon, required String title}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: const TextStyle(fontSize: 19)),
        ),
      ],
    );
  }

  /// Build Like and Dislike buttons
  Widget _buildButtons(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            /// Dislike profile button
            if (!widget.hideDislikeButton)
              cicleButton(
                  padding: 8.0,
                  icon:
                      Icon(Icons.close, color: Theme.of(context).primaryColor),
                  bgColor: Colors.grey,
                  onTap: () {
                    // Dislike profile
                    _dislikesApi.dislikeUser(
                        dislikedUserId: widget.user.userId,
                        onDislikeResult: (result) {
                          /// Check result to show message
                          if (!result) {
                            // Show error message
                            showScaffoldMessage(
                                context: context,
                                message: _i18n.translate(
                                    "you_already_disliked_this_profile"));
                          }
                        });
                  }),

            /// Like profile button
            cicleButton(
                padding: 8.0,
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                bgColor: Theme.of(context).primaryColor,
                onTap: () {
                  // Like user
                  _likeUser(context);
                }),
          ],
        ));
  }

  /// Like user function
  Future<void> _likeUser(BuildContext context) async {
    /// Check match first
    _matchesApi
        .checkMatch(
            userId: widget.user.userId,
            onMatchResult: (result) {
              if (result) {
                /// Show It`s match dialog
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return ItsMatchDialog(
                        matchedUser: widget.user,
                        showSwipeButton: false,
                        swipeKey: null,
                      );
                    });
              }
            })
        .then((_) {
      /// Like user
      _likesApi.likeUser(
          likedUserId: widget.user.userId,
          userDeviceToken: widget.user.userDeviceToken,
          nMessage: "${UserModel().user.userFullname.split(' ')[0]}, "
              "${_i18n.translate("liked_your_profile_click_and_see")}",
          onLikeResult: (result) async {
            if (result) {
              // Show success message
              showScaffoldMessage(
                  context: context,
                  message:
                      '${_i18n.translate("like_sent_to")} ${widget.user.userFullname}');
            } else if (!result) {
              // Show error message
              showScaffoldMessage(
                  context: context,
                  message: _i18n.translate("you_already_liked_this_profile"));
            }

            /// Validate to delete disliked user from disliked list
            else if (result && widget.fromDislikesScreen) {
              // Delete in database
              await _dislikesApi.deleteDislikedUser(widget.user.userId);
            }
          });
    });
  }
}
