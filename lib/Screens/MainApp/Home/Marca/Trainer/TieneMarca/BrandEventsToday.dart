import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:page_transition/page_transition.dart';

class BrandEventsToday extends StatefulWidget {
  String brandId;
  BrandEventsToday({Key? key, required this.brandId}) : super(key: key);

  @override
  _BrandEventsTodayState createState() => _BrandEventsTodayState();
}

class _BrandEventsTodayState extends State<BrandEventsToday> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Brand Events Today
  List<Event> todayEvents = [];


  @override
  void initState() {
    isLoading = true;
    getAllEventsTodayBrand();
    super.initState();
  }

  // Gets the events passed by the trainer.
  void getAllEventsTodayBrand() async {
    todayEvents = await _accessDatabase.getAllEventsTodayBrand(widget.brandId);
    setState(() {
      isLoading = false;
    });
  }

  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Container(
        height: MediaQuery.of(context).size.height*0.40,
        child: Center(
          child: LoadingViewPurple(),
        ),
      )
        :
      todayEvents.length == 0 ?
        Container(
          height: MediaQuery.of(context).size.height*0.40,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 150,
                    child: Image.asset(Constants.emptyCalendar)
                ),
                Text(AppLocalizations.of(context)!.noEvents, style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
              ],
            ),
          ),
        )
            :
        ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: todayEvents.length,
          itemBuilder: (context,int index) {
            Event event = todayEvents[index];
            var startDate = DateTime(
              int.parse(event.year!),
              int.parse(event.month!),
              int.parse(event.day!),
              int.parse(event.hour!),
              int.parse(event.minute!),
            );
            if (event.minute! == "0") event.minute = "00";
            var minute;
            return Dismissible(
              direction: DismissDirection.startToEnd,
              key: Key(event.id!),
              confirmDismiss: (direction) async {
                setState(() {
                  event.isCompleted = true;
                });
                return false;
              } ,
              background: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(25.0), right: Radius.circular(25.0))
                ),
                elevation: 4,
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width*0.10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, color: Colors.white, size: 30,),
                        Text(AppLocalizations.of(context)!.finished, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height*0.13,
                child: new Card(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    //side: BorderSide(color: Styles.accent, width: 0.01),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.01),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.24,
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.07,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        event.isCompleted! ? Colors.green : Theme.of(context).primaryColor,
                                        event.isCompleted! ? Colors.white : Colors.white,
                                      ],
                                    )
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.02),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: event.isCompleted! ? Colors.green : Theme.of(context).primaryColor,
                                    size: 40,
                                  ),
                                  Text(
                                    "${event.hour}:${event.minute!}",
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold, color: event.isCompleted! ? Colors.green : Theme.of(context).primaryColor,),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(event.title!,style: Styles.purpleTextStyle.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            color: Colors.grey,
                                            size: 25,
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width*0.03),
                                          Text(
                                            durationToString(event.duration!),
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: MediaQuery.of(context).size.width*0.005),
                                          Icon(
                                            Icons.record_voice_over,
                                            color: Colors.grey,
                                            size: 25,
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width*0.03),
                                          Text(
                                            event.selectedTrainers.length.toString(),
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                          Container(
                                              height: 16,
                                              width: 32,
                                              child: VerticalDivider(color: Colors.grey, width: 10, thickness: 2,)
                                          ),
                                          Icon(
                                            Icons.directions_run,
                                            color: Colors.grey,
                                            size: 25,
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width*0.03),
                                          Text(
                                            event.joinedMembers.length.toString(),
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                          Text(
                                            " / ",
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                          Text(
                                            event.maxMembers.toString(),
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.12,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios, size: 25,),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  _viewEvent(event.id!, startDate);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
              ),
            );
        },
      );
  }

  void _viewEvent(String eventId, DateTime startDate) {
    bool canEdit = true;
    if (startDate.isBefore(DateTime.now())) {
      canEdit = false;
    }
    Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: ViewEvent(
            eventId: eventId,
            isTrainer: true,
            canEdit: canEdit,
            canJoin: false,
            locale: Localizations.localeOf(context),
          ),
        )
    );
  }
}
