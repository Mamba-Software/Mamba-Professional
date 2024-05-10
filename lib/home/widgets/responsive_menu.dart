import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';
import 'package:mamba/home/widgets/drawer/side_menu.dart';

// ignore: must_be_immutable
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
            appBar: AppBar(
              foregroundColor: context.colorScheme.background,
              backgroundColor: context.colorScheme.background,
              toolbarHeight: kToolbarHeight,
              title: Container(
                height: kToolbarHeight,
                width: context.width / 6,
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            Assets.mambaLogoIcon,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: defaultPaddingSmall),
                    Text(
                      appName,
                      style: context.textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppBarIcon(
                      icon: Icons.help_outline_outlined,
                      iconSize: iconSize,
                      color: context.colorScheme.onBackground,
                      onTap: () => navigateToMainFeedbackScreen(context),
                    ),
                    AppBarIcon(
                      icon: Icons.notifications,
                      iconSize: iconSize,
                      color: context.colorScheme.onBackground,
                      onTap: () => navigateToNotificationsScreen(context),
                    ),
                    AppBarIcon(
                      icon: Icons.chat,
                      iconSize: iconSize,
                      color: context.colorScheme.onBackground,
                      onTap: () => navigateToChatScreen(context),
                    ),
                    InkWell(
                      onTap: () => navigateToProfileScreen(context),
                      hoverColor:
                          context.colorScheme.onBackground.withOpacity(0.2),
                      splashColor:
                          context.colorScheme.onBackground.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          8,
                        ),
                        child: SizedBox(
                          height: iconSize,
                          child: Center(
                            child: CircularImage(
                              size: iconSize,
                              image: currentUser.imageUrl,
                              color: context.theme.primaryColor,
                              borderWidth: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8)
                  ],
                ),
              ],
            ),
            body: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Expanded(
                  flex: 1,
                  child: SideMenu(),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      VerticalDivider(
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
              ],
            ),
          );
        }
      },
    );
  }
}
