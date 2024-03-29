import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TotalBenefitPurchases extends StatefulWidget {
  List<Purchase> purchases;
  List<Purchase> backPurchases;

  TotalBenefitPurchases({
    required this.purchases,
    required this.backPurchases,
    super.key,
  });

  @override
  TotalBenefitPurchasesState createState() => TotalBenefitPurchasesState();
}

class TotalBenefitPurchasesState extends State<TotalBenefitPurchases> {
  bool isLoading = true;

  List<Purchase> filteredPurchases = [], filteredBackPurchases = [];
  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true);
  double difference = 0;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  final DateFormat formatterCat = DateFormat.MMMd('ca_CAT');
  final DateFormat formatterEsp = DateFormat.MMMd('es_ES');
  DateFormat formatter = DateFormat.MMMd('es_ES');

  List<TotalBenefit> totalBenefits = [];

  double money = 0;

  double backMoney = 0;

  @override
  void initState() {
    if (currentUser.idioma == 'es') {
      formatter = formatterEsp;
    } else if (currentUser.idioma == 'ca') {
      formatter = formatterCat;
    }
    filteredPurchases = widget.purchases;
    filteredBackPurchases = widget.backPurchases;
    orderPurchases();
    getMoney();
    calculateDifference();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(TotalBenefitPurchases oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredPurchases = widget.purchases;
    filteredBackPurchases = widget.backPurchases;
    totalBenefits = [];
    money = 0;
    backMoney = 0;
    getMoney();
    calculateDifference();
    orderPurchases();
    mountStat();
  }

  void orderPurchases() {
    return filteredPurchases.sort((a, b) {
      //sorting in ascending order
      return a.purchasedAt!.compareTo(b.purchasedAt!);
    });
  }

  calculateDifference() {
    // print(filteredBackEvents.length);
    // print(filteredEvents.length);
    if (backMoney != 0 && money != 0) {
      difference = ((money - backMoney) / ((backMoney + money) / 2)) * 100;
      if (difference != 0) {
        //  print(difference);
        difference = roundDouble(difference, 2);
      }
    } else {
      difference = 0;
    }
  }

  void getMoney() {
    for (int j = 0; j < filteredPurchases.length; ++j) {
      money = money + filteredPurchases[j].price!;
    }

    for (int j = 0; j < filteredBackPurchases.length; ++j) {
      backMoney = backMoney + filteredBackPurchases[j].price!;
    }
  }

  void mountStat() {
    TotalBenefit totalBenefit;
    String? time;
    String? time2;
    double sumBenefit = 0;
    for (int j = 0; j < filteredPurchases.length; ++j) {
      time2 = formatter.format(filteredPurchases[j].purchasedAt!.toDate());
      //print(filteredEvents[i].id);
      //print(filteredEvents[i].doneAt!.toDate());
      if (time != null && time2 != time) {
        totalBenefit = TotalBenefit(time, sumBenefit);
        totalBenefits.add(totalBenefit);
        sumBenefit = filteredPurchases[j].price!;
        if (j == filteredPurchases.length - 1) {
          totalBenefit = TotalBenefit(time2, sumBenefit);
          totalBenefits.add(totalBenefit);
        }
      } else {
        sumBenefit = sumBenefit + filteredPurchases[j].price!;
        if (j == filteredPurchases.length - 1) {
          totalBenefit = TotalBenefit(time2, sumBenefit);
          totalBenefits.add(totalBenefit);
        }
      }
      time = time2;
    }
  }

  @override
  Widget build(BuildContext context) {
    _tooltipBehavior = TooltipBehavior(enable: true, header: '');
    return isLoading
        ? LoadingView()
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        '${money.toStringAsFixed(2)}€',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: context.colorScheme.secondary,
                                fontSize: 45),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          difference < 0
                              ? '${difference.toStringAsFixed(2)}%'
                              : '+${difference.toStringAsFixed(2)}%',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                  child: Stack(
                alignment: Alignment.center,
                children: [
                  filteredPurchases.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.07),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Image.asset(Assets.emptyCalendar)),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.005),
                            Text(
                              context.l10n.noData,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05),
                          ],
                        )
                      : Container(),
                  Container(
                      child: SfCartesianChart(
                          backgroundColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          plotAreaBorderColor: Colors.transparent,
                          plotAreaBorderWidth: 1,
                          primaryXAxis: CategoryAxis(
                            //Hide the gridlines of x-axis
                            majorGridLines: const MajorGridLines(width: 0),
                            isVisible: false,
                            //Hide the axis line of x-axis
                            axisLine: const AxisLine(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            decimalPlaces: 2,
                            labelFormat: '{value}€',
                            majorTickLines: const MajorTickLines(
                              width: 0,
                            ),
                            enableAutoIntervalOnZooming: false,
                            opposedPosition: true,
                            interval: 100,
                            //maximum: double.parse(maxNumber.toString()),
                            //isVisible: false,
                            //Hide the gridlines of x-axis
                            majorGridLines: const MajorGridLines(width: 0),
                            //Hide the axis line of x-axis
                            axisLine: const AxisLine(width: 0),
                          ),
                          axes: const [],
                          indicators: const [],
                          legend: null,
                          tooltipBehavior: _tooltipBehavior,
                          enableSideBySideSeriesPlacement: false,
                          series: <ChartSeries>[
                            // Renders line chart
                            SplineAreaSeries<TotalBenefit, String>(
                              borderColor: context.colorScheme.secondary,
                              borderWidth: 2,
                              markerSettings: MarkerSettings(
                                  borderColor: context.colorScheme.secondary,
                                  isVisible:
                                      totalBenefits.length == 1 ? true : false,
                                  height: 10,
                                  width: 10,
                                  shape: DataMarkerType.circle,
                                  color: context.colorScheme.secondary),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  context.colorScheme.secondary,
                                  context.colorScheme.secondary
                                      .withOpacity(0.2),
                                ],
                              ),
                              dataSource: totalBenefits,
                              xValueMapper: (TotalBenefit events, _) =>
                                  events.day,
                              yValueMapper: (TotalBenefit events, _) =>
                                  events.money,
                            )
                          ])),
                ],
              )),
            ],
          );
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class TotalBenefit {
  TotalBenefit(this.day, this.money);
  final String day;
  final double money;
}
