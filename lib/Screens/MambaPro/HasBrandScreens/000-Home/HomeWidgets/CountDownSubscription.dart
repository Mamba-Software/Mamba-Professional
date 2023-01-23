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
  DateTime endDate = DateTime.now();
  DateTime today = DateTime.now();
  DateFormat formatter = DateFormat.yMd();
  int monthFinal = 0;
  int dayFinal = 0;
  String monthFinalS0 = '0';
  String monthFinalS1 = '0';
  String dayFinalS0 = '0';
  String dayFinalS1 = '0';

  @override
  void initState() {
    super.initState();
    getBrandSubscription();
  }

  Future<void> getBrandSubscription() async
  {
    int aux = 0;
    subscription = await _brandDataService.getBrandSubscription(currentBrand.id!);
    print(subscription.endDate);
    //LocalDate a = LocalDate.today();
    endDate = subscription.endDate!.toDate();
    int difference = endDate.difference(today).inDays;
    aux = difference - getDaysInMonth(today.year, today.month);
    calculateMonthDay(difference, today.year, today.month, 0);
    print(monthFinal);
    print(dayFinal);
    if(monthFinal.toString().length == 2)
      {
         monthFinalS0 = monthFinal.toString()[0];
         monthFinalS1 = monthFinal.toString()[1];
      }
    else
      {
        monthFinalS1 = monthFinal.toString();
      }

    if(dayFinal.toString().length == 2)
    {
      dayFinalS0 = dayFinal.toString()[0];
      dayFinalS1 = dayFinal.toString()[1];
    }
    else
    {
      dayFinalS1 = dayFinal.toString();
    }

   // var date = DateTime.fromMillisecondsSinceEpoch((subscription.startDate!) * 1000);
   // var date = new DateTime.fromMicrosecondsSinceEpoch(subscription.startDate!);
    setState(() {
      isLoading = false;
    });
  }
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  void calculateMonthDay(int difference, int year, int month, monthTo)
  {
    int aux = 0;
    aux = difference - getDaysInMonth(year, month);
    if(aux <= 0)
    {
      monthFinal = monthTo;
      dayFinal = difference;
    }
    else
      {
        calculateMonthDay(aux, year , month + 1, monthTo + 1);
      }
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
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02),
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
                                    .height * 0.05,
                                child: Center(
                                    child: Text(
                                      monthFinalS0,
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
                                    .height * 0.05,
                                child: Center(
                                    child: Text(
                                      monthFinalS1,
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
                              Center(
                                child: Padding(
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
                              ),
                            ],
                          ),
                          Text('Meses'),
                        ],
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
                                    .height * 0.05,
                                child: Center(
                                    child: Text(
                                      dayFinalS0,
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
                                    .height * 0.05,
                                child: Center(
                                    child: Text(
                                      dayFinalS1,
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
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.mainColor,
                        width: 1,
                      ),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
