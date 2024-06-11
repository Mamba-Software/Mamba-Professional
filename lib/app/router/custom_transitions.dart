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
        transitionsBuilder: _cupertinoTransition,
      );
    } else if (isAndroid) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: _cupertinoTransition,
      );
    } else {
      // Default transition if platform is not web, iOS, or Android
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: _cupertinoTransition,
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

  static Widget _cupertinoTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOut, 
          ),
        ),
        child: child,
      ),
    );
  }
}
