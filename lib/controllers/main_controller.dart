import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class MainController extends ChangeNotifier {
  InAppWebViewController? webViewController;
  int currentIndex = 0;
  bool isLoading = true;
  bool isOffline = false;
  bool canGoBackState = false;
  bool canGoForwardState = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final String homeUrl = "https://hotjamzradio.com/home-page-app-launch";
  final String homePageUrl = "https://hotjamzradio.com/home-page-mobile";
  final String playlistUrl =
      "https://www.hotjamzradio.com/new-music-playlists/";
  final String packagesUrl =
      "https://www.hotjamzradio.com/radio-promo-packages/";
  final String instagramUrl = "https://www.instagram.com/hotjamzradio";
  final String instagramLoginUrl = "https://www.instagram.com/";
  final String liveRadioUrl =
      "https://das-edge15-live365-dal02.cdnstream.com/a37600";
  final String youtubeUrl = "https://www.youtube.com";
  final String facebookUrl = "https://m.facebook.com/hotjamzradiostation";
  final String facebookLoginUrl = "https://m.facebook.com/login";
  final String iheartUrl = "https://www.iheart.com";
  final String twitterUrl = "https://x.com/";
  final String spotifyUrl =
      "https://open.spotify.com/user/31363rqfdrwtthetk2bq5eafmtda";
  final String appleMusicUrl = "https://music.apple.com";

  MainController() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    if (isOffline == hasConnection) {
      isOffline = !hasConnection;
      notifyListeners();
    }
  }

  Future<void> checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
  }

  Future<void> updateHistoryState() async {
    if (webViewController != null) {
      canGoBackState = await webViewController!.canGoBack();
      canGoForwardState = await webViewController!.canGoForward();
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void onBottomNavIndexChanged(int index) {
    currentIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        loadUrl(homePageUrl);
        break;
      case 1:
        loadUrl(youtubeUrl);
        break;
      case 2:
        loadUrl(liveRadioUrl);
        break;
      case 3:
        loadUrl(spotifyUrl);
        break;
      case 4:
        loadUrl(appleMusicUrl);
        break;
    }
  }

  void loadUrl(String url) {
    webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  Future<bool> goBack() async {
    if (isOffline) {
      return true;
    }

    if (currentIndex != 0) {
      onBottomNavIndexChanged(0);
      return false;
    }

    if (webViewController != null && await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return false; // Don't exit app
    }
    return true; // Exit app
  }

  Future<void> goForward() async {
    if (webViewController != null && await webViewController!.canGoForward()) {
      webViewController!.goForward();
    }
  }

  Future<void> goBackInWebView() async {
    if (webViewController != null && await webViewController!.canGoBack()) {
      webViewController!.goBack();
    }
  }
}
