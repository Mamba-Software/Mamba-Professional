import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mamba/analytics/providers/analytics_provider_interface.dart';

class FirebaseAnalyticsProvider implements AnalyticsProviderInterface {
  static final _firebaseAnalytics = FirebaseAnalytics.instance;

  @override
  void identify({required String userId}) {
    _firebaseAnalytics.setUserId(id: userId);
  }

  @override
  void registerUserProperty({required String propertyName, required String propertyValue}) {
    _firebaseAnalytics.setUserProperty(name: propertyName, value: propertyValue);
  }

  @override
  void logEventWithName({required String eventName}) {
    _firebaseAnalytics.logEvent(name: eventName);
  }

  @override
  void logEventWithNameAndParameters({required String eventName, required Map<String, Object>? parameters}) {
    _firebaseAnalytics.logEvent(name: eventName, parameters: parameters);
  }
  
}
