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

  final String homeUrl = "https://www.hotjamzradio.com";
  // Using placeholders for other tabs as specific URLs were not provided.
  // You can update these URLs to the correct paths.
  final String instagramUrl = "https://www.instagram.com/hotjamzradio";
  final String liveRadioUrl =
      "https://das-edge15-live365-dal02.cdnstream.com/a37600";
  final String youtubeUrl = "https://www.youtube.com";
  final String facebookUrl = "https://www.facebook.com/hotjamzradiostation";

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
        loadUrl(homeUrl);
        break;
      case 1:
        loadUrl(liveRadioUrl);
        break;
      case 2:
        loadUrl(youtubeUrl);
        break;
      case 3:
        loadUrl(instagramUrl);
        break;
      case 4:
        loadUrl(facebookUrl);
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
