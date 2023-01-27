import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandEventCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';

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
      child: brandIsActive? GestureDetector(
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
                child:  Text(
                  brandIsActive? 'Tu subscripción caduca el dia ' + currentBrand.endDatePay!.toString() : ShowTextExpired? 'Tu subscripción ha caducado, pulsa para renovar' : 'No tienes subscricpión, pulsa para adquirir una',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary),
                  textAlign: TextAlign.center,
                ),
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
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.04,
                      width: MediaQuery.of(context).size.width*0.9,
                      child:  TextButton(
                        onPressed: navigateToSubscriptionOrPayWall,
                        child: Text(
                            'Tu subscripción caduca el ' + formatter.format(currentBrand.endDatePay!.toDate()).toString(),
                            style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.grey),
                            textAlign: TextAlign.center
                        ),
                      ),
                    ),
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
    return   Text(brandIsActive? 'Tu subscripción caduca el dia ' + currentBrand.endDatePay!.toString() : ShowTextExpired? 'Tu subscripción ha caducado, pulsa para renovar' : 'No tienes subscricpión, pulsa para adquirir una', style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.center,);
  }

  void navigateToSubscriptionOrPayWall()
  async {
    if(brandIsActive) {
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
