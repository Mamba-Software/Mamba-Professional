import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/models/home_navigation_page.dart';

class Footer extends StatelessWidget with PlatformMixin {
  double height;
  double width;

  Footer({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandSuscriptionCubit, BrandSuscriptionState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case BrandSuscriptionLoadedTrue:
            final suscriptionState = state as BrandSuscriptionLoadedTrue;
            int difference = state.subscription.endDate!
                .toDate()
                .difference(DateTime.now())
                .inDays;
            String date = DateTimeUtils().formatDateTimeToStringDDMMYY(
                state.subscription.endDate!.toDate());
            TextStyle titleStyle = context.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            );
            TextStyle labelStyle = context.textTheme.labelMedium!;
            return suscriptionState.subscription.subscriptionId == "7DAYSTRIAL"
                ? Container(
                    height: height,
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Center(
                      child: ListTile(
                        title: Text(
                          context.l10n.freeTrial,
                          style: titleStyle,
                          textAlign: TextAlign.left,
                        ),
                        subtitle: Text(
                          context.l10n.freeTrialDaysLeft(difference.toString()),
                          style: labelStyle,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                        ),
                        onTap: () => context
                            .read<HomeNavigationManager>()
                            .jumpToPage(HomeNavigationPage.PLAN),
                      ),
                    ),
                  )
                : Container(
                    height: height,
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Center(
                      child: ListTile(
                        title: Text(
                          context.l10n.monthlyPlan,
                          style: titleStyle,
                          textAlign: TextAlign.left,
                        ),
                        subtitle: Text(
                          context.l10n.monthlyPlanDayRenewal(date.toString()),
                          style: labelStyle,
                          textAlign: TextAlign.left,
                        ),
                        onTap: () => context
                            .read<HomeNavigationManager>()
                            .jumpToPage(HomeNavigationPage.PLAN),
                      ),
                    ),
                  );
          case BrandSuscriptionLoadedFalse:
            TextStyle titleStyle = context.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            );
            TextStyle labelStyle = context.textTheme.labelMedium!;
            return Container(
              height: height,
              padding: const EdgeInsets.only(left: 4.0),
              child: Center(
                child: ListTile(
                  title: Text(context.l10n.chooseYourPlan,
                      style: titleStyle,
                      textAlign: TextAlign.left),
                  subtitle: Text(
                    context.l10n.chooseYourPlanDesc,
                    style: labelStyle,
                    textAlign: TextAlign.left,
                  ),
                  onTap: () => context
                      .read<HomeNavigationManager>()
                      .jumpToPage(HomeNavigationPage.PLAN),
                ),
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
