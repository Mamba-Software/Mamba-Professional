import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';

class CountDownSubscription extends StatefulWidget {

  CountDownSubscription({Key? key}) : super(key: key);

  @override
  _CountDownSubscriptionState createState() => _CountDownSubscriptionState();
}

class _CountDownSubscriptionState extends State<CountDownSubscription> {
  // Step 2
  final _brandDataService = BrandDataService();
  Subscription subscription = Subscription();
  bool isLoading = true;
  String month1 = "", month2 = "", day1 = "", day2 = "";

  @override
  void initState() {
    super.initState();
    getBrandSubscription();
  }

  Future<void> getBrandSubscription() async
  {
    subscription = await _brandDataService.getBrandSubscription(currentBrand.id!);
    print(subscription.startDate);
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.04),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
            ),// BoxDecoration
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    'Tu subscripción caduca en:'
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius
                                      .circular(10),
                                ),
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.10,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.10,
                                child: Center(
                                    child: Text(
                                      '2',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                          fontWeight: FontWeight
                                              .bold, fontSize: 30,
                                          color: AppColors.black
                                      ),
                                    )

                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius
                                      .circular(10),
                                ),
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.10,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.10,
                                child: Center(
                                    child: Text(
                                      '2',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                          fontWeight: FontWeight
                                              .bold, fontSize: 30,
                                          color: AppColors.black
                                      ),
                                    )

                                ),
                              ),
                            ],
                          ),
                          Text('Meses'),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                        child: Text(
                          ':',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                              fontWeight: FontWeight
                                  .bold, fontSize: 30,
                              color: AppColors.black
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius
                                      .circular(10),
                                ),
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.10,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.10,
                                child: Center(
                                    child: Text(
                                      '2',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                          fontWeight: FontWeight
                                              .bold, fontSize: 30,
                                          color: AppColors.black
                                      ),
                                    )

                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius
                                      .circular(10),
                                ),
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.10,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.10,
                                child: Center(
                                    child: Text(
                                      '2',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline1
                                          ?.copyWith(
                                          fontWeight: FontWeight
                                              .bold, fontSize: 30,
                                          color: AppColors.black
                                      ),
                                    )

                                ),
                              ),
                            ],
                          ),
                          Text('Días'),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius
                          .circular(10),
                    ),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.90,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05,
                    child: Center(
                        child: Text(
                          'Consulta tu subscripción',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              ?.copyWith(
                              fontWeight: FontWeight
                                  .bold,
                              color: AppColors.black
                          ),
                        )

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
