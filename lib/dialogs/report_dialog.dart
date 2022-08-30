import 'dart:io';

import 'package:dating_app/api/blocked_users_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/flag_user_dialog.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/main.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  // Constructor
  const ReportDialog(
      {Key? key, required this.userId})
      : super(key: key);

  // Parameters
  final String userId;

  // Show dialog method
  void show() {
    // Get ReportDialog Modal
    final _modal = ReportDialog(userId: userId);
    final _context = navigatorKey.currentContext!;

    // Check Platform to flag profile
    if (Platform.isIOS) {
      // iOS modal
      showCupertinoModalPopup(context: _context, builder: (context) => _modal);
    } else {
      // Android modal
      showModalBottomSheet(
        context: _context, 
        backgroundColor: Colors.transparent,
        builder: (context) => _modal);
    }
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  // Variables
  late AppLocalizations _i18n;
  late ProgressDialog _pr;

  // Close dialog method
  void _close() => navigatorKey.currentState?.pop();

  // Report profile
  void _reportProfile() {
    // Close bottom sheet modal
    _close();

    // Show Flag Dialog
    showDialog(
        context: context,
        builder: (context) => FlagUserDialog(flaggedUserId: widget.userId));
  }

  // Block profile
  void _blockProfile() async {
    // Close bottom sheet modal
    _close();

    // Confirm dialog
    confirmDialog(context,
        positiveText: _i18n.translate("BLOCK"),
        message: _i18n.translate("this_profile_will_be_blocked"),
        negativeAction: _close, positiveAction: () async {
      // Hide confirm dialog
      _close();

      // Show processing dialog
      _pr.show(_i18n.translate("processing"));

      // Block profile
      if (await BlockedUsersApi().blockUser(blockedUserId: widget.userId)) {
        // Hide progress dialog
        _pr.hide();

        final String msg = _i18n.translate("user_has_been_blocked");
        // Show success dialog
        showScaffoldMessage(message: msg, bgcolor: Colors.green);
      } else {
        // Hide progress dialog
        _pr.hide();

        final String msg =
            _i18n.translate("you_have_already_blocked_this_user");
        // Show success dialog
        showScaffoldMessage(message: msg, bgcolor: Colors.red);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(navigatorKey.currentContext ?? context);

    // Check Platform
    if (Platform.isIOS) {
      return CupertinoActionSheet(
        title: Text(_i18n.translate('select_an_option'),
            style: const TextStyle(fontSize: 18)),
        cancelButton: CupertinoActionSheetAction(
          child: Text(_i18n.translate('CANCEL'),
              style: const TextStyle(color: APP_PRIMARY_COLOR)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Report bitton
          CupertinoActionSheetAction(
            child: _iosButtonIcon(context,
                color: Colors.red,
                icon: Icons.flag,
                text: _i18n.translate('report').toUpperCase()),
            onPressed: _reportProfile,
          ),

          // Block button
          CupertinoActionSheetAction(
            child: _iosButtonIcon(context,
                color: Colors.red,
                icon: Icons.block,
                text: _i18n.translate('BLOCK')),
            onPressed: _blockProfile,
          ),
        ],
      );
    }

    // Modal for Android
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          border: Border.all(
              width: 1.0, color: const Color(0xff707070)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_i18n.translate('select_an_option'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ),
              // Close button
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon:
                      const Icon(Icons.cancel, color: Colors.grey, size: 32))
            ],
          ),

          const Divider(),

          // Report button
          TextButton.icon(
            icon: const Icon(
              Icons.flag_outlined,
              color: Colors.red,
            ),
            label: Text(_i18n.translate('report').toUpperCase(),
                style: const TextStyle(fontSize: 18, color: Colors.red)),
            onPressed: _reportProfile,
          ),

          const Divider(),

          // Block button
          TextButton.icon(
              icon: const Icon(
                Icons.block,
                color: Colors.red,
              ),
              label: Text(_i18n.translate('BLOCK'),
                  style: const TextStyle(fontSize: 18, color: Colors.red)),
              onPressed: _blockProfile),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // Build iOS button
  Widget _iosButtonIcon(BuildContext context,
      {required IconData icon, required String text, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color ?? Theme.of(context).primaryColor),
        const SizedBox(width: 5),
        Text(text.toUpperCase(), style: TextStyle(color: color)),
      ],
    );
  }
}
