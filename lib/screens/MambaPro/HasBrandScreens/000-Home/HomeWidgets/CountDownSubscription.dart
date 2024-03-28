import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Subscription.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/ActiveSubscription.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/PayWall/PayWall.dart';

class CountDownSubscription extends StatefulWidget {
  const CountDownSubscription({super.key});

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
  int globaldifference = 0;
  String monthFinalS0 = '0';
  String monthFinalS1 = '0';
  String dayFinalS0 = '0';
  String dayFinalS1 = '0';

  @override
  void initState() {
    super.initState();
    getBrandSubscription();
  }

  Future<void> getBrandSubscription() async {
    if (brandIsActive && currentBrand.subscriptionId != null) {
      int aux = 0;
      subscription = await _brandDataService.getBrandSubscription(
          currentBrand.id!, currentBrand.subscriptionId!);
      print(subscription.endDate);
      //LocalDate a = LocalDate.today();
      endDate = subscription.endDate!.toDate();
      int difference = endDate.difference(today).inDays;
      globaldifference = difference;
      print('Printing difference');
      print(difference);
      calculateMonthDay(difference, today.year, today.month, 0);
      print(monthFinal);
      print(dayFinal);
      if (monthFinal.toString().length == 2) {
        monthFinalS0 = monthFinal.toString()[0];
        monthFinalS1 = monthFinal.toString()[1];
      } else {
        monthFinalS1 = monthFinal.toString();
      }
      if (dayFinal.toString().length == 2) {
        dayFinalS0 = dayFinal.toString()[0];
        dayFinalS1 = dayFinal.toString()[1];
      } else {
        dayFinalS1 = dayFinal.toString();
      }
    }

    // var date = DateTime.fromMillisecondsSinceEpoch((subscription.startDate!) * 1000);
    // var date = new DateTime.fromMicrosecondsSinceEpoch(subscription.startDate!);
    setState(() {
      isLoading = false;
    });
  }

  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[
      31,
      -1,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    return daysInMonth[month - 1];
  }

  void calculateMonthDay(int difference, int year, int month, monthTo) {
    int aux = 0;
    aux = difference - getDaysInMonth(year, month);
    if (aux <= 0) {
      monthFinal = monthTo;
      dayFinal = difference;
    } else {
      calculateMonthDay(aux, year, month + 1, monthTo + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : FittedBox(
            fit: BoxFit.fitHeight,
            child: GestureDetector(
              onTap: navigateToSubscriptionOrPayWall,
              child: Material(
                elevation: 4,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    minWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(15.0)), // BorderRadius
                  ), // BoxDecoration
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(
                        start: 1, end: 1, bottom: 1, top: 1),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      minWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.04),
                    decoration: BoxDecoration(
                      color: brandIsActive
                          ? globaldifference < 5
                              ? AppColors.red.withOpacity(0.5)
                              : Theme.of(context).scaffoldBackgroundColor
                          : AppColors.red.withOpacity(0.5),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(15.0)), // BorderRadius
                    ), // BoxDecoration
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: navigateToSubscriptionOrPayWall,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.leaderboard_outlined,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        color: AppColors.grey,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      Text('Subscripción',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(color: AppColors.grey),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: navigateToSubscriptionOrPayWall,
                                  child: Column(
                                    children: [
                                      Text('Caducidad (Meses/días)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.width * 0.07,
                                child: Center(
                                    child: Text(
                                  monthFinalS0,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                )),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.width * 0.07,
                                child: Center(
                                    child: Text(
                                  monthFinalS1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                )),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.02),
                                child: Text(
                                  ':',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.width * 0.07,
                                child: Center(
                                    child: Text(
                                  dayFinalS0,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                )),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.02),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height:
                                    MediaQuery.of(context).size.width * 0.07,
                                child: Center(
                                    child: Text(
                                  dayFinalS1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void navigateToSubscriptionOrPayWall() async {
    if (brandIsActive) {
      await Navigator.push(
          context,
          CupertinoPageRoute<bool?>(
            builder: (context) => ActiveSubscription(
              brandId: currentBrand.id!,
              subscription: subscription,
            ),
          ));
      setState(() {
        isLoading = false;
      });
    } else {
      await Navigator.push(
          context,
          CupertinoPageRoute<bool?>(
            builder: (context) => PayWall(
              brandId: currentBrand.id!,
            ),
          ));
    }
  }
}
