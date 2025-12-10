import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:collection';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/main_controller.dart';
import '../widgets/live_loading_indicator.dart';
import '../utils/webview_scripts.dart';
import 'no_internet_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MainController _controller = MainController();
  DateTime? _lastPressedAt;
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: const Color(0xFF95062D)),
      onRefresh: () async {
        if (_controller.webViewController != null) {
          _controller.webViewController!.reload();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _controller.goBack();
        if (shouldExit) {
          final now = DateTime.now();
          if (_lastPressedAt == null ||
              now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
            _lastPressedAt = now;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Press back again to exit')),
              );
            }
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isOffline) {
            return NoInternetScreen(
              onRefresh: () {
                _controller.checkConnectivity();
                if (_controller.webViewController != null) {
                  _controller.webViewController!.reload();
                }
              },
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "HOT JAMZ RADIO",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible,
                  fontSize: 15,
                ),
              ),
              backgroundColor: const Color(0xFF95062D),
              foregroundColor: Colors.white,
              actions: [
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: const FaIcon(FontAwesomeIcons.spotify, size: 24),
                  ),
                  onTap: () => _controller.loadUrl(
                    'https://open.spotify.com/user/31363rqfdrwtthetk2bq5eafmtda',
                  ),
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: const FaIcon(FontAwesomeIcons.apple, size: 26),
                  ),

                  onTap: () => _controller.loadUrl('https://music.apple.com'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _controller.goBackInWebView(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: _controller.canGoBackState
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _controller.goForward(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: _controller.canGoForwardState
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 05),
                  ],
                ),
              ],
            ),
            drawer: _buildDrawer(context),
            body: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(_controller.homeUrl),
                  ),
                  initialUserScripts: UnmodifiableListView<UserScript>([
                    UserScript(
                      source: WebViewScripts.hideHeaderScript,
                      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                    ),
                    UserScript(
                      source: WebViewScripts.hideOpenAppButtonScript,
                      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                    ),
                  ]),
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                    javaScriptEnabled: true,
                    allowsInlineMediaPlayback: true,
                    domStorageEnabled: true,
                    useHybridComposition: true,
                    userAgent:
                        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 Mobile Safari/537.36',
                  ),
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    _controller.setWebViewController(controller);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        var uri = navigationAction.request.url;
                        if (uri != null) {
                          // Handle intent:// URLs (Deep links)
                          if (uri.scheme == 'intent') {
                            try {
                              String intentUrl = uri.toString();
                              // Extract browser_fallback_url if available
                              if (intentUrl.contains('browser_fallback_url=')) {
                                var fallbackUrl = Uri.decodeComponent(
                                  intentUrl
                                      .split('browser_fallback_url=')[1]
                                      .split(';')[0],
                                );
                                await controller.loadUrl(
                                  urlRequest: URLRequest(
                                    url: WebUri(fallbackUrl),
                                  ),
                                );
                                return NavigationActionPolicy.CANCEL;
                              }
                            } catch (e) {
                              debugPrint('Error parsing intent URL: $e');
                            }
                          }

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about",
                          ].contains(uri.scheme)) {
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                  onLoadStart: (controller, url) {
                    _controller.setLoading(true);
                  },
                  onLoadStop: (controller, url) async {
                    _controller.setLoading(false);
                    pullToRefreshController?.endRefreshing();
                    _controller.updateHistoryState();
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    _controller.updateHistoryState();
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                ),
                if (_controller.isLoading)
                  Container(
                    color: Colors.white,
                    child: const LiveLoadingIndicator(),
                  ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: const Color(0xFF95062D),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              type: BottomNavigationBarType.fixed,
              currentIndex: _controller.currentIndex,
              onTap: _controller.onBottomNavIndexChanged,
              items: const [
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.house),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.music),
                  label: 'Playlist',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.radio),
                  label: 'LIVE RADIO',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.youtube),
                  label: 'Youtube',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.bullhorn),
                  label: 'Packages',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF95062D),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 45, 6, 5),
              decoration: const BoxDecoration(color: Color(0xFF95062D)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      // padding: const EdgeInsets.all(4),
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withOpacity(0.2),
                      //   borderRadius: BorderRadius.circular(50),
                      // ),
                      child: const FaIcon(
                        FontAwesomeIcons.xmark,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.house,
                color: Colors.white70,
              ),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(0);
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.music,
                color: Colors.white70,
              ),
              title: const Text(
                'Playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(1);
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.radio,
                color: Colors.white70,
              ),
              title: const Text(
                'LIVE RADIO',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(2);
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.youtube,
                color: Colors.white70,
              ),
              title: const Text(
                'Youtube',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(3);
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.bullhorn,
                color: Colors.white70,
              ),
              title: const Text(
                'Packages',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(4);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(color: Colors.white54),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 5),
              child: Text(
                'Listen to Music On',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.spotify,
                color: Colors.white70,
              ),
              title: const Text(
                'Spotify',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(
                  'https://open.spotify.com/user/31363rqfdrwtthetk2bq5eafmtda',
                ); // Placeholder - update with actual link
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.apple,
                color: Colors.white70,
              ),
              title: const Text(
                'Apple Music',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(
                  'https://music.apple.com',
                ); // Placeholder - update with actual link
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(color: Colors.white54),
            ),

            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.shareNodes,
                color: Colors.white70,
              ),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Share.share(
                  'Check out Hot Jamz Radio and download our free Music Mobile Apps today! https://www.hotjamzradio.com',
                );
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.instagram,
                color: Colors.white70,
              ),
              title: const Text(
                'Instagram',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl('https://www.instagram.com'); // Placeholder
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.facebook,
                color: Colors.white70,
              ),
              title: const Text(
                'Facebook',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl('https://www.facebook.com'); // Placeholder
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.envelope,
                color: Colors.white70,
              ),
              title: const Text('Email', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('mailto:radiohotjamz@gmail.com'); // Placeholder
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
