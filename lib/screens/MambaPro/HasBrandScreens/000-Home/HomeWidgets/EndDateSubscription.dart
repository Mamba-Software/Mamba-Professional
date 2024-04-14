import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/ActiveSubscription.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';

class EndDateSubscription extends StatefulWidget {

  const EndDateSubscription({super.key});

  @override
  _EndDateSubscriptionState createState() => _EndDateSubscriptionState();
}

class _EndDateSubscriptionState extends State<EndDateSubscription> {
  DateFormat formatter = DateFormat('dd/MM/yy');
  bool ShowTextExpired = true;
  int difference = 0;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandSuscriptionCubit, BrandSuscriptionState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case BrandSuscriptionInitial:
              return Container();
            case BrandSuscriptionLoading:
              return Container();
            case BrandSuscriptionLoadedTrue:
              final suscriptionState = state as BrandSuscriptionLoadedTrue;
              difference = suscriptionState.subscription.endDate!.toDate().difference(DateTime.now()).inDays;
              return FittedBox(
                fit: BoxFit.fitHeight,
                child: suscriptionState.subscription.subscriptionId  == '7DAYSTRIAL'? freeTrialMamba() : GestureDetector(
                  onTap: () async {
                    mixpanel!.track('brand_see_active_subscription');
                    await Navigator.push(
                        context,
                        CupertinoPageRoute<bool?>(
                          builder: (context) =>
                              ActiveSubscription(
                                brandId: currentBrand.id!,
                                subscription: suscriptionState.subscription,
                              ),
                        )
                    );
                  },
                  child: Material(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                        maxWidth: MediaQuery.of(context).size.width*0.9,
                        minWidth: MediaQuery.of(context).size.width*0.9,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                      ),// BoxDecoration
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height,
                          maxWidth: MediaQuery.of(context).size.width*0.9,
                          minWidth: MediaQuery.of(context).size.width*0.9,
                        ),
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                        ),// BoxDecoration
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  Constants.subscriptionImage,),

                              ),
                              title: Text(
                                  suscriptionState.subscription.title!,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyLarge,
                                  textAlign: TextAlign.left
                              ),
                              subtitle: Text(
                                  suscriptionState.subscription.unsuscribed!? '${AppLocalizations.of(context)!.expiresAt} ${formatter.format(suscriptionState.subscription.endDate!.toDate())}' :  AppLocalizations.of(context)!.autoRenovation ,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodySmall
                              ),
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            case BrandSuscriptionLoadedFalse:
              return FittedBox(
                fit: BoxFit.fitHeight,
                child: GestureDetector(
                  onTap: () async {
                    mixpanel!.track('brand_see_paywall');
                    await navigateToPayWall(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                    height: MediaQuery.of(context).size.height*0.1,
                    width: MediaQuery.of(context).size.width*0.9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.new_releases,
                          color: Theme.of(context).colorScheme.secondary,
                          size: MediaQuery.of(context).size.width*0.10,
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                        Flexible(
                          child:  textToShow(),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                      ],
                    ),
                  ),
                ),
              );
            default:
              return Container();
          }
        }
    );
  }

  Widget textToShow()
  {
    return   Text(ShowTextExpired? AppLocalizations.of(context)!.subscriptionExpired : AppLocalizations.of(context)!.noSubscription,  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.secondary), textAlign: TextAlign.center,);
  }

  Widget freeTrialMamba()
  {
    return GestureDetector(
      onTap: () async {
        await navigateToPayWall(context);
      },
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.6), width: 2),
        ),
        child: Center(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.01),
              child: Text(
                  AppLocalizations.of(context)!.chooseYourPlan,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge!.copyWith(color: AppColors.mainColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.freeTrialDaysLeft(difference.toString()),
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall!.copyWith(color: AppColors.mainColor, fontWeight: FontWeight.normal, fontSize: 12),
            ),
            trailing: GestureDetector(
              onTap: () async {
                await navigateToPayWall(context);
              },
              child: Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(child: Text(
                  AppLocalizations.of(context)!.subscriptionsAppBar,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall!.copyWith(color:  AppColors.white, fontWeight: FontWeight.bold, fontSize: 15),
                )),
              ),
            ),
            dense: true,
          ),
        ),
      ),
    );
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            CupertinoPageRoute<bool?>(
              builder: (context) =>
                  PayWall(
                    brandId: currentBrand.id!,
                  ),
            )
        );
      },
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
            maxWidth: MediaQuery.of(context).size.width*0.9,
            minWidth: MediaQuery.of(context).size.width*0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
          ),// BoxDecoration
          child: Container(
            margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width*0.9,
              minWidth: MediaQuery.of(context).size.width*0.9,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
            ),// BoxDecoration
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      Constants.subscriptionImage,),

                  ),
                  title: Text(
                      'Disfruta de MAMBA SIN LIMITE',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge,
                      textAlign: TextAlign.left
                  ),
                  subtitle: Text(
                    'Tienes hasta el  ${formatter.format(currentBrand.endDatePay!.toDate())} para suscribirte a un plan',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
