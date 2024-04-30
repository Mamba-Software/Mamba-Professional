// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';

class DesktopAppBar extends StatelessWidget with PlatformMixin {
  const DesktopAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      surfaceTintColor: context.theme.scaffoldBackgroundColor,
      elevation: 4,
      title: Row(
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
          const SizedBox(width: 15),
          Text(appName, style: context.textTheme.displayLarge),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppBarIcon(
              icon: Icons.help_outline_outlined,
              iconSize: iconSizeBig,
              color: context.theme.primaryColor,
              onTap: () => navigateToMainFeedbackScreen(context),
            ),
            AppBarIcon(
              icon: Icons.help_outline_outlined,
              iconSize: iconSizeBig,
              color: context.theme.primaryColor,
              onTap: () => navigateToMainFeedbackScreen(context),
            ),
            AppBarIcon(
              icon: Icons.help_outline_outlined,
              iconSize: iconSizeBig,
              color: context.theme.primaryColor,
              onTap: () => navigateToMainFeedbackScreen(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () => navigateToProfileScreen(context),
                child: SizedBox(
                  height: iconSizeBig,
                  child: Center(
                    child: CircularImage(
                      size: iconSizeBig,
                      image: currentUser.imageUrl,
                      color: AppColors.grey,
                      borderWidth: 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16)
          ],
        ),
      ],
    );
  }
}
