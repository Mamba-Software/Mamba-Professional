// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/events/crud_events/widgets/mobile/LinearProgressIndicator.dart';
import 'package:mamba/home/cubit/home_manager.dart';
import 'package:mamba/home/widgets/appbar/AppBarIcon.dart';
import 'package:mamba/calendar/widgets/calendar_view_dropdown.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppbar extends StatelessWidget {
  // App Bar
  final String title;
  final bool appBarExpanded;
  // Calendar View
  final CalendarView view;
  final double timeSlotViewScale;
  // Call Back Functions
  final Function() onTapToday;
  final Function() onTapBackward;
  final Function() onTapForward;
  final Function(CalendarView) onCalendarViewChanged;
  final Function(bool) onManualScaleUpdate;

  const CalendarAppbar({
    Key? key,
    // App Bar
    required this.title,
    required this.appBarExpanded,
    // Calendar View
    required this.view,
    required this.timeSlotViewScale,
    // Call Back Functions
    required this.onTapToday,
    required this.onTapBackward,
    required this.onTapForward,
    required this.onCalendarViewChanged,
    required this.onManualScaleUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.isMobile || context.isTablet) {
      // Variables
      bool hasFilter = false;
      // Sizes
      double toolbarHeight = context.height * 0.15;
      // Colors
      Color backgroundColor = AppColors.darkGrey;
      Color foregroundColor = AppColors.white;
      Color dividerColor = AppColors.grey;
      // Styles
      TextStyle titleTextStyle =
          context.textTheme.headlineMedium!.copyWith(color: foregroundColor);
      TextStyle textTextStyle =
          context.textTheme.bodyLarge!.copyWith(color: foregroundColor);
      // Return Widget
      return SliverAppBar(
        elevation: 0,
        floating: true,
        pinned: true,
        centerTitle: false,
        expandedHeight: toolbarHeight,
        surfaceTintColor: backgroundColor,
        backgroundColor: backgroundColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            height: toolbarHeight,
            color: backgroundColor,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CalendarViewDropdown(
                            view: view,
                            onViewChanged: onCalendarViewChanged,
                            zoom: timeSlotViewScale,
                            onZoomToogled: onManualScaleUpdate,
                            selectedItemBuilder: Text(
                              title,
                              style: titleTextStyle,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: onTapToday,
                                style: TextButton.styleFrom(
                                  foregroundColor: foregroundColor,
                                ),
                                child: Text(
                                  context.l10n.todayString,
                                  style: textTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: iconSizeBig,
                                width: iconSizeBig,
                                child: ClipOval(
                                  child: Material(
                                    color: hasFilter
                                        ? foregroundColor
                                        : Colors.transparent, // Button color
                                    child: InkWell(
                                      splashColor: foregroundColor
                                          .withOpacity(0.2), // Splash color
                                      onTap: () {},
                                      child: SizedBox(
                                        width: iconSizeBig,
                                        height: iconSizeBig,
                                        child: Icon(
                                          Icons.filter_list,
                                          color: hasFilter
                                              ? backgroundColor
                                              : foregroundColor,
                                          size: iconSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: defaultPadding),
                    Divider(
                      color: dividerColor,
                      height: 1.0,
                      thickness: 1.0,
                    )
                  ],
                ),
                const LinearProgressIndicatorWidget(),
              ],
            ),
          ),
          titlePadding: EdgeInsets.zero,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: foregroundColor,
            size: iconSize,
          ),
          padding: EdgeInsets.all(defaultPadding),
          onPressed: () => navigationDrawerKey.currentState?.openDrawer(),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppBarIcon(
                icon: Icons.help_outline_outlined,
                iconSize: iconSize,
                color: foregroundColor,
                onTap: () => navigateToMainFeedbackScreen(context),
              ),
              AppBarIcon(
                icon: Icons.notifications,
                iconSize: iconSize,
                color: foregroundColor,
                onTap: () => navigateToNotificationsScreen(context),
              ),
              AppBarIcon(
                icon: Icons.chat,
                iconSize: iconSize,
                color: foregroundColor,
                onTap: () => navigateToChatScreen(context),
              ),
              InkWell(
                onTap: () => navigateToProfileScreen(context),
                hoverColor: foregroundColor.withOpacity(0.2),
                splashColor: foregroundColor.withOpacity(0.2),
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
                        color: foregroundColor,
                        borderWidth: 0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: defaultPaddingSmall)
            ],
          ),
        ],
      );
    } else {
      // Variables
      bool hasFilter = false;
      // Sizes
      double toolbarHeight = desktopAppBarHeight;
      // Colors
      Color foregroundColor = context.colorScheme.onBackground;
      Color backgroundColor = context.colorScheme.background;
      // Styles
      TextStyle titleTextStyle =
          context.textTheme.bodyLarge!.copyWith(fontSize: headline1);
      TextStyle textTextStyle = context.textTheme.bodyLarge!;
      return SliverToBoxAdapter(
        child: Column(
          children: [
            AppBar(
              toolbarHeight: toolbarHeight,
              foregroundColor: backgroundColor,
              backgroundColor: backgroundColor,
              title: Row(
                children: [
                  TextButton(
                    onPressed: onTapToday,
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.background,
                      padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPaddingSmall),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: context.theme.dividerColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          borderRadiusSmall,
                        ),
                      ),
                      minimumSize: const Size(80, 45),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      context.l10n.todayString,
                      style: textTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: defaultPadding),
                  AppBarIcon(
                    icon: Icons.chevron_left,
                    iconSize: iconSize,
                    color: context.colorScheme.onBackground,
                    onTap: onTapBackward,
                  ),
                  AppBarIcon(
                    icon: Icons.chevron_right,
                    iconSize: iconSize,
                    color: context.colorScheme.onBackground,
                    onTap: onTapForward,
                  ),
                  SizedBox(width: defaultPadding),
                  Text(
                    title,
                    style: titleTextStyle,
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppBarIcon(
                      icon: Icons.filter_list,
                      iconSize: iconSize,
                      color: foregroundColor,
                      onTap: () {},
                    ),
                    SizedBox(width: defaultPadding),
                    CalendarViewDropdown(
                      view: view,
                      onViewChanged: onCalendarViewChanged,
                      zoom: timeSlotViewScale,
                      onZoomToogled: onManualScaleUpdate,
                    ),
                    SizedBox(width: defaultPadding),
                    AppBarIcon(
                      icon: Icons.help_outline_outlined,
                      iconSize: iconSize,
                      color: foregroundColor,
                      onTap: () => navigateToMainFeedbackScreen(context),
                    ),
                    AppBarIcon(
                      icon: Icons.notifications,
                      iconSize: iconSize,
                      color: foregroundColor,
                      onTap: () => navigateToNotificationsScreen(context),
                    ),
                    AppBarIcon(
                      icon: Icons.chat,
                      iconSize: iconSize,
                      color: foregroundColor,
                      onTap: () => navigateToChatScreen(context),
                    ),
                    InkWell(
                      onTap: () => navigateToProfileScreen(context),
                      hoverColor: foregroundColor.withOpacity(0.2),
                      splashColor: foregroundColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: iconSize,
                          child: Center(
                            child: CircularImage(
                              size: iconSize,
                              image: currentUser.imageUrl,
                              color: foregroundColor,
                              borderWidth: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: defaultPadding),
                  ],
                ),
              ],
            ),
            Divider(
              color: context.theme.dividerColor,
              thickness: 1,
              height: 1,
            ),
          ],
        ),
      );
    }
  }
}
