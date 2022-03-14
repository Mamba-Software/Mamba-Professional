import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class FirebaseAnalyticsProvider extends ChangeNotifier {

  // Firebase Analytics Global Var to Log Events
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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
}
