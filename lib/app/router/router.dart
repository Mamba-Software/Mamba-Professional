import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/admin/Admin.dart';
import 'package:mamba/auth/splash/SplashScreen.dart';
import 'package:mamba/auth/views/login.dart';
import 'package:mamba/home/views/brand_screen.dart';
import 'package:mamba/home/views/home.dart';
import 'package:mamba/user/onboarding/OnboardingScreen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      HomePage.route,
      SplashScreen.route,
      Login.route,
      OnboardingScreen.route,
      Admin.route,
      BrandScreen.route,
    ],
    errorBuilder: (context, state) {
      debugPrint('Navigation error: ${state.error}');
      debugPrint('Missing state: ${state.matchedLocation}');
      return Text('Navigation Error: ${state.error}');
    },
  );
}
