import 'dart:math';

import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
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

import '../../../../Styles/AppColors/AppColors.dart';

class GenderGroup extends StatefulWidget {
  List<Usuario> users;
  bool resize;

  GenderGroup({
    required this.users,
    required this.resize,
    Key? key,
  }) : super(key: key);

  @override
  GenderGroupState createState() => GenderGroupState();
}

class GenderGroupState extends State<GenderGroup> {
  bool isLoading = true;

  // Models i base de Dades
  Brand brand = Brand();
  List <Usuario> filteredUsers = [];

  int totalMen = 0, totalWomen = 0, totalOthers = 0;

  List<GenderGroupClass> genderGrouped = [];

  int explodeIndex = -1;

  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true, header: 'Día y número de entrenos');



  @override
  void initState() {
    filteredUsers = widget.users;
    mountStat();
    isLoading = false;
    super.initState();
  }

  @override
  void didUpdateWidget(GenderGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredUsers = widget.users;
    totalMen = 0;
    totalWomen = 0;
    totalOthers = 0;
    genderGrouped = [];
    explodeIndex = -1;
    mountStat();
  }

  void mountStat()
  {
    for(int i = 0; i < filteredUsers.length; ++i) {
     if(filteredUsers[i].gender == 0)
       {
         totalMen = totalMen + 1;
       }
     else if(filteredUsers[i].gender == 1)
       {
         totalWomen = totalWomen + 1;
       }
     else
       {
         totalOthers = totalOthers + 1;
       }
    }



    genderGrouped.add(new GenderGroupClass('Masculino', totalMen, AppColors.mainColor));
    genderGrouped.add(new GenderGroupClass('Femenino', totalWomen, AppColors.grey));
    genderGrouped.add(new GenderGroupClass('Otros', totalOthers, AppColors.black));

    genderGrouped.sort((a, b){
      if(a.total > b.total) return 0;
      else return -1;
    });

    for(int i = 0; i < genderGrouped.length; ++i) {
      if(i == 0)
        {
          genderGrouped[i].color = AppColors.mainColor;
        }
      else if(i == 1)
        {
          genderGrouped[i].color = Colors.blue.shade500;
        }
      else
        {
          genderGrouped[i].color = AppColors.grey;
        }
    }

    }

    checkWhosBigger()
    {
      if(totalMen > totalWomen)
      {
        if(totalMen > totalOthers)
        {
          //totalMen el mes gran
          explodeIndex = 0;
        }
        else if (totalMen < totalOthers)
        {
          //totalOthers el mes gran
          explodeIndex = 2;

        }
        else
        {
          //totalOthers i totalMen iguals
        }
      }
      else if (totalMen < totalWomen)
      {
        if(totalWomen > totalOthers)
        {
          //totalWomen el mes gran
            explodeIndex = 1;
        }
        else if (totalWomen < totalOthers)
        {
          //totalOthers el mes gran
          genderGrouped.add(new GenderGroupClass('Otros', totalOthers, AppColors.mainColor));
          explodeIndex = 2;
        }
        else
        {
          genderGrouped.add(new GenderGroupClass('Femenino', totalWomen, AppColors.mainColor));
          genderGrouped.add(new GenderGroupClass('Otros', totalOthers, AppColors.mainColorTrans));

          //totalOthers i totalWomen iguals
        }
      }
      else {
        if(totalMen == totalOthers)
        {
          genderGrouped.add(new GenderGroupClass('Femenino', totalWomen, AppColors.mainColor));
          genderGrouped.add(new GenderGroupClass('Masculino', totalMen, AppColors.mainColorTrans));
          genderGrouped.add(new GenderGroupClass('Otros', totalOthers, AppColors.grey));
          //els tres iguals
        }
        else {
          genderGrouped.add(new GenderGroupClass('Femenino', totalWomen, AppColors.mainColor));
          genderGrouped.add(new GenderGroupClass('Masculino', totalMen, AppColors.mainColorTrans));
          //totalMen i totalWomen igual
        }
      }
    }


  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :
    Column(
      children: [
        Center(
                child: Container(
                    child: SfCircularChart(
                      title: ChartTitle(text:widget.resize? 'Total' : 'Filtrat', textStyle: Theme.of(context).textTheme.bodyText1),
                        legend: Legend(isVisible: true,position: LegendPosition.bottom, textStyle: Theme.of(context).textTheme.bodyText2),
                        series: <CircularSeries>[
                          // Render pie chart
                          PieSeries<GenderGroupClass, String>(
                              radius: widget.resize? '100%' : '100%',
                              dataSource: genderGrouped,
                              pointColorMapper:(GenderGroupClass data,  _) => data.color,
                              xValueMapper: (GenderGroupClass data, _) => data.gender,
                              yValueMapper: (GenderGroupClass data, _) => data.total
                          ),

                        ]
                    ),
                )
            ),
      ],
    );

  }


}

class GenderGroupClass {
  GenderGroupClass(this.gender, this.total, this.color);
final String gender;
final int total;
Color? color;
}


