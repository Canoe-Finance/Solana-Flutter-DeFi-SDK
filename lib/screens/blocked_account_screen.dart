import 'package:dating_app/models/app_model.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

class BlockedAccountScreen extends StatelessWidget {
  const BlockedAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.lock_outline, size: 60, color: Colors.white),
          ),
          Text(i18n.translate("oops")),
          Text(i18n.translate("your_account_was_blocked"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(i18n.translate("please_contact_support_to_active_it")),
          const SizedBox(height: 10),
          Text(AppModel().appInfo.appEmail,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 18),
              textAlign: TextAlign.center),
        ],
      ),
    ));
  }
}
