import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/widgets/side_menu/body.dart';
import 'package:mamba/home/widgets/side_menu/footer.dart';
import 'package:mamba/home/widgets/side_menu/header.dart';

class SideMenu extends StatefulWidget with PlatformMixin {
  const SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool isExtended = false;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeNavigationManager, HomeNavigationManagerState,
        bool>(
      selector: (state) => state.isExtendedDesktop,
      builder: (BuildContext context, bool stateIsExtendedDesktop) {
        double width =
            stateIsExtendedDesktop ? sideMenuWidth : collapsedSideMenuWidth;
        return Drawer(
          width: width,
          backgroundColor: context.colorScheme.background,
          surfaceTintColor: context.colorScheme.background,
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            children: [
              Header(width: width),
              Body(width: width),
              Footer(width: width),
            ],
          ),
        );
      },
    );
  }
}
