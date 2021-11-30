import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/chatDetailPage.dart';
import 'package:page_transition/page_transition.dart';

import '../../Constants.dart';
import '../../Styles.dart';
import '../LoadingViewPurple.dart';

class ProfileViewUser extends StatefulWidget {
  @override
  String userID;
  bool viewOnly;
  ProfileViewUser({Key? key, required this.userID, required this.viewOnly}) : super(key: key);
  _ProfileViewUserState createState() => _ProfileViewUserState();
}

class _ProfileViewUserState extends State<ProfileViewUser> with SingleTickerProviderStateMixin {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Usuario
  Usuario? user;
  // Birthday
  int birthday = 0;
  // Event List
  int totalEvents  = 0;
  int thisMonthEvents  = 0;
  List<Event> listEvents = [];

  // init Widget state. Loading user info.
  @override
  void initState() {
    isLoading = true;
    getUser();
    super.initState();
  }
  // Gets the user info from firebase.
  void getUser() async {
    user = await _accessDatabase.getUserDetails(widget.userID);
    if (user!.isTrainer!) {
      getTrainerEventsDone();
    } else {
      getClientEventsDone();
    }
  }

  // Gets the events passed by the trainer.
  void getTrainerEventsDone() async {
    DateTime today = DateTime.now();
    var tempMonth = 0;
    List<Event> list = await _accessDatabase.getAllEventsFromTrainer(widget.userID);
    for (var i=0; i<list.length; i++) {
      Event event = list[i];
      int year = int.parse(event.year!);
      int month = int.parse(event.month!);
      int day = int.parse(event.day!);
      if (year <= today.year && month <= today.month && day < today.day) {
        listEvents.add(event);
        if (year == today.year && month == today.month) {
          tempMonth += 1;
        }
      }
    }
    setState(() {
      thisMonthEvents = tempMonth;
      totalEvents = listEvents.length;
      isLoading = false;
    });
  }
  // Gets the events passed by the trainer.
  void getClientEventsDone() async {
    DateTime today = DateTime.now();
    var tempMonth = 0;
    List<Event> list = await _accessDatabase.getAllEventsFromClient(widget.userID);
    for (var i=0; i<list.length; i++) {
      Event event = list[i];
      int year = int.parse(event.year!);
      int month = int.parse(event.month!);
      int day = int.parse(event.day!);
      if (year <= today.year && month <= today.month && day < today.day) {
        listEvents.add(event);
        if (year == today.year && month == today.month) {
          tempMonth += 1;
        }
      }
    }
    setState(() {
      thisMonthEvents = tempMonth;
      totalEvents = listEvents.length;
      isLoading = false;
    });
  }

