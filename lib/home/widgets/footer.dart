import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';

class Footer extends StatelessWidget with PlatformMixin {
  const Footer({
    super.key,
  });

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
            return suscriptionState.subscription.subscriptionId == "7DAYSTRIAL"
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    padding: const EdgeInsets.only(left: 4.0),
                    child: ListTile(
                        title: Text(context.l10n.freeTrial,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        subtitle: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            context.l10n
                                .freeTrialDaysLeft(difference.toString()),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        onTap: () => {
                              Navigator.pop(context),
                              setBrandActive(),
                              /*
                              setState(() {
                                pageIndex = 17;
                              }),
                              */
                            }),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    padding: const EdgeInsets.only(left: 4.0),
                    child: ListTile(
                        title: Text(context.l10n.monthlyPlan,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left),
                        subtitle: Text(
                          context.l10n.monthlyPlanDayRenewal(date.toString()),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.left,
                        ),
                        onTap: () => {
                              /*
                              Navigator.pop(context),
                              setBrandActive(),
                              setState(() {
                                pageIndex = 17;
                              }),
                              */
                            }),
                  );
          case BrandSuscriptionLoadedFalse:
            return Container(
              height: MediaQuery.of(context).size.height * 0.1,
              padding: const EdgeInsets.only(left: 4.0),
              child: ListTile(
                  title: Text(context.l10n.chooseYourPlan,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left),
                  subtitle: Text(
                    context.l10n.chooseYourPlanDesc,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.left,
                  ),
                  onTap: () => {
                        Navigator.pop(context),
                        setBrandActive(),
                        /*
                        setState(() {
                          pageIndex = 17;
                        }),
                        */
                      }),
            );
          default:
            return Container();
        }
      },
    );
  }

  Future<void> navigateToSubscriptionsScreen(BuildContext context) async {
    //mixpanel!.track('brand_membership_requests_view');
    var result = await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => PayWall(
            brandId: currentBrand.id!,
          ),
        ));
    if (result == null || result == true) {
      /*
      setState(() {
        isLoading = true;
      });
      */
    }
  }
  
}
