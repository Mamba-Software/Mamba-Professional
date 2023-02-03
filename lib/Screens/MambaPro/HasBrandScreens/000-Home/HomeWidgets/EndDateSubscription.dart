import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';

import '../../../../../Globals/Widgets/GroupOfComponents/PayWall/ActiveSubscription.dart';

class EndDateSubscription extends StatefulWidget {

  EndDateSubscription({Key? key}) : super(key: key);

  @override
  _EndDateSubscriptionState createState() => _EndDateSubscriptionState();
}

class _EndDateSubscriptionState extends State<EndDateSubscription> {
  // Step 2
  final _brandDataService = BrandDataService();
  Subscription subscription = Subscription();
  bool isLoading = true;
  DateFormat formatter = DateFormat('dd/MM/yy');
  bool ShowTextExpired = false;


  @override
  void initState() {
    super.initState();
    checkBrandActive();
    getBrandSubscription();
  }

  void checkBrandActive()
  {
    if(currentBrand.endDatePay != null)
    {
      if(DateTime.now().compareTo(currentBrand.endDatePay!.toDate()) < 0)
      {
      }
      else
      {
        ShowTextExpired = true;
      }
    }
  }

  Future<void> getBrandSubscription() async
  {
    if(brandIsActive && currentBrand.subscriptionId != null) {
      subscription =
      await _brandDataService.getBrandSubscription(currentBrand.id!, currentBrand.subscriptionId!);
    }

   // var date = DateTime.fromMillisecondsSinceEpoch((subscription.startDate!) * 1000);
   // var date = new DateTime.fromMicrosecondsSinceEpoch(subscription.startDate!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? Container() : FittedBox(
      fit: BoxFit.fitHeight,
      child: !brandIsActive? GestureDetector(
        onTap: navigateToSubscriptionOrPayWall,
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
      ) : GestureDetector(
        onTap: navigateToSubscriptionOrPayWall,
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
              color: Theme.of(context).backgroundColor,
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
                        subscription.title!,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1,
                        textAlign: TextAlign.left
                    ),
                    subtitle: Text(
                        AppLocalizations.of(context)!.expiresAt + ' ' + formatter.format(currentBrand.endDatePay!.toDate()).toString(),
                        style: Theme
                            .of(context)
                            .textTheme
                            .caption
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
  }

  Widget textToShow()
  {
    return   Text(ShowTextExpired? AppLocalizations.of(context)!.subscriptionExpired : AppLocalizations.of(context)!.noSubscription,  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary), textAlign: TextAlign.center,);
  }

  void navigateToSubscriptionOrPayWall()
  async {
    if(brandIsActive) {
      mixpanel!.track('brand_see_active_subscription');
      await Navigator.push(
          context,
          CupertinoPageRoute<bool?>(
            builder: (context) =>
                ActiveSubscription(
                  brandId: currentBrand.id!,
                  subscription: subscription,
                ),
          )
      );
      setState(() {
        isLoading = false;
      });
    }
    else {
      mixpanel!.track('brand_see_paywall');
      await Navigator.push(
          context,
          CupertinoPageRoute<bool?>(
            builder: (context) =>
                PayWall(
                  brandId: currentBrand.id!,
                ),
          )
      );
    }
  }
}
