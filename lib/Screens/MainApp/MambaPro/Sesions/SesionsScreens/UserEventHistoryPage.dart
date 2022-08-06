import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventListTile.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../Data/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserEventHistoryPage extends StatefulWidget {
  String userId;

  UserEventHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserEventHistoryPageState createState() => _UserEventHistoryPageState();
}

class _UserEventHistoryPageState extends State<UserEventHistoryPage> {

  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _eventDataService = new EventDataService();
  // User
  Usuario user = Usuario();
  // AlL Events From User
  List<Event> listEvents = [];
  // Index for Lazy Scroll
  int lastIndex = 9;

  @override
  void initState() {
    initEventHistory();
    super.initState();
  }

  Future<void> initEventHistory() async {
    await getUserDetails();
    await getUserFirstEvents();
    //await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      isLoading = false;
    });
  }
  
  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Gets the Events Done by the User
  Future<void> getUserDetails() async {
    user = await _userDataService.getUserCoverDetails(widget.userId);
  }

  // Gets the Events Done by the User
  Future<void> getUserFirstEvents() async {
    listEvents = await _eventDataService.getUserFirstCompletedEventsLimit(widget.userId, 10);
  }

  // Gets the Events Done by the User
  Future<void> getUserMoreEvents(String lastEventId) async {
    var temp = listEvents;
    var moreEvents = await _eventDataService.getUserMoreCompletedEventsLimit(widget.userId, lastEventId, 10);
    temp.addAll(moreEvents);
    if (mounted) {
      setState(() {
        listEvents = temp;
        lastIndex += 10;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.eventHistory,
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading ?
      Container(
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context,int index) {
            return Column(
              children: [
                index == 0 ? SizedBox(height: safeAreaWidth*0.08) : Container(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                  child: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: safeAreaHeight*0.18,
                      width: safeAreaWidth*0.9,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: (safeAreaWidth*0.9)*0.20,
                            width: (safeAreaWidth*0.9)*0.20,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: (safeAreaWidth*0.9)*0.20,
                                  width: (safeAreaWidth*0.9)*0.20,
                                  decoration: new BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                height: safeAreaHeight*18,
                                width: safeAreaWidth*0.9*0.56,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: safeAreaHeight*0.03,
                                      width: (safeAreaWidth*0.9)*0.20,
                                      decoration: new BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    SizedBox(height: safeAreaHeight*0.02,),
                                    Container(
                                      height: safeAreaHeight*0.02,
                                      width: (safeAreaWidth*0.9)*0.35,
                                      decoration: new BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    SizedBox(height: safeAreaHeight*0.015,),
                                    Container(
                                      height: safeAreaHeight*0.02,
                                      width: (safeAreaWidth*0.9)*0.5,
                                      decoration: new BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    SizedBox(height: safeAreaHeight*0.015,),
                                    Container(
                                      height: safeAreaHeight*0.02,
                                      width: (safeAreaWidth*0.9)*0.5,
                                      decoration: new BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    SizedBox(height: safeAreaHeight*0.015,),
                                    Container(
                                      height: safeAreaHeight*0.02,
                                      width: (safeAreaWidth*0.9)*0.5,
                                      decoration: new BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Container(
                                height: safeAreaHeight*15,
                                width: (safeAreaWidth*0.84)*0.12,
                                child: Center(
                                  child: Container(
                                    height: safeAreaHeight*0.05,
                                    width: safeAreaHeight*0.05,
                                    decoration: new BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: safeAreaHeight*0.04, horizontal: safeAreaWidth*0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 1,
                        width: safeAreaWidth*0.61,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      )
          :
      listEvents.length > 0 ? Container(
        child: LazyLoadScrollView(
          onEndOfPage: () {
            print("Getting more events ...");
            getUserMoreEvents(listEvents[lastIndex].id!);
          },
          scrollOffset: safeAreaHeight.toInt(),
          child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: listEvents.length,
            itemBuilder: (context,int index) {
              Event event = listEvents[index];
              return Column(
                children: [
                  index == 0 ? SizedBox(height: safeAreaWidth*0.08) : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                    child: EventListTile(
                      eventId: event.id!,
                      showFeedback: currentUser.id! == user.id! && currentUser.isTrainer == false,
                      height: safeAreaHeight,
                      width: safeAreaWidth*0.9,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: safeAreaHeight*0.04, horizontal: safeAreaWidth*0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 1,
                          width: safeAreaWidth*0.61,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ), // A subclass of `ScrollView`
        ),
      ) :
      Container(
        height: safeAreaHeight,
        width: safeAreaWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
                width: MediaQuery.of(context).size.width*0.25,
                child: Image.asset(Constants.emptyCalendar)
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.005),
            Text(AppLocalizations.of(context)!.noEvents, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height*0.12),
          ],
        ),
      ),
    );
  }
}
