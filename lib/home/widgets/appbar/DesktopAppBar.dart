// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';
import 'package:mamba/notifications/Unread/cubit/UnreadNotChatsCubit.dart';

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
              iconSize: iconSize,
              color: context.theme.primaryColor,
              onTap: () => navigateToMainFeedbackScreen(context),
            ),
            BlocBuilder<UnreadNotChatsCubit, List<int>>(
              builder: (context, state) {
                return CounterBadgeIcon(
                  counter: state[0],
                  top: 5,
                  right: 7,
                  child: AppBarIcon(
                    icon: Icons.notifications,
                    iconSize: iconSize,
                    color: context.theme.primaryColor,
                    onTap: () => navigateToNotificationsScreen(context),
                  ),
                );
              },
            ),
            BlocBuilder<UnreadNotChatsCubit, List<int>>(
              builder: (context, state) {
                return CounterBadgeIcon(
                  counter: state[1],
                  top: 5,
                  right: 7,
                  child: AppBarIcon(
                    icon: Icons.chat,
                    iconSize: iconSize,
                    color: context.theme.primaryColor,
                    onTap: () => navigateToChatScreen(context),
                  ),
                );
              },
            ),
            InkWell(
              onTap: () => navigateToProfileScreen(context),
              hoverColor: context.theme.primaryColor.withOpacity(0.2),
              splashColor: context.theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                  24), // Optional: customize the splash radius
              child: Padding(
                padding: const EdgeInsets.all(
                    8), // Control the space around the icon
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
            
          ],
        ),
      ],
    );
  }
}
