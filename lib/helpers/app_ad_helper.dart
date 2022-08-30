import 'dart:io';

import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppAdHelper {
  // Local Variables
  static InterstitialAd? _interstitialAd;
  //

  // Get Interstitial Ad ID
  static String get _interstitialID {
    if (Platform.isAndroid) {
      return ANDROID_INTERSTITIAL_ID;
    } else if (Platform.isIOS) {
      return IOS_INTERSTITIAL_ID;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // Create Interstitial Ad
  Future<void> _createInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: _interstitialID,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _interstitialAd = null;
            _createInterstitialAd();
          },
        ));
  }

  // Show Interstitial Ads for Non VIP Users
  void showInterstitialAd() async {
    // Check "Active" VIP Status
    if (UserModel().userIsVip) {
      // Debug
      debugPrint('User is VIP Member!');
      return;
    }

    // Load Interstitial Ad
    await _createInterstitialAd();

    if (_interstitialAd == null) {
      // Debug
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    // Run callbacks
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // Dispose Interstitial Ad
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
