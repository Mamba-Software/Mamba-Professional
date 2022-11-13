import 'dart:math';

import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../Styles/AppColors/AppColors.dart';

class AgeRange extends StatefulWidget {
  List<Usuario> users;

  AgeRange({
    required this.users,
    Key? key,
  }) : super(key: key);

  @override
  AgeRangeState createState() => AgeRangeState();
}

class AgeRangeState extends State<AgeRange> {
  bool isLoading = true;

  // Models i base de Dades
  Brand brand = Brand();
  List <Usuario> filteredUsers = [];
  List <Usuario> users = [];

  List<int> clientsAge = [0,0,0,0,0,0,0];
  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.x,
    enablePanning: true);
  double difference = 0;

  final DateFormat formatter = DateFormat('dd-MM-yyyy');

  List<ClientsAge> clientsAgeTotalList = [];
  List<ClientsAge> allClientsAgeTotalList = [];
  final _brandDataService = BrandDataService();

  Timestamp tm = Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5)));

  int maxValue = 0;
  int maxValueInt = 0;
  String maxValueStr = '';

  int totalSumClients = 0;

  @override
  void initState() {
    filteredUsers = widget.users;
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(AgeRange oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredUsers = widget.users;
    clientsAge = [0,0,0,0,0,0,0];
    clientsAgeTotalList = [];
     maxValue = 0;
     maxValueInt = 0;
     maxValueStr = '';
    totalSumClients = 0;
    mountStat();
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  void mountStat()
  {
    int age;
    for(int i = 0; i < filteredUsers.length; ++i) {
      age = calculateAge(DateFormat('dd-MM-yy').parse(filteredUsers[i].dateOfBirth!));
      if(age < 12 )
        {
          clientsAge[0] = clientsAge[0] + 1;
        }
      else if(age >= 12 && age < 16)
        {
          clientsAge[1] = clientsAge[1] + 1;
        }
      else if(age >= 16 && age < 26)
      {
        clientsAge[2] = clientsAge[2] + 1;
      }
      else if(age >= 26 && age < 35)
      {
        clientsAge[3] = clientsAge[3] + 1;
      }
      else if(age >= 35 && age < 50)
      {
        clientsAge[4] = clientsAge[4] + 1;
      }
      else if(age >= 50 && age < 65)
      {
        clientsAge[5] = clientsAge[5] + 1;
      }
      else {
        clientsAge[6] = clientsAge[6] + 1;
      }
    }

    addDayInTotalEvent('-12', 0);
    addDayInTotalEvent('12-16', 1);
    addDayInTotalEvent('16-26', 2);
    addDayInTotalEvent('26-35', 3);
    addDayInTotalEvent('35-50', 4);
    addDayInTotalEvent('50-65', 5);
    addDayInTotalEvent('+65', 6);

    maxValueStr = maxValue.toString();

    clientsAgeTotalList = clientsAgeTotalList.reversed.toList();
    }


  void addDayInTotalEvent(String range, int number) {
    ClientsAge clientsAgeTotal;

      if (clientsAge[number] > maxValue) {
        maxValue = clientsAge[number];
      }

    clientsAgeTotal =
      new ClientsAge(range, clientsAge[number]);
      clientsAgeTotalList.add(clientsAgeTotal);


  }


  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :   Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left:  MediaQuery.of(context).size.width*0.03),
          child: Center(
                  child: Container(
                      child: SfCartesianChart(
                          onDataLabelRender:(DataLabelRenderArgs args){
                            if(args.text == maxValueStr)
                              {
                                args.textStyle = (Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.mainColor));
                              }
                            else  args.textStyle = (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColorLight));

                          },
                          zoomPanBehavior: _zoomPanBehavior,
                        backgroundColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          plotAreaBorderColor: Colors.transparent,
                          plotAreaBorderWidth: 1,
                          primaryYAxis: NumericAxis(

                            placeLabelsNearAxisLine: true,
                            //Hide the gridlines of x-axis
                            majorGridLines: MajorGridLines(width: 0),
                            isVisible: false,
                            //Hide the axis line of x-axis
                            axisLine: AxisLine(width: 0),

                          ),
                          primaryXAxis: CategoryAxis(
                            majorTickLines: MajorTickLines(
                              width: 0,
                            ),
                            labelStyle: (Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor)),
                            placeLabelsNearAxisLine: true,
                            //maximum: double.parse(maxNumber.toString()),
                            //isVisible: false,
                            //Hide the gridlines of x-axis
                            majorGridLines: MajorGridLines(width: 0),
                            //Hide the axis line of x-axis
                            axisLine: AxisLine(width: 0),
                          ),
                          axes: [],
                          indicators: [],
                          legend: null,
                         // tooltipBehavior: _tooltipBehavior,
                        enableSideBySideSeriesPlacement: false,
                        series: <ChartSeries>[

                          // Renders line chart


                          BarSeries<ClientsAge, String>(
                            spacing: 1,
                            width: 0.3,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderColor: Styles.mainColor,
                            borderWidth: 0,
                            /*
                              markerSettings: MarkerSettings(
                                  isVisible: true,
                                  height:  5,
                                  width:  5,
                                  shape: DataMarkerType.circle,
                                  color: Styles.mainColor),
*/
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                AppColors.mainColor,
                                AppColors.mainColor.withOpacity(0.2),
                              ],
                            ),
                            dataSource: clientsAgeTotalList,

                            dataLabelSettings: DataLabelSettings(isVisible: true),
                            xValueMapper: (ClientsAge events, _) => events.range,
                            yValueMapper: (ClientsAge events, _) => events.age,
                          ),
                          ]
                      )
                  )
              ),
        ),
      ],
    );

  }


}

class ClientsAge {
  ClientsAge(this.range, this.age);
  final String range;
  final int age;
}
