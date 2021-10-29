import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/CompleteEventConfirmationDialog.dart';
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
        Column(
          children: [
            Container(
              height: 1,
              color: !todayEvents[0].isCompleted! ? Theme.of(context).backgroundColor : Colors.green,
            ),
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
                var endDate = startDate.add(Duration(hours: event.duration!.toInt()));
                if (event.minute! == "0") event.minute = "00";
                var minute;
                return Column(
                  children: [
                    Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: Key(event.id!),
                      confirmDismiss: (direction) async {
                        var result = await showDialog(
                            context: context,
                            builder: (_) {
                              return CompleteEventConfirmationDialog(text: AppLocalizations.of(context)!.completeEventConfirmation);
                            }
                        );
                        if (result) {
                          setState(() {
                            isLoading = true;
                          });
                          await _accessDatabase.updateEventCompleted(event.id!);
                          getAllEventsTodayBrand();
                        }
                        return false;
                      } ,
                      background: Material(
                        //elevation: 5,
                        color: Colors.green,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: MediaQuery.of(context).size.width*0.10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.playlist_add_check, color: Colors.white, size: 30,),
                                Text(AppLocalizations.of(context)!.finished, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.13,
                        color: event.isCompleted! ? Color(0x33e5fbe5) : endDate.isBefore(DateTime.now()) ? Color(0x5EEAE4F7) : Color(0x1AF5F5F5),
                        child: Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.20,
                                  child: Row(
                                    children: [
                                      SizedBox(width: MediaQuery.of(context).size.width*0.05),
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
                                  width: MediaQuery.of(context).size.width*0.68,
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
                                                  Text(event.title!,style: Styles.purpleTextStyle.copyWith(fontSize: 18.0, fontWeight: FontWeight.bold, color: event.isCompleted! ? Colors.green : Theme.of(context).primaryColor ),),
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
                                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                  Text(
                                                    durationToString(event.duration!),
                                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                                  ),
                                                  Container(
                                                      height: 16,
                                                      width: 32,
                                                      child: VerticalDivider(color: Colors.grey, width: 10, thickness: 2,)
                                                  ),
                                                  SizedBox(width: MediaQuery.of(context).size.width*0.005),
                                                  Icon(
                                                    Icons.record_voice_over,
                                                    color: Colors.grey,
                                                    size: 25,
                                                  ),
                                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
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
                                                  SizedBox(width: MediaQuery.of(context).size.width*0.02),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_ios, size: 20,),
                                        color: Colors.grey,
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
                    ),
                    Container(
                      height: 1,
                      color: !event.isCompleted! ? Theme.of(context).backgroundColor : Colors.green,
                    ),
                  ],
                );
            },
      ),
          ],
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
