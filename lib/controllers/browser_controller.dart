import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserController extends ChangeNotifier {
  InAppWebViewController? webViewController;
  TextEditingController urlController = TextEditingController();
  bool isLoading = false;
  double progress = 0;
  String currentUrl = '';

  void setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
  }

  void updateUrl(String url) {
    currentUrl = url;
    urlController.text = url;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setProgress(double p) {
    progress = p;
    notifyListeners();
  }

  Future<void> loadUrl(String input) async {
    if (input.isEmpty) return;

    String urlToLoad = input.trim();

    // Check if it's a valid URL, otherwise treat as search
    if (!urlToLoad.startsWith('http://') && !urlToLoad.startsWith('https://')) {
      if (urlToLoad.contains('.') && !urlToLoad.contains(' ')) {
        urlToLoad = 'https://$urlToLoad';
      } else {
        // specific google search
        urlToLoad =
            'https://www.google.com/search?q=${Uri.encodeComponent(urlToLoad)}';
      }
    }

    if (webViewController != null) {
      await webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(urlToLoad)),
      );
    }
  }

  Future<bool> goBack() async {
    if (webViewController != null && await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return true;
    }
    return false;
  }

  Future<bool> goForward() async {
    if (webViewController != null && await webViewController!.canGoForward()) {
      webViewController!.goForward();
      return true;
    }
    return false;
  }
}
