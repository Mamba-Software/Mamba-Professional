import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamba/commons/mixins/platform.dart';

class CustomTransitions with PlatformMixin {
  
  static final CustomTransitions _instance = CustomTransitions._internal();
  CustomTransitions._internal();

  static CustomTransitions get instance => _instance;
  
  Page<void> customTransitionPage({
    required Widget child,
    required GoRouterState state,
  }) {
    // Different transitions for different platforms
    if (isWeb) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: _webTransition,
      );
    } else if (isIOS) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: _iosTransition,
      );
    } else if (isAndroid) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: _androidTransition,
      );
    } else {
      // Default transition if platform is not web, iOS, or Android
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: _defaultTransition,
      );
    }
  }

  static Widget _webTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget _iosTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}

static Widget _androidTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}

static Widget _defaultTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animation),
    child: child,
  );
}
}
