import 'package:mamba/analytics/providers/analytics_provider_interface.dart';
import 'package:mamba/analytics/providers/firebase_analytics_provider.dart';
import 'package:mamba/analytics/providers/mixpanel_analytics_provider.dart';

class AnalyticsRepository {
  
  List<AnalyticsProviderInterface> providers = [];
  
  AnalyticsRepository({required bool isRelease}) {
    if (isRelease) {
      providers        
        ..add(FirebaseAnalyticsProvider())
        ..add(MixpanelAnalyticsProvider());
    }
  }  

  // User Properties
  void identify({required String userId}) {
    for (final provider in providers) {
      provider.identify(userId: userId);
    }
  }

  void registerUserProperty({required String propertyName, required String propertyValue}) {
    for (final provider in providers) {
      provider.registerUserProperty(propertyName: propertyName, propertyValue: propertyValue);
    }
  }
  
  // Event Loging
  void _logEventWithName({required String eventName}) {
    for (final provider in providers) {
      provider.logEventWithName(eventName: eventName);
    }
  }

  void _logEventWithNameAndParameters({required String eventName, required Map<String, Object> parameters}) {
    for (final provider in providers) {
      provider.logEventWithNameAndParameters(eventName: eventName, parameters: parameters);
    }
  }
  
  // Specific Events

  // AUTH
  void logIn() => _logEventWithName(eventName: 'auth_login');
  void logOut() => _logEventWithName(eventName: 'auth_logout');

  // REGISTER
  void registerStartButton() => _logEventWithName(eventName: 'register_start_button');
  void registerCredentialsButton() => _logEventWithName(eventName: 'register_credentials_button');
  void registerInfoButton() => _logEventWithName(eventName: 'register_info_button');
  void registerImagesButton() => _logEventWithName(eventName: 'register_images_button');
  void registerSuccess() => _logEventWithName(eventName: 'register_success');
  void registerSuccessLoginButton() => _logEventWithName(eventName: 'register_success_login_button');
  void registerFailure() => _logEventWithName(eventName: 'register_failure');
  void registerFailureAgainButton() => _logEventWithName(eventName: 'register_failure_again_button');

  // COMPLETE PROFILE
  void completeProfileStart() => _logEventWithName(eventName: 'complete_profile_start');
  void completeProfileInfoPage() => _logEventWithName(eventName: 'complete_profile_info_page');
  void completeProfileImagesPage() => _logEventWithName(eventName: 'complete_profile_images_page');
  void completeProfileSuccess() => _logEventWithName(eventName: 'complete_profile_success');
  void completeProfileSuccessButton() => _logEventWithName(eventName: 'complete_profile_success_button');
  void completeProfileFailure() => _logEventWithName(eventName: 'complete_profile_failure');
  void completeProfileFailureButton() => _logEventWithName(eventName: 'complete_profile_failure_button');

  // ONBOARDING
  void onboardingStartButton() => _logEventWithName(eventName: 'onboarding_start_button');
  void onboardingNextButton() => _logEventWithName(eventName: 'onboarding_next_button');
  void onboardingFinishButton() => _logEventWithName(eventName: 'onboarding_finish_button');

  // GROUPS
  void groupCreationButton() => _logEventWithName(eventName: 'group_creation_button');
  void groupCreationParticipantsButton() => _logEventWithName(eventName: 'group_creation_participants_button');
  void groupCreationInfoButton() => _logEventWithName(eventName: 'group_creation_info_button');
  void groupCreationConfirmationButton() => _logEventWithName(eventName: 'group_creation_confirmation_button');
  void groupCreationSuccess({required int participants}) =>
      _logEventWithNameAndParameters(eventName: 'group_creation_success', parameters: {'participants': participants});
  void groupCreationFailure({required int participants}) =>
      _logEventWithNameAndParameters(eventName: 'group_creation_failure', parameters: {'participants': participants});

  // ACTIVITY
  void activityCreationButton() => _logEventWithName(eventName: 'activity_creation_button');
  void activityCreationConcreteButton({required String activity}) => _logEventWithName(eventName: '${activity}_creation_button');
  void activityCreationGroupButton({required String activity}) => _logEventWithName(eventName: '${activity}_creation_group_button');

  void activityCreationParticipantsButton({required String activity}) =>
      _logEventWithName(eventName: '${activity}_creation_participants_button');
  void activityCreationTypeButton({required String activity}) => _logEventWithName(eventName: '${activity}_creation_type_button');
  void activityCreationLocationButton({required String activity}) => _logEventWithName(eventName: '${activity}_creation_location_button');
  void activityCreationInfoButton({required String activity}) => _logEventWithName(eventName: '${activity}_creation_info_button');
  void activityCreationConfirmationButton({required String activity}) =>
      _logEventWithName(eventName: '${activity}_creation_confirmation_button');
  void activityCreationSuccess({required String activity, required String type, required int participants}) =>
      _logEventWithNameAndParameters(eventName: '${activity}_creation_success', parameters: {'type': type, 'participants': participants});
  void activityCreationFailure({required String activity, required String type, required int participants}) =>
      _logEventWithNameAndParameters(eventName: '${activity}_creation_failure', parameters: {'type': type, 'participants': participants});

  // PLANS
  void planClosed({required String type, required int participants}) =>
      _logEventWithNameAndParameters(eventName: 'plan_closed', parameters: {'type': type, 'participants': participants});

  void joinEvent({required String eventType}) =>
      _logEventWithNameAndParameters(eventName: 'event_join', parameters: {'eventType': eventType});
  void leaveEvent({required String eventType}) =>
      _logEventWithNameAndParameters(eventName: 'event_leave', parameters: {'eventType': eventType});

  // CHAT
  void message() => _logEventWithName(eventName: 'message');

  // REQUESTS
  void sendRequest({required String type, required int participants}) =>
      _logEventWithNameAndParameters(eventName: 'request_send', parameters: {'type': type, 'participants': participants});
  void acceptRequest({required String type, required int participants}) =>
      _logEventWithNameAndParameters(eventName: 'request_accept', parameters: {'type': type, 'participants': participants});
  void rejectRequest({required String type, required int participants}) =>
      _logEventWithNameAndParameters(eventName: 'request_rejected', parameters: {'type': type, 'participants': participants});

  // OTHERS
  void swipe() => _logEventWithName(eventName: 'swipe');
  void share() => _logEventWithName(eventName: 'share');
  void homePage() => _logEventWithName(eventName: 'home_page');
}
