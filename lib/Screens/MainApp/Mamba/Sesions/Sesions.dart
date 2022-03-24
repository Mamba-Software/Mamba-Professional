import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventListTile.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/SesionsScreens/UserCalendarMonthWidget.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/SesionsScreens/UserEventHistoryWidget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class Sesions extends StatefulWidget {
  Sesions({Key? key}) : super(key: key);

  @override
  _SesionsState createState() => _SesionsState();
}

class _SesionsState extends State<Sesions> {
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Acceso a Base de Datos
  var _eventDataService = new EventDataService();
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Event List
  List<Event> listEvents = [];

  @override
  void initState() {
    isLoading = true;
    super.initState();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return Scaffold (
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sesionsBottomNav, style: Theme.of(context).textTheme.headline1,),
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        right: false,
        left: false,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    height: safeAreaHeight*0.02,
                  ),
                  UserCalendarMonthWidget(
                    userId: currentUser.id!,
                    height: safeAreaHeight*0.4,
                    width: safeAreaWidth*0.9,
                  ),
                  Container(
                    height: safeAreaHeight*0.02,
                  ),
                ],
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      height: safeAreaHeight*0.08,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                          AppLocalizations.of(context)!.eventHistory,
                          style: Theme.of(context).textTheme.headline3!.copyWith(color: AppColors.grey, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: safeAreaHeight*0.01,
                    ),
                    UserEventHistoryWidget(
                      userId: currentUser.id!,
                      height: safeAreaHeight,
                      width: safeAreaWidth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

