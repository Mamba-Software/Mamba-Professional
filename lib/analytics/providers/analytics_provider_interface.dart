abstract class AnalyticsProviderInterface {

  void identify({required String userId});

  void registerUserProperty({required String propertyName, required String propertyValue});

  void logEventWithName({required String eventName});

  void logEventWithNameAndParameters({required String eventName, required Map<String, Object>? parameters});
  
}
