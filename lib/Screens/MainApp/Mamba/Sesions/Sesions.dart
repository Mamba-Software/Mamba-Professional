import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/SesionsScreens/UserCalendarMonthWidget.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/SesionsScreens/UserEventHistoryPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Sesions/SesionsScreens/UserRecentEventsWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Sesions extends StatefulWidget {
  Sesions({Key? key}) : super(key: key);

  @override
  _SesionsState createState() => _SesionsState();
}

class _SesionsState extends State<Sesions> {
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
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

  // Navigate to Event History Screen
  void navigateToEventHistoryScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
            builder: (context) => UserEventHistoryPage(
              userId: currentUser.id!,
            )
        )
    );
  }

  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }
    return Scaffold (
      appBar:  AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: SafeArea(
        right: false,
        left: false,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
            child: Column(
              children: [
                Container(
                  height: safeAreaHeight*0.6,
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: safeAreaHeight*0.02,),
                      UserCalendarMonthWidget(
                        userId: currentUser.id!,
                        height: safeAreaHeight*0.56,
                        width: safeAreaWidth*0.9,
                      ),
                      SizedBox(height: safeAreaHeight*0.02,),
                    ],
                  ),
                ),
                Container(
                  height: safeAreaHeight*0.08,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          AppLocalizations.of(context)!.recentEvents,
                          style: Theme.of(context).textTheme.headline3!.copyWith(color: AppColors.grey, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center
                      ),
                      FloatingActionButton.extended(
                        heroTag: "86",
                        onPressed: navigateToEventHistoryScreen,
                        backgroundColor: Theme.of(context).accentColor,
                        icon: Icon(
                          Icons.description,
                          color: AppColors.white,
                          size: safeAreaWidth*0.05,
                        ),
                        label: Text(
                            AppLocalizations.of(context)!.eventHistory,
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: safeAreaHeight*0.04,),
                UserRecentEventsWidget(
                  userId: currentUser.id!,
                  height: safeAreaHeight,
                  width: safeAreaWidth*0.9,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

