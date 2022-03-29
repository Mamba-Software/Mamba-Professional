import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventListTile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../../Data/Models/Event.dart';
import '../../../../../Globals/Utils/Strings/StringUtils.dart';

class UserRecentEventsWidget extends StatefulWidget {
  String userId;
  var height;
  var width;

  UserRecentEventsWidget({Key? key, required this.userId, required this.height, required this.width}) : super(key: key);

  @override
  _UserRecentEventsWidgetState createState() => _UserRecentEventsWidgetState();
}

class _UserRecentEventsWidgetState extends State<UserRecentEventsWidget> {

  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _eventDataService = new EventDataService();
  // User
  Usuario user = Usuario();
  // AlL Events From User
  List<Event> listEvents = [];

  @override
  void initState() {
    initEventHistory();
    super.initState();
  }

  Future<void> initEventHistory() async {
    await getUserDetails();
    await getUserEvents();
    setState(() {
      isLoading = false;
    });
  }

  // Gets the Events Done by the User
  Future<void> getUserDetails() async {
    user = await _userDataService.getUserCoverDetails(widget.userId);
  }

  // Gets the Events Done by the User
  Future<void> getUserEvents() async {
    listEvents = await _eventDataService.getUserFirstCompletedEventsLimit(widget.userId, 10);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context,int index) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.grey,
                highlightColor: AppColors.grey.withOpacity(0.5),
                child: Container(
                  height: widget.height*0.18,
                  width: widget.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: widget.width*0.20,
                        width: widget.width*0.20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: widget.width*0.20,
                              width: widget.width*0.20,
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
                            height: widget.height*18,
                            width: widget.width*0.56,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: widget.height*0.03,
                                  width: widget.width*0.20,
                                  decoration: new BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                SizedBox(height: widget.height*0.02,),
                                Container(
                                  height: widget.height*0.02,
                                  width: widget.width*0.35,
                                  decoration: new BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                SizedBox(height: widget.height*0.015,),
                                Container(
                                  height: widget.height*0.02,
                                  width: widget.width*0.5,
                                  decoration: new BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                SizedBox(height: widget.height*0.015,),
                                Container(
                                  height: widget.height*0.02,
                                  width: widget.width*0.5,
                                  decoration: new BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                SizedBox(height: widget.height*0.015,),
                                Container(
                                  height: widget.height*0.02,
                                  width: widget.width*0.5,
                                  decoration: new BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Container(
                            height: widget.height*15,
                            width: widget.width*0.12,
                            child: Center(
                              child: Container(
                                height: widget.height*0.05,
                                width: widget.height*0.05,
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: widget.height*0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 1,
                      width: widget.width*0.68,
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
    : Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: listEvents.length,
        itemBuilder: (context,int index) {
          Event event = listEvents[index];
          return Column(
            children: [
              EventListTile(
                eventId: event.id!,
                isTrainer: user.isTrainer!,
                height: widget.height,
                width: widget.width,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: widget.height*0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 1,
                      width: widget.width*0.68,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ), //
    );
  }
}
