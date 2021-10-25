import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<Event> trainerEvent = [];
  List<Event> clientEvent = [];

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
      //getClientEventsDone();
    }
  }

  // Gets the events passed by the trainer.
  void getTrainerEventsDone() async {
    trainerEvent = await _accessDatabase.getAllEventsFromTrainer(widget.userID);
    print(trainerEvent.length);
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
            IconButton(
              onPressed: () {
                print("Travel to Chat");
              } ,
              icon: Icon(Icons.chat)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "@leomessi",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user!.email!,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                  SizedBox(width: 2),
                  Text(
                    user!.isTrainer! ?  AppLocalizations.of(context)!.trainer : AppLocalizations.of(context)!.client,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: trainerEvent.length,
                itemBuilder: (context,int index) {
                  Event event = trainerEvent[index];
                  return ListTile(
                    title: Text(event.title!, style: Styles.purpleTextStyle,),
                    subtitle: Text(event.description!, style: Styles.purpleTextStyle.copyWith(fontSize: 16),),
                  );
                },
              ),
            ],
          ),
        ),
    );
  }
}