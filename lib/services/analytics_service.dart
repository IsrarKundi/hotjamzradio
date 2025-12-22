import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logPlatformSwitch(String platform) async {
    await _analytics.logEvent(
      name: 'platform_switch',
      parameters: {'platform': platform},
    );
  }

  Future<void> logUrlLoad(String url) async {
    // Basic sanitization to avoid logging sensitive data if any
    final sanitizedUrl = url.split('?').first;
    await _analytics.logEvent(
      name: 'webview_load',
      parameters: {'url': sanitizedUrl},
    );
  }

  Future<void> logAction(
    String actionName, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: 'app_action',
      parameters: {'action': actionName, ...parameters ?? {}},
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
