import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../Constants.dart';
import '../../Styles.dart';
import '../LoadingViewPurple.dart';

class ProfileViewUser extends StatefulWidget {
  @override
  String userID;
  ProfileViewUser({Key? key, required this.userID}) : super(key: key);
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
    if (user!.dateOfBirth! != "null") {
      DateTime dob = DateFormat('dd-mm-yyyy').parse(user!.dateOfBirth!);
      birthday = calculateAge(dob);
    }
    if (user!.isTrainer!) {
      getTrainerEventsDone();
    } else {
      getClientEventsDone();
    }
  }

  // Gets the events passed by the trainer.
  void getTrainerEventsDone() async {
    listEvents = await _accessDatabase.getAllEventsFromTrainer(widget.userID);
    setState(() {
      isLoading = false;
    });
  }
  // Gets the events passed by the trainer.
  void getClientEventsDone() async {
    listEvents = await _accessDatabase.getAllEventsFromClient(widget.userID);
    setState(() {
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
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () {
                  print("Travel to Chat");
                } ,
                icon: Icon(Icons.chat)
              ),
            )
          ],
        ),
        body: isLoading ?
        LoadingViewPurple()
            :
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              CircularImage(size: MediaQuery.of(context).size.width*0.40, image: user!.imageUrl, borderWidth: 1.5,),
              const SizedBox(height: 24),
              Text(
                user!.name!,
                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(height: 4),
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "@leomessi",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
               */
              const SizedBox(height: 16),
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
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
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
                    birthday.toString(),
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
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
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.format_list_numbered, color: Colors.grey, size: 25,),
                    SizedBox(width: 8,),
                    Text(
                      AppLocalizations.of(context)!.totalNumberEvents(listEvents.length.toString()),
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
              listEvents.length != 0 ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /*
                      Text(
                        "HOLA",
                        style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      // Aqui hauria de ficar les dates semana a semana
                       */
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: listEvents.length,
                    itemBuilder: (context,int index) {
                      Event event = listEvents[index];
                      return GestureDetector(
                        onTap: () => {
                          print(event.id)
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.15,
                          child: new Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              //side: BorderSide(color: Styles.accent, width: 0.01),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.02, MediaQuery.of(context).size.width*0.01, MediaQuery.of(context).size.width*0.02, MediaQuery.of(context).size.width*0.01),
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
                      );
                    },
                  ),
                  SizedBox(height: 10)
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
                        Container(
                            height: 150,
                            child: Image.asset(Constants.emptyCalendar)
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.20),
                          child: Text(AppLocalizations.of(context)!.noTrainingsDone, style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}