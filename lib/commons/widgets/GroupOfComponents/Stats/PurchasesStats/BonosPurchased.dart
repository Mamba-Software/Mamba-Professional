import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/app/styles/AppColors.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mamba/commons/managers/language_manager.dart';

class BonosPurchased extends StatefulWidget {
  List<Purchase> purchases;
  List<Bono> bonos;
  Brand brand;

  BonosPurchased({
    required this.purchases,
    required this.bonos,
    required this.brand,
    super.key,
  });

  @override
  BonosPurchasedState createState() => BonosPurchasedState();
}

class BonosPurchasedState extends State<BonosPurchased> {
  bool isLoading = true;
  int maxNumber = 4;
  // Models i base de Dades
  Brand brand = Brand();
  List<Purchase> filteredPurchase = [];
  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, zoomMode: ZoomMode.x, enablePanning: true);
  double difference = 0;
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  final DateFormat formatterCat = DateFormat.MMMd('ca_CAT');
  final DateFormat formatterEsp = DateFormat.MMMd('es_ES');
  DateFormat formatter = DateFormat.MMMd('es_ES');

  List<Bono> bonos = [];
  List<BonoStat> bonoStats = [];

  // Page View Controller
  int _numPages = 0;
  int? _currentPage;
  PageController? _pageController;

  int index = 0;

  List<BonoStat> bonoStat = [];
  final _brandDataService = BrandDataService();

  @override
  void initState() {
    if (currentUser.idioma == 'es') {
      formatter = formatterEsp;
    } else if (currentUser.idioma == 'ca') {
      formatter = formatterCat;
    }
    filteredPurchase = widget.purchases;
    bonos = widget.bonos;
    _numPages = bonos.length;
    orderBonos();
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(BonosPurchased oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredPurchase = widget.purchases;
    bonoStats = [];
    mountStat();
  }

  void orderBonos() {
    bonos.sort((a, b) {
      //sorting in ascending order
      if (a.isActive!) {
        return -1;
      } else {
        return 1;
      }
    });
  }

  void mountStat() {
    List<Purchase> purchasesList;
    BonoStat bonoStat;
    for (int i = 0; i < bonos.length; ++i) {
      purchasesList = filteredPurchase
          .where((element) => element.bonoId == bonos[i].id)
          .toList();
      bonoStat = BonoStat(purchasesList.length, getMoney(purchasesList),
          makeBonoStats(purchasesList));
      bonoStats.add(bonoStat);
    }
  }

  List<TotalBenefit> makeBonoStats(List<Purchase> purchasesList) {
    TotalBenefit totalBenefit;
    List<TotalBenefit> totalBenefits = [];
    String? time;
    String? time2;
    double sumBenefit = 0;

    purchasesList.sort((a, b) {
      //sorting in ascending order
      return a.purchasedAt!.compareTo(b.purchasedAt!);
    });
    for (int j = 0; j < purchasesList.length; ++j) {
      time2 = formatter.format(purchasesList[j].purchasedAt!.toDate());
      //print(filteredEvents[i].id);
      //print(filteredEvents[i].doneAt!.toDate());
      if (time != null && time2 != time) {
        totalBenefit = TotalBenefit(time, sumBenefit);
        totalBenefits.add(totalBenefit);
        sumBenefit = purchasesList[j].price!;
        if (j == purchasesList.length - 1) {
          totalBenefit = TotalBenefit(time2, sumBenefit);
          totalBenefits.add(totalBenefit);
        }
      } else {
        sumBenefit = sumBenefit + purchasesList[j].price!;
        if (j == purchasesList.length - 1) {
          totalBenefit = TotalBenefit(time2, sumBenefit);
          totalBenefits.add(totalBenefit);
        }
      }
      time = time2;
    }

    return totalBenefits;
  }

  double getMoney(List<Purchase> purchasesList) {
    double money = 0;
    for (int j = 0; j < purchasesList.length; ++j) {
      money = money + purchasesList[j].price!;
    }
    return money;
  }

  @override
  Widget build(BuildContext context) {
    _tooltipBehavior = TooltipBehavior(enable: true, header: '');
    return isLoading
        ? LoadingView()
        : bonos.isNotEmpty
            ? Column(
                children: [
                  bonos.length > 1
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildPageIndicator(),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                          ],
                        )
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.24,
                      minHeight: MediaQuery.of(context).size.height * 0.24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: (int page) {
                                mixpanel!.track(
                                    'brand_stats_view_fact_tab_bono_changed',
                                    properties: {
                                      'bono id': bonos[index].id,
                                      'bono title': bonos[index].title,
                                      'bono price':
                                          bonos[index].price.toString(),
                                      'bono sessions': bonos[index].sessions,
                                      'bono total invoice': bonoStats[index]
                                          .money
                                          .toStringAsFixed(2),
                                      'bono total boughts': bonoStats[index]
                                          .purchases
                                          .toStringAsFixed(2),
                                    });
                                setState(() {
                                  //bonoSelected = bonos[page];
                                  // bonoSelected.setBasicData = bonos[page];
                                  // bonoSelected.setConditionsData = bonos[page].condition!;
                                  // isBonoSelected = true;
                                  // setConditionsBono(bonoSelected);
                                  _currentPage = page;
                                  index = page;
                                });
                              },
                              itemCount: bonos.length,
                              itemBuilder: (context, index) {
                                Bono bono = bonos[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.08,
                                      right: MediaQuery.of(context).size.width *
                                          0.08,
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  child: BonoCard(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.22,
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      bono: bono,
                                      brand: widget.brand,
                                      canExpand: false,
                                      onlyView: true),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.0,
                        left: MediaQuery.of(context).size.width * 0.08,
                        right: MediaQuery.of(context).size.width * 0.08),
                    child: Column(
                      children: [
                        bonos.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.04),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${bonoStats[index].money.toStringAsFixed(2)} €',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme
                                                          .secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.benefit),
                                          ]),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              bonoStats[index]
                                                  .purchases
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme
                                                          .secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.boughts),
                                          ]),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.04),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${0.toStringAsFixed(2)} €',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme.secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.benefit),
                                          ]),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              0.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme.secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.boughts),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.05),
                          child: Center(
                              child: Stack(
                            alignment: Alignment.center,
                            children: [
                              bonos.isEmpty ||
                                      bonoStats[index].totalBenefits.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            child: Image.asset(
                                                Assets.emptyCalendar)),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.005),
                                        Text(
                                          context.l10n.noData,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05),
                                      ],
                                    )
                                  : Container(),
                              SfCartesianChart(
                                  backgroundColor: Colors.transparent,
                                  borderColor: Colors.transparent,
                                  plotAreaBorderColor: Colors.transparent,
                                  plotAreaBorderWidth: 1,
                                  primaryXAxis: CategoryAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
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
                                    interval: 50,
                                    //maximum: double.parse(maxNumber.toString()),
                                    //isVisible: false,
                                    //Hide the gridlines of x-axis
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
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
                                          //isVisible: bonos.isEmpty || bonoStats[index].totalBenefits.length == 1 ? true : false,
                                          isVisible: false,
                                          height: 10,
                                          width: 10,
                                          shape: DataMarkerType.circle,
                                          color: context.colorScheme.secondary),
                                      color: Colors.transparent,
                                      dataSource:
                                          bonoStats[index].totalBenefits,
                                      xValueMapper: (TotalBenefit events, _) =>
                                          events.day,
                                      yValueMapper: (TotalBenefit events, _) =>
                                          events.money,
                                    )
                                  ]),
                            ],
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Image.asset(Assets.emptyCalendar)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                      Text(
                        context.l10n.noData,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02,
                        bottom: MediaQuery.of(context).size.height * 0.0,
                        left: MediaQuery.of(context).size.width * 0.08,
                        right: MediaQuery.of(context).size.width * 0.08),
                    child: Column(
                      children: [
                        bonos.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.04),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${bonoStats[index].money.toStringAsFixed(2)} €',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme.secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.benefit),
                                          ]),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              bonoStats[index]
                                                  .purchases
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme.secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.boughts),
                                          ]),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.04),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${0.toStringAsFixed(2)} €',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme.secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.benefit),
                                          ]),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.25,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              0.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: context.colorScheme.secondary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(context.l10n.boughts),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 6.0 : 4.0,
      width: isActive ? 6.0 : 4.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
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

class BonoStat {
  BonoStat(this.purchases, this.money, this.totalBenefits);
  final int purchases;
  final double money;
  final List<TotalBenefit> totalBenefits;
}
