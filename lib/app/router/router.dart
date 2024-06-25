import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/admin/Admin.dart';
import 'package:mamba/auth/splash/splash_screen.dart';
import 'package:mamba/auth/views/login.dart';
import 'package:mamba/home/views/home.dart';
import 'package:mamba/user/onboarding/OnboardingScreen.dart';

class AppRouter {  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/loading',
    routes: [
      Admin.route,
      SplashScreen.route,
      Login.route,
      Onboarding.route,            
      HomePage.route,            
    ],
    errorBuilder: (context, state) {
      debugPrint('Navigation error: ${state.error}');
      debugPrint('Missing state: ${state.matchedLocation}');
      return Text('Navigation Error: ${state.error}');
    },
  );
}
