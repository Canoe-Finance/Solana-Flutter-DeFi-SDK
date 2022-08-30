import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/widgets/app_section_card.dart';
import 'package:dating_app/widgets/profile_basic_info_card.dart';
import 'package:dating_app/widgets/profile_statistics_card.dart';
import 'package:dating_app/widgets/delete_account_button.dart';
import 'package:dating_app/widgets/sign_out_button_card.dart';
import 'package:dating_app/widgets/vip_account_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  // Variables

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Basic profile info
            const ProfileBasicInfoCard(),

            const SizedBox(height: 10),

            /// Profile Statistics Card
            const ProfileStatisticsCard(),

            const SizedBox(height: 10),

            /// Show VIP dialog
            const VipAccountCard(),

            const SizedBox(height: 10),

            /// App Section Card
            AppSectionCard(),

            const SizedBox(height: 20),

            /// Sign out button card
            const SignOutButtonCard(),

            const SizedBox(height: 25),
            
            /// Delete Account Button
            const DeleteAccountButton(),

            const SizedBox(height: 25),

          ],
        );
      }),
    );
  }
}
