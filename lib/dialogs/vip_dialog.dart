
import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/app_model.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/widgets/store_products.dart';
import 'package:flutter/material.dart';

class VipDialog extends StatelessWidget {
  const VipDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      /// User image
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Image.asset('assets/images/crow_badge.png'),
                        ) 
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(i18n.translate("vip_account"),
                            style: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage: NetworkImage(UserModel().user.userProfilePhoto),
                        ),
                        title: Text(
                            '${i18n.translate("hello")} ${UserModel().user.userFullname.split(' ')[0]}, '
                            '${i18n.translate("become_a_vip_member_and_enjoy_the_benefits_below")}',
                            style:
                                const TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 8)
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white, size: 35),
                      onPressed: () {
                        /// Close Dialog
                        Navigator.of(context).pop();
                      }),
                )
              ],
            ),

            /// VIP Plans
            Container(
              color: Colors.grey.withAlpha(70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(i18n.translate("vip_subscriptions"),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 10, thickness: 1),
                  /// VIP Subscriptions
                  StoreProducts(
                    priceColor: Colors.green,
                    icon: Image.asset('assets/images/crow_badge.png',
                        width: 50, height: 50),
                  ),
                  const Divider(thickness: 1, height: 30),

                  // Show Restore VIP Subscription button
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(i18n.translate('have_you_already_purchased_a_VIP_account'),
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        // Restore subscription button
                        TextButton.icon(
                            icon: const Icon(Icons.refresh),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ))),
                            label: Text(i18n.translate('restore_subscription')),
                            onPressed: () async {
                              // Restore past subscription
                              await AppHelper().restoreVipAccount(
                                  onSuccess: () {
                                // Show success message
                                successDialog(context,
                                    message:
                                        i18n.translate('VIP_subscription_successfully_restored'));
                              }, onNotFound: () {
                                // Show error message
                              errorDialog(context,
                                  message:
                                      i18n.translate('oops_you_dont_have_an_active_VIP_subscription'));
                              });
                            }),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1),
                  
                ],
              ),
            ),
            const Divider(),

            /// VIP Benefits
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(i18n.translate("benefits"),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 10, thickness: 1),

                  // Passport
                  ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.flight,
                              color: Colors.white),
                    ),
                    title: Text(i18n.translate("passport"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(i18n.translate("travel_to_any_country_or_city_and_match_with_people_there")),
                  ),
                  const Divider(height: 10, thickness: 1),

                  // Discover more people around you
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.location_on_outlined, 
                      color: Colors.white),
                    ),
                    title: Text(i18n.translate("discover_more_people"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text("${i18n.translate('get')} "
                      "${AppModel().appInfo.vipAccountMaxDistance} km " 
                      "${i18n.translate('radius_away')}"),
                  ),
                  const Divider(height: 10, thickness: 1),

                  // Add more pictures
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.camera_alt, 
                      color: Colors.white),
                    ),
                    title: Text(i18n.translate("add_more_pictures_on_your_profile_gallery"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(i18n.translate("make_your_profile_attractive_by_adding_more_photos")),
                  ),
                  const Divider(height: 10, thickness: 1),

                  /// See who liked you
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.pinkAccent,
                      child: Icon(Icons.favorite, color: Colors.white),
                    ),
                    title: Text(i18n.translate("see_people_who_liked_you"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(i18n.translate(
                        "unravel_the_mystery_and_find_out_who_liked_you")),
                  ),
                  const Divider(height: 10, thickness: 1),

                  /// See who visited you
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.remove_red_eye, color: Colors.white),
                    ),
                    title: Text(
                        i18n.translate("see_people_who_visited_your_profile"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(i18n.translate(
                        "unravel_the_mystery_and_find_out_who_visited_your_profile")),
                  ),
                  const Divider(height: 10, thickness: 1),

                  /// See disliked profiles
                  ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    title: Text(
                        i18n.translate("see_people_you_have_rejected"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(
                        i18n.translate("retrieve_and_review_all_profiles")),
                  ),
                  const Divider(height: 10, thickness: 1),

                  /// Verified account badge
                  ListTile(
                    leading: Image.asset('assets/images/verified_badge.png',
                        width: 40, height: 40),
                    title: Text(i18n.translate("verified_account_badge"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(i18n.translate(
                        "let_other_users_know_that_you_are_a_real_person")),
                  ),
                  const Divider(height: 10, thickness: 1),

                  /// No Ads
                  ListTile(
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.block, color: Colors.white),
                    ),
                    title: Text(i18n.translate("no_ads"),
                        style: const TextStyle(fontSize: 18)),
                    subtitle:
                        Text(i18n.translate("have_a_unique_experience")),
                  ),
                  const Divider(height: 10, thickness: 1),
                  const SizedBox(height: 15)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
 }
