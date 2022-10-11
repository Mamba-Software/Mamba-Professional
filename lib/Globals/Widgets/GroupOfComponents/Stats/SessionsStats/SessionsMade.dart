import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class SessionsMade extends StatefulWidget {
  SessionsMade({
    Key? key,
  }) : super(key: key);

  @override
  SessionsMadeState createState() => SessionsMadeState();
}

class SessionsMadeState extends State<SessionsMade> {
  bool isLoading = true;
  // Models i base de Dades
  Brand brand = Brand();
  final _brandDataService = BrandDataService();

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<SalesData> chartData = [
      SalesData(DateTime.now(), 35),
      SalesData(DateTime.now().add(Duration(days: 360)), 34),
      SalesData(DateTime.now().add(Duration(days: 800)), 28),
      SalesData(DateTime.now().add(Duration(days: 950)), 40),
      SalesData(DateTime.now().add(Duration(days: 1300)), 32),
    ];
    return isLoading? LoadingView() :   Center(
            child: Container(
                child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <ChartSeries>[
                      // Renders line chart
                      LineSeries<SalesData, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (SalesData sales, _) => sales.year,
                          yValueMapper: (SalesData sales, _) => sales.sales
                      )
                    ]
                )
            )
        );

  }

}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
