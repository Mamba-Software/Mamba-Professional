import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/widgets/custom_appbar.dart';
import 'package:mamba/calendar/views/calendar.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/home/models/home_nav_page.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';
import 'package:mamba/home/widgets/side_menu/side_menu.dart';

class ResponsiveAddEditEvent extends StatelessWidget with PlatformMixin {
  final Widget child;

  const ResponsiveAddEditEvent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile || context.isTablet) {
          return child;
        } else {
          return Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                //const SideMenu(),
                //Calendar(),
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
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          return Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: context.width,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

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
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: sideMenuWidth),
                            child: child,
                          ),
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
