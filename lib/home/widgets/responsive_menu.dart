import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/mixin/home_tile_mixin.dart';
import 'package:mamba/home/models/home_navigation_page.dart';
import 'package:mamba/home/widgets/body.dart';
import 'package:mamba/home/widgets/footer.dart';
import 'package:mamba/home/widgets/header.dart';

// ignore: must_be_immutable
class ResponsiveMenu extends StatelessWidget with HomeTileMixin {
  final Widget child;

  ResponsiveMenu({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile || context.isTablet) {
          return Scaffold(
            key: navigationDrawerKey,
            drawer: Drawer(
              surfaceTintColor: context.theme.scaffoldBackgroundColor,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: Column(
                children: [
                  Header(
                    height: context.height * 0.25,
                    // Standard Size of a Drawer in Flutter
                    width: 304,
                  ),
                  const Body(),
                  Footer(
                    height: context.height * 0.1,
                    // Standard Size of a Drawer in Flutter
                    width: 304,
                  ),
                ],
              ),
            ),
            body: child,
          );
        } else {
          return Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 304,
                  child: Column(
                    children: [
                      Header(
                        height: 250,
                        // Standard Size of a Drawer in Flutter
                        width: 304,
                      ),
                      const Body(),
                      Footer(
                        height: 80,
                        // Standard Size of a Drawer in Flutter
                        width: 304,
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                    color: context.theme.dividerColor, thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }
}
