import 'dart:async';

import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_helper.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/home_screen.dart';
import 'package:dating_app/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UpdateLocationScreen extends StatefulWidget {
  // Parameters
  final bool isSignUpProcess;

  // Conastructor
  const UpdateLocationScreen({Key? key, this.isSignUpProcess = true}) : super(key: key);

  @override
  _UpdateLocationScreenState createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  // Variables
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  final AppHelper _appHelper = AppHelper();

  /// Navigate to next page
  void _nextScreen(screen) {
    // Go to next page route
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => screen), (route) => false);
    });
  }

  // Show timeout exception message on get device's location
  void _showTimeoutErrorMessage(BuildContext context) async {
    // Hide progress dialog
    await _pr.hide();
    // Get error message
    final String message = _i18n
            .translate("we_are_unable_to_get_your_device_current_location") +
        ", " +
        _i18n.translate(
            "please_make_sure_to_enable_location_services_on_your_device_and_try_again");
    // Show error messag
    errorDialog(context, message: message);
  }

  // Show fail error message on get device's location
  void _showFailErrorMessage(BuildContext context) async {
    // Hide progress dialog
    await _pr.hide();
    // Get error message
    final String message =
        _i18n.translate("we_are_unable_to_get_your_device_current_location") +
            ", " +
            _i18n.translate("please_skip_and_try_again_later_in_app_settings");
    // Show error messag
    errorDialog(context, message: message);
  }

  /// Get location permission
  Future<void> _getLocationPermission(BuildContext context) async {
    // Show loading progress
    _pr.show(_i18n.translate('processing'));

    /// Check location permission
    await _appHelper.checkLocationPermission(onGpsDisabled: () async {
      // Hide progress dialog
      await _pr.hide();
      // Show error message
      errorDialog(context,
          message: _i18n.translate(
              "we_were_unable_to_get_your_current_location_please_enable_gps_to_continue"));
    }, onDenied: () async {
      // Hide progress dialog
      await _pr.hide();
      // Show error message
      errorDialog(context,
          message: _i18n.translate("location_permissions_are_denied"));
    }, onGranted: () async {
      //
      // Get User current location
      //
      await _appHelper.getUserCurrentLocation(
          onSuccess: (Position position) async {
        // Debug
        debugPrint("User Position result: $position");
        // Get user readable address
        final Placemark place = await _appHelper.getUserAddress(
            position.latitude, position.longitude);

        // Debug placemark address
        debugPrint("User Address result: $place");

        // Get locality
        String? locality;
        // Check locality
        if (place.locality == '') {
          locality = place.administrativeArea;
        } else {
          locality = place.locality;
        }

        // Update User location
        await _appHelper.updateUserLocation(
            userId: UserModel().getFirebaseUser!.uid, // widget.userId
            latitude: position.latitude,
            longitude: position.longitude,
            country: place.country.toString(),
            locality: locality.toString());

        // Hide progress dialog
        await _pr.hide();

        // Show success message
        successDialog(context,
            message: '${_i18n.translate("location_updated_successfully")}\n\n'
                '${place.country}, $locality', positiveAction: () {
          // Check
          if (widget.isSignUpProcess) {
            // Go to home screen
            _nextScreen(const HomeScreen());
          } else {
            // Close dialog
            Navigator.of(context).pop();
            // Close current screen
            Navigator.of(context).pop();
          }
        });
      }, onTimeoutException: (exception) async {
        // Show timeout error message
        _showTimeoutErrorMessage(context);
      }, onFail: (error) {
        // Show fail error message
        _showFailErrorMessage(context);
      });
      // End
    });
  }

  @override
  Widget build(BuildContext context) {
    // Init
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context, isDismissible: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate('your_current_location')),
        // actions: [
        //   // SKIP BUTTON
        //   // Check
        //   if (widget.isSignUpProcess)
        //     TextButton(
        //       child: Text(_i18n.translate('SKIP'),
        //           style: TextStyle(color: Theme.of(context).primaryColor)),
        //       onPressed: () {
        //         // Show info dialog
        //         confirmDialog(context,
        //             message: _i18n.translate(
        //                 'if_you_SKIP_the_option_to_get_your_device_current_location'),
        //             positiveText: _i18n.translate('SKIP'),
        //             negativeAction: () => Navigator.of(context).pop(),
        //             positiveAction: () {
        //               // Actions
        //               // Go to home screen
        //               _nextScreen(HomeScreen());
        //             });
        //       },
        //     )
        // ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Location icon
              Icon(Icons.location_on,
                  size: 100, color: Theme.of(context).primaryColor),
              const SizedBox(height: 5),
              // Title description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                    _i18n.translate(
                        'the_app_needs_your_permission_to_access_your_device_current_location'),
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              // Get current location button
              DefaultButton(
                  child: Text(_i18n.translate('GET_LOCATION'),
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    // Get location permission
                    _getLocationPermission(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
