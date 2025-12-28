import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../controllers/browser_controller.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final BrowserController _controller = BrowserController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Column(
          children: [
            // Safe Area for top status bar
            Container(
              color: const Color(0xFF95062D),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _controller.goBack(),
                      ),
                      // Forward Button
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _controller.goForward(),
                      ),
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _controller.urlController,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (value) => _controller.loadUrl(value),
                            decoration: const InputDecoration(
                              hintText: 'Search or enter URL',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Refresh/Stop
                      IconButton(
                        icon: Icon(
                          _controller.isLoading ? Icons.close : Icons.refresh,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_controller.webViewController != null) {
                            if (_controller.isLoading) {
                              _controller.webViewController!.stopLoading();
                            } else {
                              _controller.webViewController!.reload();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Progress Bar
            if (_controller.isLoading)
              LinearProgressIndicator(
                value: _controller.progress,
                color: const Color(0xFF95062D),
                backgroundColor: Colors.white,
                minHeight: 3,
              ),
            // WebView
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://www.google.com"),
                ),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                  javaScriptEnabled: true,
                  allowsInlineMediaPlayback: true,
                  supportMultipleWindows: true,
                ),
                onWebViewCreated: (controller) {
                  _controller.setWebViewController(controller);
                },
                onLoadStart: (controller, url) {
                  _controller.setLoading(true);
                  if (url != null) {
                    _controller.urlController.text = url.toString();
                  }
                },
                onLoadStop: (controller, url) {
                  _controller.setLoading(false);
                  if (url != null) {
                    _controller.updateUrl(url.toString());
                  }
                },
                onProgressChanged: (controller, progress) {
                  _controller.setProgress(progress / 100);
                  if (progress == 100) {
                    _controller.setLoading(false);
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
