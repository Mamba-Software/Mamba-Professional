import 'package:flutter/widgets.dart';
import 'package:mamba_castelldefels/Stripe/views/onboarding_webview.dart';

class AppRoutes {
  static const String brandsList = '/brandsList';
  static const String usersList = '/usersList';
  static const String brandProfile = '/brandProfile';
  static const String onboarding = '/onboarding';
  static const String brandServices = '/brandServices';

  static Map<String, Widget Function(BuildContext)> routes = {
    onboarding: (context) {
      return OnboardingWebView();
    }
  };
}
