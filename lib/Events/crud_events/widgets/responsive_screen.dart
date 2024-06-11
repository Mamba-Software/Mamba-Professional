import 'package:flutter/material.dart';
import 'package:mamba/auth/widgets/custom_appbar.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ResponsiveScreen extends StatelessWidget with PlatformMixin {
  final Widget child;
  final AppBar appBar;
  final Widget floatingActionButton;

  const ResponsiveScreen(
      {super.key,
      required this.child,
      required this.appBar,
      required this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: true,
            appBar: appBar,
            body: Container(
              margin: const EdgeInsets.symmetric(horizontal: 60),
              child: child,
            ),
            floatingActionButton: floatingActionButton,
          );
        } else if (context.isTablet) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: true,
            appBar: appBar,
            body: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 60),
                constraints: const BoxConstraints(maxWidth: 1000),
                child: child,
              ),
            ),
            floatingActionButton: floatingActionButton,
          );
        } else {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: true,
            appBar: appBar,
            body: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 60),
                constraints: const BoxConstraints(maxWidth: 1000),
                child: child,
              ),
            ),
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}
