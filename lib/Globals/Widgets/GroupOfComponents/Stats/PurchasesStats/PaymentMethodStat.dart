import 'dart:math';

import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Constants.dart';
import '../../../../Styles/AppColors/AppColors.dart';

class PaymentMethodStat extends StatefulWidget {
  List<Purchase> purchases;
  var context;

  PaymentMethodStat({
    required this.purchases,
    required this.context,
    Key? key,
  }) : super(key: key);

  @override
  PaymentMethodStatState createState() => PaymentMethodStatState();
}

class PaymentMethodStatState extends State<PaymentMethodStat> {
  bool isLoading = true;

  List <Purchase> filteredPurchases = [];

  Map<String, int> mapHours = {};

  List<PaymentMethodObject> paymentMethodList = [];

  String mostPaymentMethod = '';

  TooltipBehavior _tooltipBehavior = TooltipBehavior(header: '', enable: true, tooltipPosition: TooltipPosition.pointer);

  @override
  void initState() {
    filteredPurchases = widget.purchases;
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(PaymentMethodStat oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredPurchases = widget.purchases;
    mostPaymentMethod = '';
    paymentMethodList = [];
    mapHours.clear();
    mountStat();
  }


  void mountStat() {
    int maxPM = 0;
    Purchase purchase;
    mapHours[AppLocalizations.of(widget.context)!.transferPaymentMethod] = 0;
    mapHours[AppLocalizations.of(widget.context)!.cashPaymentMethod] = 0;
    mapHours[AppLocalizations.of(widget.context)!.giftPaymentMethod] = 0;

    for (int i = 0; i < filteredPurchases.length; ++i) {
      purchase = filteredPurchases[i];
      setPM(0,purchase,AppLocalizations.of(widget.context)!.cashPaymentMethod);
      setPM(1,purchase,AppLocalizations.of(widget.context)!.transferPaymentMethod);
      setPM(2,purchase,AppLocalizations.of(widget.context)!.giftPaymentMethod);
      //setHour(21,23,"21 \n - \n 23",event);
    }

    mapHours.forEach((key, value) {
      if(value>maxPM) {
        maxPM = value;
        mostPaymentMethod = key;
      }
    });


    mapHours.forEach((k, v)
    {
      if(v == maxPM) {
        paymentMethodList.add(PaymentMethodObject(k, v, AppColors.mainColor));
      }
      else {
        paymentMethodList.add(PaymentMethodObject(k, v, AppColors.grey));
      }

    });

  }

  setPM(int paymentMethod, Purchase purchase, String paymentMethodString)
  {
    if(purchase.paymentMethod! == paymentMethod)
    {
      if (!mapHours.containsKey(paymentMethodString)) {
        mapHours[paymentMethodString] = 1;
      }
      else {
        mapHours.update(
            paymentMethodString, (value) => value + 1);
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :
    Stack(
      alignment: Alignment.center,
      children: [

        Padding(
          padding:
          EdgeInsets.only(left:  MediaQuery.of(context).size.width*0.01),
          child: Center(
              child: Container(
                  child: SfCartesianChart(
                      tooltipBehavior: _tooltipBehavior,
                      plotAreaBorderWidth: 0,

                      primaryYAxis: NumericAxis(
                        majorTickLines: MajorTickLines(
                          width: 0,
                        ),
                        labelStyle: TextStyle(color: Colors.transparent),
                        labelPosition: ChartDataLabelPosition.inside,

                        //Hide the gridlines of x-axis
                        //majorGridLines: MajorGridLines(width: 0),
                        majorGridLines: MajorGridLines(
                            dashArray: <double>[5,5]
                        ),
                        minorGridLines: MinorGridLines(
                            dashArray: <double>[5,5]
                        ),
                        isVisible: true,
                        //Hide the axis line of x-axis
                        axisLine: AxisLine(width: 0),
                        borderWidth: 0,

                      ),
                      primaryXAxis: CategoryAxis(
                        interval: 1,
                        majorTickLines: MajorTickLines(
                          width: 0,
                        ),
                        labelStyle: (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 12)),
                        placeLabelsNearAxisLine: true,
                        //maximum: double.parse(maxNumber.toString()),
                        //isVisible: false,
                        //Hide the gridlines of x-axis
                        majorGridLines: MajorGridLines(width: 0),
                        //Hide the axis line of x-axis
                        axisLine: AxisLine(width: 0),
                      ),
                      series: <ChartSeries<PaymentMethodObject, String>>[
                        ColumnSeries<PaymentMethodObject, String>(
                            dataSource: paymentMethodList,
                            xValueMapper: (PaymentMethodObject data, _) => data.paymentMethod,
                            yValueMapper: (PaymentMethodObject data, _) => data.times,
                            pointColorMapper: (PaymentMethodObject data, _) => data.color,
                            // Sets the corner radius
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        )
                      ]
                  )
              )
          ),
        ),
        filteredPurchases.isEmpty? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width*0.30,
                child: Image.asset(Constants.emptyCalendar)
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.005),
            Text(AppLocalizations.of(context)!.noData, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height*0.05),
          ],
        ) : Container(),
      ],
    );

  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

}

class PaymentMethodObject {
  PaymentMethodObject(this.paymentMethod, this.times, this.color);
  final String paymentMethod;
  final int times;
  final Color? color;
}
