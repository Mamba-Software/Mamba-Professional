import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mamba/analytics/providers/analytics_provider_interface.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelAnalyticsProvider implements AnalyticsProviderInterface {
  
  Mixpanel? _mixpanel;

  MixpanelAnalyticsProvider() {
    _init();
  }

  Future<void> _init() async {
    _mixpanel = await Mixpanel.init(
      dotenv.env['MIXPANEL_KEY']!,
      trackAutomaticEvents: true,
      optOutTrackingDefault: false,
    );
  }

  void _ensureInitialized() {
    if (_mixpanel == null) {
      throw Exception('Mixpanel has not been initialized.');
    }
  }

  @override
  void identify({required String userId}) {
    _ensureInitialized();
    _mixpanel!.identify(userId);
  }

  @override
  void registerUserProperty({required String propertyName, required dynamic propertyValue}) {
    _ensureInitialized();
    _mixpanel!.getPeople().set(propertyName, propertyValue);
  }

  @override
  void logEventWithName({required String eventName}) {
    _ensureInitialized();
    _mixpanel!.track(eventName);
  }

  @override
  void logEventWithNameAndParameters({required String eventName, required Map<String, Object>? parameters}) {
    _ensureInitialized();
    _mixpanel!.track(eventName, properties: parameters);
  }
}
