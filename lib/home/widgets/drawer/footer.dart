import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/models/home_navigation_page.dart';

class Footer extends StatelessWidget with PlatformMixin {
  const Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandSuscriptionCubit, BrandSuscriptionState>(
      builder: (context, state) {
        // Sizes and Colours Used for Table and Mobile
        double height = context.height * 0.1;
        Color dividerColor = context.theme.dividerColor;
        Color backgroundColor = context.colorScheme.background;
        // Text Styles
        TextStyle titleStyle = context.textTheme.titleMedium!;
        TextStyle labelStyle = context.textTheme.labelMedium!;
        // Variables Based on the Bloc State
        String title, subtitle;
        Function onTap;
        if (state is BrandSuscriptionLoadedTrue) {
          int difference = DateTime.now()
              .difference(state.subscription.endDate!.toDate())
              .inDays;
          String date = DateTimeUtils().formatDateTimeToStringDDMMYY(
              state.subscription.endDate!.toDate());
          if (state.subscription.subscriptionId == "7DAYSTRIAL") {
            title = context.l10n.freeTrial;
            subtitle = context.l10n.freeTrialDaysLeft(difference.toString());
          } else {
            title = context.l10n.monthlyPlan;
            subtitle = context.l10n.monthlyPlanDayRenewal(date);
          }
          onTap = () => context
              .read<HomeNavigationManager>()
              .jumpToPage(HomeNavigationPage.PLAN);
        } else if (state is BrandSuscriptionLoadedFalse) {
          title = context.l10n.chooseYourPlan;
          subtitle = context.l10n.chooseYourPlanDesc;
          onTap = () => context
              .read<HomeNavigationManager>()
              .jumpToPage(HomeNavigationPage.PLAN);
        } else {
          // Return an empty container in case no relevant state is present
          return Container();
        }

        // Common Widget structure used in all states
        return Builder(builder: (context) {
          if (context.isMobile || context.isTablet) {
            return Column(
              children: [
                Divider(
                  color: dividerColor,
                  thickness: 1,
                  height: 1,
                ),
                Container(
                  height: height,
                  color: backgroundColor,
                  padding: EdgeInsets.all(defaultPaddingSmall),
                  child: Center(
                    child: ListTile(
                      title: Text(
                        title,
                        style: titleStyle,
                        textAlign: TextAlign.left,
                      ),
                      subtitle: Text(
                        subtitle,
                        style: labelStyle,
                        textAlign: TextAlign.left,
                      ),
                      onTap: () => onTap,
                    ),
                  ),
                ),
              ],
            );
          } else {
            labelStyle = context.textTheme.labelLarge!;
            return Column(
              children: [
                Divider(
                  color: dividerColor,
                  thickness: 1,
                  height: 1,
                ),
                Container(
                  height: height,
                  color: backgroundColor,
                  padding: EdgeInsets.all(defaultPaddingSmall),
                  child: Center(
                    child: ListTile(
                      title: Text(
                        title,
                        style: titleStyle,
                        textAlign: TextAlign.left,
                      ),
                      subtitle: Text(
                        subtitle,
                        style: labelStyle,
                        textAlign: TextAlign.left,
                      ),
                      onTap: () => onTap,
                    ),
                  ),
                ),
              ],
            );
          }
        });
      },
    );
  }
}
