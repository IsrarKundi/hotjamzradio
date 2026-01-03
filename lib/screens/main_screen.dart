import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'browser_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'dart:collection';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/main_controller.dart';
import '../widgets/live_loading_indicator.dart';
import '../utils/webview_scripts.dart';
import '../services/analytics_service.dart';
import '../widgets/social_media_toggle.dart';
import '../widgets/bottom_nav_toggle.dart';
import 'no_internet_screen.dart';
import 'plans_screen.dart';
import 'radio_player_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

enum SocialPlatform { iheart, instagram, facebook, twitter, radio }

class _MainScreenState extends State<MainScreen> {
  final MainController _controller = MainController();
  DateTime? _lastPressedAt;
  PullToRefreshController? pullToRefreshController;
  SocialPlatform _selectedPlatform = SocialPlatform.instagram;

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
              centerTitle: false,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: SocialMediaToggle(
                  selectedPlatform: _selectedPlatform,
                  onPlatformSelected: (platform) {
                    setState(() {
                      _selectedPlatform = platform;
                    });
                    switch (platform) {
                      case SocialPlatform.iheart:
                        AnalyticsService().logPlatformSwitch('iHeartRadio');
                        _controller.loadUrl(_controller.iheartUrl);
                        break;
                      case SocialPlatform.instagram:
                        AnalyticsService().logPlatformSwitch('Instagram');
                        _controller.loadUrl(_controller.instagramUrl);
                        break;
                      case SocialPlatform.facebook:
                        AnalyticsService().logPlatformSwitch('Facebook');
                        _controller.loadUrl(_controller.facebookUrl);
                        break;
                      case SocialPlatform.twitter:
                        AnalyticsService().logPlatformSwitch('Twitter/X');
                        _controller.loadUrl(_controller.twitterUrl);
                        break;
                      case SocialPlatform.radio:
                        AnalyticsService().logPlatformSwitch('Live Radio');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RadioPlayerScreen(),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
              backgroundColor: const Color(0xFF95062D),
              foregroundColor: Colors.white,
              actions: [
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
                Offstage(
                  offstage: _controller.currentIndex == 2,
                  child: Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(_controller.homeUrl),
                        ),
                        initialUserScripts: UnmodifiableListView<UserScript>([
                          UserScript(
                            source: WebViewScripts.hideHeaderScript,
                            injectionTime:
                                UserScriptInjectionTime.AT_DOCUMENT_END,
                          ),
                          UserScript(
                            source: WebViewScripts.hideOpenAppButtonScript,
                            injectionTime:
                                UserScriptInjectionTime.AT_DOCUMENT_END,
                          ),
                          UserScript(
                            source: WebViewScripts.hideFacebookAppBanner,
                            injectionTime:
                                UserScriptInjectionTime.AT_DOCUMENT_END,
                            forMainFrameOnly: false,
                          ),
                        ]),
                        initialSettings: InAppWebViewSettings(
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          javaScriptEnabled: true,
                          allowsInlineMediaPlayback: true,
                          domStorageEnabled: true,
                          useHybridComposition: true,
                          javaScriptCanOpenWindowsAutomatically: true,
                          supportMultipleWindows: true,
                          userAgent:
                              'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
                        ),
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          _controller.setWebViewController(controller);
                        },
                        onCreateWindow: (controller, createWindowAction) async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              bool isPopupLoading = true;
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Dialog(
                                    insetPadding: EdgeInsets.zero,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Stack(
                                        children: [
                                          InAppWebView(
                                            windowId:
                                                createWindowAction.windowId,
                                            initialSettings: InAppWebViewSettings(
                                              useShouldOverrideUrlLoading: true,
                                              mediaPlaybackRequiresUserGesture:
                                                  false,
                                              javaScriptEnabled: true,
                                              allowsInlineMediaPlayback: true,
                                              domStorageEnabled: true,
                                              useHybridComposition: true,
                                              userAgent:
                                                  'Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
                                            ),
                                            onCloseWindow: (controller) {
                                              Navigator.pop(context);
                                            },
                                            shouldOverrideUrlLoading:
                                                (
                                                  controller,
                                                  navigationAction,
                                                ) async {
                                                  return NavigationActionPolicy
                                                      .ALLOW;
                                                },
                                            onLoadStart: (controller, url) {
                                              setState(() {
                                                isPopupLoading = true;
                                              });
                                            },
                                            onLoadStop: (controller, url) {
                                              setState(() {
                                                isPopupLoading = false;
                                              });
                                            },
                                          ),
                                          if (isPopupLoading)
                                            const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF95062D),
                                              ),
                                            ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                          return true;
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
                                    if (intentUrl.contains(
                                      'browser_fallback_url=',
                                    )) {
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
                          if (url != null) {
                            AnalyticsService().logUrlLoad(url.toString());
                          }
                          _controller.setLoading(true);
                        },
                        onLoadStop: (controller, url) async {
                          await controller.evaluateJavascript(
                            source: WebViewScripts.hideFacebookAppBanner,
                          );
                          _controller.setLoading(false);
                          pullToRefreshController?.endRefreshing();
                          _controller.updateHistoryState();
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {
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
                ),
                Offstage(
                  offstage: _controller.currentIndex != 2,
                  child: const BrowserScreen(),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavToggle(
              currentIndex: _controller.currentIndex,
              onIndexChanged: _controller.onBottomNavIndexChanged,
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'webview',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'Menu     Hot Jamz Radio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
            // const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlansScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.gem,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Go Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Enjoy ad-free music',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 30),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.house,
                color: Colors.white70,
              ),
              title: const Text(
                'Home',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(0);
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.music,
                color: Colors.white70,
              ),
              title: const Text(
                'Playlist',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(_controller.playlistUrl);
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const Icon(
                Icons.radio,
                color: Colors.white70,
              ),
              title: const Text(
                'Live Radio',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RadioPlayerScreen(),
                  ),
                );
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.globe,
                color: Colors.white70,
              ),
              title: const Text(
                'Browser',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(2);
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.youtube,
                color: Colors.white70,
              ),
              title: const Text(
                'Youtube',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.onBottomNavIndexChanged(1);
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.bullhorn,
                color: Colors.white70,
              ),
              title: const Text(
                'Packages',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(_controller.packagesUrl);
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
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.spotify,
                color: Colors.white70,
              ),
              title: const Text(
                'Spotify',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(
                  'https://open.spotify.com/user/31363rqfdrwtthetk2bq5eafmtda',
                ); // Placeholder - update with actual link
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.apple,
                color: Colors.white70,
              ),
              title: const Text(
                'Apple Music',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl('https://music.apple.com');
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Image.asset(
                'assets/images/iheart.png',
                width: 28,
                height: 28,
              ),
              title: const Text(
                'iHeart Radio',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(_controller.iheartUrl);
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(color: Colors.white54),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 5),
              child: Text(
                'Social Media',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.facebook,
                color: Colors.white70,
              ),
              title: const Text(
                'Facebook',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(_controller.facebookUrl);
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.instagram,
                color: Colors.white70,
              ),
              title: const Text(
                'Instagram',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(_controller.instagramUrl);
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.xTwitter,
                color: Colors.white70,
              ),
              title: const Text(
                'X/Twitter',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadUrl(_controller.twitterUrl);
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(color: Colors.white54),
            ),

            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.envelope,
                color: Colors.white70,
              ),
              title: const Text(
                'Email',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                AnalyticsService().logAction('email_click');
                _launchUrl('mailto:radiohotjamz@gmail.com'); // Placeholder
              },
            ),
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: const FaIcon(
                FontAwesomeIcons.shareNodes,
                color: Colors.white70,
              ),
              title: const Text(
                'Share',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                AnalyticsService().logAction('share_app');
                Share.share(
                  'Check out Hot Jamz Radio and download our free Music Mobile Apps today! https://www.hotjamzradio.com',
                );
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
