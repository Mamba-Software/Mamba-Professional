import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class FirebaseAnalyticsProvider extends ChangeNotifier {

  // Firebase Analytics Global Var to Log Events
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // USER ONBOARDING

  Future<void> sendAnalyticsEventOnboardUserData() async {
    await analytics.logEvent(
      name: 'onboarding_user_data',
      parameters: <String, dynamic>{
        'string': "UserDataPage",
      },
    );
    print("EVENT onboarding_user_wellcome SENT!");
  }

  Future<void> sendAnalyticsEventOnboardUserPicture() async {
    await analytics.logEvent(
      name: 'onboarding_user_picture',
      parameters: <String, dynamic>{
        'string': "PicturePage",
      },
    );
    print("EVENT onboarding_user_picture SENT!");
  }

  Future<void> sendAnalyticsEventOnboardUserPictureSelected() async {
    await analytics.logEvent(
      name: 'onboarding_user_picture_selected',
      parameters: <String, dynamic>{
        'string': "PictureSelected",
      },
    );
    print("EVENT onboarding_user_picture_selected SENT!");
  }

  Future<void> sendAnalyticsEventOnboardUserLocation() async {
    await analytics.logEvent(
      name: 'onboarding_user_location',
      parameters: <String, dynamic>{
        'string': "LocationPage",
      },
    );
    print("EVENT onboarding_user_location SENT!");
  }

  Future<void> sendAnalyticsEventOnboardUserType() async {
    await analytics.logEvent(
      name: 'onboarding_user_type',
      parameters: <String, dynamic>{
        'string': "TypeUserPage",
      },
    );
    print("EVENT onboarding_user_type SENT!");
  }

  Future<void> sendAnalyticsEventOnboardUserBrand() async {
    await analytics.logEvent(
      name: 'onboarding_user_brand',
      parameters: <String, dynamic>{
        'string': "BrandCodePage",
      },
    );
    print("EVENT onboarding_user_brand SENT!");
  }

  Future<void> sendAnalyticsEventOnboardUserFinished() async {
    await analytics.logEvent(
      name: 'onboarding_user_finished',
      parameters: <String, dynamic>{
        'string': "OnboardingFinished",
      },
    );
    print("EVENT onboarding_user_finished SENT!");
  }

  // USER CREATES NEW BRAND

  Future<void> sendAnalyticsEventCreateBrandIntro() async {
    await analytics.logEvent(
      name: 'create_brand_intro',
      parameters: <String, dynamic>{
        'string': "CreateBrandIntroPage",
      },
    );
    print("EVENT create_brand_intro SENT!");
  }

  Future<void> sendAnalyticsEventCreateBrandProfile() async {
    await analytics.logEvent(
      name: 'create_brand_profile',
      parameters: <String, dynamic>{
        'string': "CreateBrandProfilePage",
      },
    );
    print("EVENT create_brand_profile SENT!");
  }

  Future<void> sendAnalyticsEventCreateBrandInfo() async {
    await analytics.logEvent(
      name: 'create_brand_info',
      parameters: <String, dynamic>{
        'string': "CreateBrandInfoPage",
      },
    );
    print("EVENT create_brand_info SENT!");
  }

  Future<void> sendAnalyticsEventCreateBrandLocation() async {
    await analytics.logEvent(
      name: 'create_brand_location',
      parameters: <String, dynamic>{
        'string': "CreateBrandLocationPage",
      },
    );
    print("EVENT create_brand_location SENT!");
  }

  Future<void> sendAnalyticsEventCreateBrandCalendar() async {
    await analytics.logEvent(
      name: 'create_brand_calendar',
      parameters: <String, dynamic>{
        'string': "CreateBrandCalendarPage",
      },
    );
    print("EVENT create_brand_calendar SENT!");
  }

  Future<void> sendAnalyticsEventCreateBrandFinished() async {
    await analytics.logEvent(
      name: 'create_brand_finished',
      parameters: <String, dynamic>{
        'string': "CreateBrandFinished",
      },
    );
    print("EVENT create_brand_finished SENT!");
  }

  // USER ANSWERS FEEDBACK

  Future<void> sendAnalyticsUserOpenEventFeedback() async {
    await analytics.logEvent(
      name: 'user_open_event_feedback',
      parameters: <String, dynamic>{
        'string': "UserOpenEventFeedback",
      },
    );
    print("EVENT user_open_event_feedback");
  }

  Future<void> sendAnalyticsUserAnswerEventFeedbackTestA() async {
    await analytics.logEvent(
      name: 'user_answer_event_feedback_testA',
      parameters: <String, dynamic>{
        'string': "UserAnswerEventFeedbackTestA",
      },
    );
    print("EVENT user_answer_event_feedback_testA");
  }

  Future<void> sendAnalyticsUserAnswerEventFeedbackTestB() async {
    await analytics.logEvent(
      name: 'user_answer_event_feedback_testB',
      parameters: <String, dynamic>{
        'string': "UserAnswerEventFeedbackTestB",
      },
    );
    print("EVENT user_answer_event_feedback_testB");
  }

  Future<void> sendAnalyticsUserEditEventFeedbackTestA() async {
    await analytics.logEvent(
      name: 'user_edit_event_feedback_testA',
      parameters: <String, dynamic>{
        'string': "UserEditEventFeedbackTestA",
      },
    );
    print("EVENT user_edit_event_feedback_testA");
  }

  Future<void> sendAnalyticsUserEditEventFeedbackTestB() async {
    await analytics.logEvent(
      name: 'user_edit_event_feedback_testB',
      parameters: <String, dynamic>{
        'string': "UserEditEventFeedbackTestB",
      },
    );
    print("EVENT user_edit_event_feedback_testB");
  }


}
