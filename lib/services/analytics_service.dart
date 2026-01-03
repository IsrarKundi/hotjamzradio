import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      debugPrint('Analytics logAppOpen error: $e');
    }
  }

  Future<void> logPlatformSwitch(String platform) async {
    try {
      await _analytics.logEvent(
        name: 'platform_switch',
        parameters: {'platform': platform},
      );
    } catch (e) {
      debugPrint('Analytics logPlatformSwitch error: $e');
    }
  }

  Future<void> logUrlLoad(String url) async {
    try {
      // Basic sanitization to avoid logging sensitive data if any
      final sanitizedUrl = url.split('?').first;
      await _analytics.logEvent(
        name: 'webview_load',
        parameters: {'url': sanitizedUrl},
      );
      // Explicitly log as screen view to populate "Views" dashboard
      await _analytics.logScreenView(
        screenName: sanitizedUrl,
        screenClass: 'WebView',
      );
    } catch (e) {
      debugPrint('Analytics logUrlLoad error: $e');
    }
  }

  Future<void> logAction(
    String actionName, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_action',
        parameters: {'action': actionName, ...parameters ?? {}},
      );
    } catch (e) {
      debugPrint('Analytics logAction error: $e');
    }
  }

  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics logScreenView error: $e');
    }
  }
}
