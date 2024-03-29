import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';

class ResponsiveCenter extends StatelessWidget {
  final Widget child;

  const ResponsiveCenter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: kToolbarHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.background,
                  border: Border(
                    bottom: BorderSide(
                      color: context
                          .theme.dividerColor, // Color of the bottom border
                      width: 0.5, // Width of the bottom border
                    ),
                  ),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Mamba",
                    style: context.textTheme.headlineLarge,
                  ),
                ),
              ),
              Expanded(
                child: Scaffold(resizeToAvoidBottomInset: true, body: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: child,
                )),
              ),
            ],
          );
        } else if (context.isTablet) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: kToolbarHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.background,
                  border: Border(
                    bottom: BorderSide(
                      color: context
                          .theme.dividerColor, // Color of the bottom border
                      width: 0.5, // Width of the bottom border
                    ),
                  ),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Mamba",
                    style: context.textTheme.headlineLarge,
                  ),
                ),
              ),
              Expanded(
                child: Center(child: Scaffold(resizeToAvoidBottomInset: true, body: child)),
              ),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: kToolbarHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.background,
                  border: Border(
                    bottom: BorderSide(
                      color: context
                          .theme.dividerColor, // Color of the bottom border
                      width: 0.5, // Width of the bottom border
                    ),
                  ),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Mamba",
                    style: context.textTheme.headlineLarge,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: child,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
