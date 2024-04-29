import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/mixin/home_tile_mixin.dart';
import 'package:mamba/home/models/home_navigation_page.dart';
import 'package:mamba/home/widgets/drawer/body.dart';
import 'package:mamba/home/widgets/drawer/footer.dart';
import 'package:mamba/home/widgets/drawer/header.dart';

// ignore: must_be_immutable
class ResponsiveMenu extends StatelessWidget with HomeTileMixin {
  final Widget child;

  ResponsiveMenu({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (context.isMobile) {
          return Scaffold(
            key: mambaProScaffoldKey,
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
                  ),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                  const Body(),
                  const Divider(
                    color: AppColors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                  Footer(
                    height: context.height * 0.1,
                  ),
                ],
              ),
            ),
            body: child,
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: context.width * 0.2,
                  child: NavigationRail(
                    minWidth: context.width * 0.2,
                    minExtendedWidth: context.width * 0.3,
                    selectedIndex: 1,
                    onDestinationSelected: (int index) {
                      context.read<HomeNavigationManager>().jumpToIndex(index);
                    },
                    leading: Header(
                      height: context.height * 0.25,
                    ),
                    destinations: returnDestinations(context),
                    trailing: Footer(
                      height: context.height * 0.1,
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }

  List<NavigationRailDestination> returnDestinations(BuildContext context) {
    return <NavigationRailDestination>[
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.BOOKINGS),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.BOOKINGS),
        label: returnTextWidget(context, HomeNavigationPage.BOOKINGS),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.PAYMENTS),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.PAYMENTS),
        label: returnTextWidget(context, HomeNavigationPage.PAYMENTS),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.STATS),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.STATS),
        label: returnTextWidget(context, HomeNavigationPage.STATS),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.RATES),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.RATES),
        label: returnTextWidget(context, HomeNavigationPage.RATES),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.CLIENTS),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.CLIENTS),
        label: returnTextWidget(context, HomeNavigationPage.CLIENTS),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.STAFF),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.STAFF),
        label: returnTextWidget(context, HomeNavigationPage.STAFF),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.INFO),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.INFO),
        label: returnTextWidget(context, HomeNavigationPage.INFO),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.IMAGES),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.IMAGES),
        label: returnTextWidget(context, HomeNavigationPage.IMAGES),
      ),
      NavigationRailDestination(
        icon: returnLeadingIcon(context, HomeNavigationPage.LOCATIONS),
        selectedIcon: returnSelectedIcon(context, HomeNavigationPage.LOCATIONS),
        label: returnTextWidget(context, HomeNavigationPage.LOCATIONS),
      ),
    ];
  }
}