  // Calculate Age
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

  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profileBottomNav, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor, //change your color here
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Styles.accent),
            onPressed: () => {
              Navigator.pop(context)
            },
          ),
          actions: [
            !isLoading ?
            widget.viewOnly || user!.id! == currentUser.id ? Container() : Padding(
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.03),
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child:
                  ChatDetailPage(user!)
                  ),
                  );
                } ,
                icon: Icon(Icons.chat_outlined)
              ),
            ) : Container()
          ],
        ),
        body: isLoading ?
        LoadingViewPurple()
            :
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              CircularImage(size: MediaQuery.of(context).size.width*0.45, image: user!.imageUrl, borderWidth: 1.5,),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              Text(
                user!.name!,
                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "@${user!.nick!}",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    user!.gender == 2 ? Icons.transgender_outlined : user!.gender == 0 ? Icons.male_outlined : Icons.female_outlined,
                    color: Theme.of(context).accentColor,
                    size: 25,
                  ),
                  SizedBox(width: 2),
                  Text(
                    user!.gender == 2 ? AppLocalizations.of(context)!.transgender : user!.gender == 0 ? AppLocalizations.of(context)!.male : AppLocalizations.of(context)!.female,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).accentColor),
                  ),
                  Container(
                    height: 16,
                    width: 32,
                    child: VerticalDivider(color: Theme.of(context).accentColor, width: 10, thickness: 2,)
                  ),
                  Icon(
                    Icons.cake,
                    color: Theme.of(context).accentColor,
                    size: 25,
                  ),
                  SizedBox(width: 2),
                  Text(
                    user!.dateOfBirth!,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).accentColor),
                  ),
                  Container(
                      height: 16,
                      width: 32,
                      child: VerticalDivider(color: Theme.of(context).accentColor, width: 10, thickness: 2,)
                  ),
                  Icon(
                    user!.isTrainer! ?  Icons.record_voice_over : Icons.directions_run,
                    color: Theme.of(context).accentColor,
                    size: 25,
                  ),
                  user!.isTrainer! ? SizedBox(width: 4) : SizedBox(width: 2),
                  Text(
                    user!.isTrainer! ?  AppLocalizations.of(context)!.trainer : AppLocalizations.of(context)!.client,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).accentColor),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    //elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.81,
                      height: MediaQuery.of(context).size.height * 0.10,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        //border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.10,
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  totalEvents.toString(),
                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.allEvents,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            height: MediaQuery.of(context).size.height * 0.03,
                            child: VerticalDivider(color: Theme.of(context).primaryColor,),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.10,
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  thisMonthEvents.toString(),
                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.monthEvents,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              listEvents.length != 0 ? Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: listEvents.length,
                    itemBuilder: (context,int index) {
                      Event event = listEvents[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02),
                        child: ListTile(
                          onTap: () {
                            if (currentUser.isTrainer!) {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.bottomToTop,
                                      child: ViewEventTrainer(
                                        eventId: event.id!,
                                        canEdit: false,
                                        locale: Localizations.localeOf(context),
                                      )
                                  )
                              );
                            } else {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.bottomToTop,
                                      child: ViewEventClient(
                                        eventId: event.id!,
                                        canJoin: false,
                                        locale: Localizations.localeOf(context),
                                      )
                                  )
                              );
                            }
                          },
                          leading: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.event_available,
                                color: Theme.of(context).primaryColor,
                                size: 25,
                              ),
                              Text(
                                "${event.day}/${event.month}/${event.year!.substring(2, 4)}",
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12.0, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "${event.hour.toString()}:${event.minute=="0" ? "00" : event.minute.toString()}",
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12.0, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          title: Text(event.title!,style: Styles.purpleTextStyle.copyWith(fontSize: 18.0, fontWeight: FontWeight.w600),),
                          subtitle: Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    durationToString(event.duration!),
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                  Container(
                                      height: 16,
                                      width: 32,
                                      child: VerticalDivider(color: Colors.grey, width: 10, thickness: 2,)
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.record_voice_over,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
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
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
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
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ],
              )
                :
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 120),
                    height: MediaQuery.of(context).size.height*0.49,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: Container(
                              height: MediaQuery.of(context).size.height*0.15,
                              child: Image.asset(Constants.emptyCalendar)
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.20),
                          child: Text(AppLocalizations.of(context)!.noTrainingsDone, style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080), fontSize: 16), textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

/*
Container(
                              height: MediaQuery.of(context).size.height*0.15,
                              child: new Card(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                /*elevation: 5,
                                shape: RoundedRectangleBorder(
                                  //side: BorderSide(color: Styles.accent, width: 0.01),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                */
                                //margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.02, MediaQuery.of(context).size.width*0.01, MediaQuery.of(context).size.width*0.02, MediaQuery.of(context).size.width*0.01),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.24,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.event_available,
                                              color: Theme.of(context).primaryColor,
                                              size: 40,
                                            ),
                                            Text(
                                              "${event.day}/${event.month}/${event.year!.substring(2, 4)}",
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold),
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
                                                      SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.timer,
                                                            color: Colors.grey,
                                                            size: 25,
                                                          ),
                                                          SizedBox(width: 2),
                                                          Text(
                                                            durationToString(event.duration!),
                                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(width: 4),
                                                          Icon(
                                                            Icons.record_voice_over,
                                                            color: Colors.grey,
                                                            size: 25,
                                                          ),
                                                          SizedBox(width: 8),
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
                                                          SizedBox(width: 8),
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
                                        width: MediaQuery.of(context).size.width*0.14,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Theme.of(context).primaryColor,
                                              size: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
 */