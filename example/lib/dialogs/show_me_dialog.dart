import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';

class ShowMeDialog extends StatefulWidget {
  const ShowMeDialog({Key? key}) : super(key: key);

  @override
  _ShowMeDialogState createState() => _ShowMeDialogState();
}

class _ShowMeDialogState extends State<ShowMeDialog> {
  // Variables
  final Map<String, dynamic>? _userSettings = UserModel().user.userSettings;
  String _selectedOption = "";
  String _selectedOptionKey = "";
  late AppLocalizations _i18n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Variables
    final i18n = AppLocalizations.of(context);
    final String? showMe = _userSettings?[USER_SHOW_ME];
    // Check option
    if (showMe != null) {
      setState(() {
        _selectedOption = i18n.translate(showMe);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialization
    _i18n = AppLocalizations.of(context);
    // Map options
    final Map<String, String> mapOptions = {
      "women": _i18n.translate("women"),
      "men": _i18n.translate("men"),
      "everyone": _i18n.translate("everyone"),
    };

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _dialogContent(context, mapOptions),
      elevation: 3,
    );
  }

// Build dialog
  Widget _dialogContent(BuildContext context, Map<String, String> mapOptions) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const Icon(Icons.wc),
              const SizedBox(width: 5),
              Text(
                _i18n.translate("show_me"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.black,
          height: 5,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: mapOptions.entries.map((option) {
                  return RadioListTile<String>(
                      selected: _selectedOption == option.value ? true : false,
                      title: Text(option.value),
                      activeColor: Theme.of(context).primaryColor,
                      value: option.value,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value.toString();
                          _selectedOptionKey = option.key;
                        });
                        debugPrint('Selected option: $value');
                      });
                }).toList()),
          ),
        ),
        const Divider(
          color: Colors.black,
          height: 5,
        ),
        Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    child: Text(_i18n.translate("CANCEL")),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(_i18n.translate("SAVE"),
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: _selectedOption == ''
                        ? null
                        : () async {
                            /// Save option
                            await UserModel().updateUserData(
                                userId: UserModel().user.userId,
                                data: {
                                  '$USER_SETTINGS.$USER_SHOW_ME':
                                      _selectedOptionKey
                                });

                            // Close dialog
                            Navigator.of(context).pop();
                            debugPrint('Show me option() -> saved');
                          },
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
