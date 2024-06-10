import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/home/widgets/side_menu/side_menu.dart';

class ResponsiveMenu extends StatelessWidget {
  final Widget child;

  ResponsiveMenu({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile || context.isTablet) {
          return Scaffold(
            key: navigationDrawerKey,
            drawer: const SideMenu(),
            body: child,
          );
        } else {
          return Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SideMenu(),
                Expanded(
                  child: Container(
                    color: context.colorScheme.background,
                    child: Row(
                      children: [
                        VerticalDivider(
                          indent: desktopAppBarHeight,
                          color: context.theme.dividerColor,
                          thickness: 1,
                          width: 1,
                        ),
                        Expanded(
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
