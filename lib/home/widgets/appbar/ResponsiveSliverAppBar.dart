// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';

class ResponsiveSliverAppBar extends StatelessWidget with PlatformMixin {
  double height;
  String title;
  bool appBarExpanded;
  Widget flexibleSpace;

  ResponsiveSliverAppBar({
    Key? key,
    required this.height,
    required this.title,
    required this.appBarExpanded,
    required this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: height,
      surfaceTintColor: AppColors.darkGrey,
      backgroundColor: AppColors.darkGrey,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      floating: true,
      pinned: true,
      centerTitle: false,
      title: AnimatedOpacity(
        opacity: appBarExpanded ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          title,
          style: context.textTheme.bodyLarge?.copyWith(color: AppColors.white),
        ),
      ),
      flexibleSpace: flexibleSpace,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          Container(
            height: 40,
            width: 40,
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
          const SizedBox(width: 24),
          Text(appName, style: context.textTheme.displayLarge),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppBarIcon(
              icon: Icons.help_outline_outlined,
              iconSize: iconSize,
              color: AppColors.white,
              onTap: () => navigateToMainFeedbackScreen(context),
            ),
            AppBarIcon(
              icon: Icons.notifications,
              iconSize: iconSize,
              color: AppColors.white,
              onTap: () => navigateToNotificationsScreen(context),
            ),
            AppBarIcon(
              icon: Icons.chat,
              iconSize: iconSize,
              color: AppColors.white,
              onTap: () => navigateToChatScreen(context),
            ),
            InkWell(
              onTap: () => navigateToProfileScreen(context),
              hoverColor: context.theme.primaryColor.withOpacity(0.2),
              splashColor: context.theme.primaryColor.withOpacity(0.2),
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
                      color: AppColors.grey,
                      borderWidth: 0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
      ],
    );

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (context.isMobile) {
        return SliverAppBar(
          expandedHeight: height,
          surfaceTintColor: AppColors.darkGrey,
          backgroundColor: AppColors.darkGrey,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          floating: true,
          pinned: true,
          centerTitle: false,
          title: AnimatedOpacity(
            opacity: appBarExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              title,
              style:
                  context.textTheme.bodyLarge?.copyWith(color: AppColors.white),
            ),
          ),
          flexibleSpace: flexibleSpace,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.white,
              size: iconSize,
            ),
            padding: const EdgeInsets.all(16),
            onPressed: () => navigationDrawerKey.currentState?.openDrawer(),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBarIcon(
                  icon: Icons.help_outline_outlined,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToMainFeedbackScreen(context),
                ),
                AppBarIcon(
                  icon: Icons.notifications,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToNotificationsScreen(context),
                ),
                AppBarIcon(
                  icon: Icons.chat,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToChatScreen(context),
                ),
                InkWell(
                  onTap: () => navigateToProfileScreen(context),
                  hoverColor: context.theme.primaryColor.withOpacity(0.2),
                  splashColor: context.theme.primaryColor.withOpacity(0.2),
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
                          color: AppColors.grey,
                          borderWidth: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8)
              ],
            ),
          ],
        );
      } else if (context.isTablet) {
        return SliverAppBar(
          expandedHeight: height,
          surfaceTintColor: AppColors.darkGrey,
          backgroundColor: AppColors.darkGrey,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          floating: true,
          pinned: true,
          centerTitle: false,
          title: AnimatedOpacity(
            opacity: appBarExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              title,
              style:
                  context.textTheme.bodyLarge?.copyWith(color: AppColors.white),
            ),
          ),
          flexibleSpace: flexibleSpace,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.white,
              size: iconSize,
            ),
            padding: const EdgeInsets.all(16),
            onPressed: () => navigationDrawerKey.currentState?.openDrawer(),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBarIcon(
                  icon: Icons.help_outline_outlined,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToMainFeedbackScreen(context),
                ),
                AppBarIcon(
                  icon: Icons.notifications,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToNotificationsScreen(context),
                ),
                AppBarIcon(
                  icon: Icons.chat,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToChatScreen(context),
                ),
                InkWell(
                  onTap: () => navigateToProfileScreen(context),
                  hoverColor: context.theme.primaryColor.withOpacity(0.2),
                  splashColor: context.theme.primaryColor.withOpacity(0.2),
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
                          color: AppColors.grey,
                          borderWidth: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12)
              ],
            ),
          ],
        );
      } else {
        return SliverAppBar(
          expandedHeight: height,
          surfaceTintColor: AppColors.darkGrey,
          backgroundColor: AppColors.darkGrey,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          floating: true,
          pinned: true,
          centerTitle: false,
          title: AnimatedOpacity(
            opacity: appBarExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              title,
              style:
                  context.textTheme.bodyLarge?.copyWith(color: AppColors.white),
            ),
          ),
          flexibleSpace: flexibleSpace,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Container(
                height: 40,
                width: 40,
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
              const SizedBox(width: 24),
              Text(appName, style: context.textTheme.displayLarge),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBarIcon(
                  icon: Icons.help_outline_outlined,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToMainFeedbackScreen(context),
                ),
                AppBarIcon(
                  icon: Icons.notifications,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToNotificationsScreen(context),
                ),
                AppBarIcon(
                  icon: Icons.chat,
                  iconSize: iconSize,
                  color: AppColors.white,
                  onTap: () => navigateToChatScreen(context),
                ),
                InkWell(
                  onTap: () => navigateToProfileScreen(context),
                  hoverColor: context.theme.primaryColor.withOpacity(0.2),
                  splashColor: context.theme.primaryColor.withOpacity(0.2),
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
                          color: AppColors.grey,
                          borderWidth: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                )
              ],
            ),
          ],
        );
      }
    });
  }
}
