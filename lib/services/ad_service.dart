import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  Timer? _adTimer;
  bool _showAdRequested = false;

  // Default interval in minutes (40 as requested)
  // You can update this value from a backend or remote config to make it dynamic.
  int _adIntervalMinutes = 1; // Set to 1 for testing

  // Production Ad Unit IDs
  static const String _androidUnitId = 'ca-app-pub-6283793061328900/5676677473';
  static const String _iosUnitId = 'ca-app-pub-6283793061328900/6492803808';

  String get _adUnitId => defaultTargetPlatform == TargetPlatform.android
      ? _androidUnitId
      : _iosUnitId;

  void init() {
    debugPrint('AdService: Initializing...');
    _loadInterstitialAd();
    _startTimer();
  }

  /// Updates the ad interval and restarts the timer.
  void updateInterval(int minutes) {
    if (minutes <= 0) return;
    _adIntervalMinutes = minutes;
    _startTimer();
    debugPrint('Ad interval updated to $_adIntervalMinutes minutes');
  }

  void _startTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(Duration(minutes: _adIntervalMinutes), (timer) {
      debugPrint(
        'AdService: Timer triggered after $_adIntervalMinutes minute(s).',
      );
      showInterstitialAd();
    });
  }

  void _loadInterstitialAd() {
    debugPrint(
      'AdService: Attempting to load Interstitial Ad for Unit ID: $_adUnitId',
    );
    if (_isAdLoading) {
      debugPrint('AdService: Ad is already loading...');
      return;
    }
    if (_interstitialAd != null) {
      debugPrint('AdService: Ad is already loaded and ready.');
      return;
    }
    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
          _setAdEvents(ad);
          debugPrint('AdService: InterstitialAd loaded successfully.');

          if (_showAdRequested) {
            debugPrint(
              'AdService: Showing ad now (was requested while loading).',
            );
            _showAdRequested = false;
            showInterstitialAd();
          }
        },
        onAdFailedToLoad: (error) {
          _isAdLoading = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: $error');
          // Try to reload after 1 minute if failed
          Timer(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  void _setAdEvents(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
          'AdService: Ad dismissed. Resetting timer for the next one.',
        );
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); // Preload next ad
        _startTimer(); // Start the 40-minute wait AFTER dismissal
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Failed to show ad: $error. Resetting timer.');
        ad.dispose();
        _interstitialAd = null;
        _showAdRequested = false;
        _loadInterstitialAd();
        _startTimer(); // Also reset if it failed to show
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdService: Ad is now showing on screen.');
      },
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      debugPrint('AdService: Showing Interstitial Ad.');
      _interstitialAd!.show();
    } else {
      debugPrint(
        'AdService: Ad not ready to show yet. Will show automatically once loaded.',
      );
      _showAdRequested = true;
      _loadInterstitialAd();
    }
  }

  void dispose() {
    _adTimer?.cancel();
    _interstitialAd?.dispose();
  }
}
