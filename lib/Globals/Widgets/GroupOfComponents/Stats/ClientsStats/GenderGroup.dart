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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Constants.dart';
import '../../../../Styles/AppColors/AppColors.dart';

class GenderGroup extends StatefulWidget {
  List<Usuario> users;
  bool resize;
  var context;

  GenderGroup({
    required this.users,
    required this.resize,
    required this.context,
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

  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true, tooltipPosition: TooltipPosition.pointer);



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



    genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.male, totalMen, AppColors.mainColor));
    genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.female, totalWomen, AppColors.black));
    genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.others, totalOthers, AppColors.grey));

    genderGrouped.sort((a, b){
      if(a.total >= b.total) return 0;
      else return 1;
    });

    /*
    if((genderGrouped[0].total >= genderGrouped[1].total) && (genderGrouped[0].total >= genderGrouped[2].total)) {
      genderGrouped[0].color = AppColors.mainColor;
      genderGrouped[1].color = Colors.black;
      genderGrouped[2].color = AppColors.grey;
    }*/

    for(int i = 0; i < genderGrouped.length; ++i) {
      if(i == 0)
        {
          genderGrouped[i].color = AppColors.mainColor;
        }
      else if(i == 1)
        {
          genderGrouped[i].color = AppColors.black;
        }
      else
        {
          genderGrouped[i].color = AppColors.grey;
        }
    }

    }

    /*

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
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.others, totalOthers, AppColors.mainColor));
          explodeIndex = 2;
        }
        else
        {
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.female, totalWomen, AppColors.mainColor));
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.others, totalOthers, AppColors.mainColorTrans));

          //totalOthers i totalWomen iguals
        }
      }
      else {
        if(totalMen == totalOthers)
        {
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.female, totalWomen, AppColors.mainColor));
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.male, totalMen, AppColors.mainColorTrans));
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.others, totalOthers, AppColors.grey));
          //els tres iguals
        }
        else {
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.female, totalWomen, AppColors.mainColor));
          genderGrouped.add(new GenderGroupClass(AppLocalizations.of(widget.context)!.male, totalMen, AppColors.mainColorTrans));
          //totalMen i totalWomen igual
        }
      }
    } */


  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingView() :
    Column(
      children: [
        Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    filteredUsers.isEmpty? Column(
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
                    Container(
                        child: SfCircularChart(
                            tooltipBehavior: _tooltipBehavior,
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
                    ),
                  ],
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


