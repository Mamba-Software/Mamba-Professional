import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Data/Models/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/DeleteFromBrandConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/DeleteFromEventConfirmationDialog.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/ChatCore/Chat.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../Constants.dart';
import '../../Styles/Styles.dart';
import '../LoadingViews/LoadingViewPurple.dart';

class ProfileViewUser extends StatefulWidget {
  @override
  String userID;
  bool viewOnly;
  ProfileViewUser({Key? key, required this.userID, required this.viewOnly}) : super(key: key);
  _ProfileViewUserState createState() => _ProfileViewUserState();
}

class _ProfileViewUserState extends State<ProfileViewUser> with SingleTickerProviderStateMixin {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _roomDataService = new RoomDataService();
  // Boolean Loading
  bool isLoading = false;
  // Usuario
  Usuario? user;
  // Birthday
  int birthday = 0;
  // Event List
  String month = "";
  int totalEvents  = 0;
  int thisMonthEvents  = 0;
  List<Event> listEvents = [];

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  // init Widget state. Loading user info.
  @override
  void initState() {
    isLoading = true;
    getUser();
    super.initState();
  }
  // Gets the user info from firebase.
  void getUser() async {
    totalEvents  = 0;
    thisMonthEvents  = 0;
    listEvents = [];
    user = await _userDataService.getUserDetails(widget.userID);
    getEventsDone();
  }

  // Gets the events passed by the trainer.
  void getEventsDone() async {
    DateTime today = DateTime.now();
    var tempMonth = 0;
    List<Event> list = await _eventDataService.getUserEvents(widget.userID);
    for (var i=0; i<list.length; i++) {
      Event event = list[i];
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (startDate.isBefore(today)) {
        listEvents.add(event);
        if (startDate.year == today.year && startDate.month == today.month) {
          tempMonth += 1;
        }
      }
    }
    listEvents.sort((a,b) {
      var aDate =  DateTime(
        int.parse(a.year!),
        int.parse(a.month!),
        int.parse(a.day!),
        int.parse(a.hour!),
        int.parse(a.minute!),
      );
      var bDate =  DateTime(
        int.parse(b.year!),
        int.parse(b.month!),
        int.parse(b.day!),
        int.parse(b.hour!),
        int.parse(b.minute!),
      );
      return aDate.compareTo(bDate);
    });
    listEvents = List.from(listEvents.reversed);
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
            !isLoading ? Row(
              children: [
                canDeleteFromBrand() ? IconButton(
                    onPressed: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return DeleteFromBrandConfirmationDialog(
                              text: AppLocalizations.of(context)!.deleteFromBrandConfirmation,
                              userId: widget.userID,
                            );
                          }
                      );
                      if (result) {
                        setState(() {
                          isLoading = true;
                        });
                        NotificationService().userLeavesBrand(widget.userID, currentBrand.id!);
                        // New Database
                        await Future.delayed(const Duration(milliseconds: 3000));
                        await _eventDataService.deleteUserFromUpcomingEvents(currentUser.id!, currentUser.isTrainer!);
                        await _brandDataService.deleteUserFromBrand(widget.userID, currentBrand.id!);
                        // TODO: Revisar Pq True, yo crec que es per recagar els users a todos los miemrbos
                        Navigator.pop(context, true);
                      }
                    } ,
                    icon: Icon(Icons.delete_outlined, color: Colors.red)
                ) : Container(),
                widget.viewOnly || user!.id! == currentUser.id ? Container() : IconButton(
                    onPressed: () async {
                      types.User otherUser = types.User(
                        firstName: user!.firstName,
                        lastName: user!.lastName,
                        id: user!.id!, // UID from Firebase Authentication
                        imageUrl: user!.imageUrl,
                      );
                      final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                        "trainer" + user!.id!: user!.isTrainer,
                        "trainer" + currentUser.id!: currentUser.isTrainer,
                        "active" + user!.id!: false,
                        "active" + currentUser.id!: true,
                      });

                      bool? deleteRoom = await Navigator.push(
                        context,
                        CupertinoPageRoute<bool>(
                            builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                        room.metadata!["active" + currentUser.id!] = false;
                        _roomDataService.updateRoom(room.id, room.metadata!);
                      });
                      if (!deleteRoom!) {
                        _roomDataService.deleteRoom(room.id);
                      }
                    } ,
                    icon: Icon(Icons.chat_outlined)
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.01)
              ],
            ) : Container(),

          ],
        ),
        body: isLoading ?
        LoadingViewPurple()
            :
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute<Null>(
                            builder: (context) => FullScreenPage(
                              child:  Image.network(
                                user!.imageUrl!,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).accentColor,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              dark: false,
                            )
                        )
                    );
                  },
                  child: CircularImage(
                    size: MediaQuery.of(context).size.width*0.45,
                    image: user!.imageUrl,
                    borderWidth: 1.5,)),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                child: Text(
                  user!.name!,
                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    user!.isTrainer! ?  Icons.record_voice_over : Icons.directions_run,
                    color: Theme.of(context).accentColor,
                    size: 25,
                  ),
                  user!.isTrainer! ? SizedBox(width: 4) : SizedBox(width: 2),
                  Text(
                    user!.isTrainer! ?  AppLocalizations.of(context)!.trainer : AppLocalizations.of(context)!.client,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600,color: Theme.of(context).accentColor,),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.00),
              /*
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
                  /*
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
                   */
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
              */
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
                      bool addLabel = false;
                      var startDate =  DateTime(
                        int.parse(event.year!),
                        int.parse(event.month!),
                        int.parse(event.day!),
                        int.parse(event.hour!),
                        int.parse(event.minute!),
                      );
                      String day = DateFormat('EEEE', Localizations.localeOf(context).languageCode).format(startDate);
                      String _month = DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(startDate);
                      if (_month != month) {
                        month = _month;
                        addLabel = true;
                      }
                      return Column(
                        children: [
                          addLabel ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                            child: Column(
                              children: [
                                //if(index != 0) SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      Localizations.localeOf(context).languageCode == 'ca' ? month.substring(3).toUpperCase() : month.toUpperCase(),
                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).accentColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ) : Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02),
                            child: ListTile(
                              onTap: () {
                                if (currentUser.isTrainer!) {
                                  Navigator.push(
                                      context,
                                    CupertinoPageRoute<Null>(
                                      builder: (context) => ViewEventTrainer(
                                            eventId: event.id!,
                                            canEdit: false,
                                            locale: Localizations.localeOf(context),
                                          )
                                      )
                                  );
                                } else {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute<Null>(
                                          builder: (context) => ViewEventClient(
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    toCapitalized(day),
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 12.0, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "${event.day}/${event.month}/${event.year!.substring(2, 4)}",
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 12.0, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              minLeadingWidth: MediaQuery.of(context).size.width*0.15,
                              title: Text(event.title!,style: Styles.purpleTextStyle.copyWith(fontSize: 18.0, fontWeight: FontWeight.w600),),
                              subtitle: Column(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                      Text(
                                        event.hour.toString(),
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        ":",
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        event.minute=="0" ? "00" : event.minute.toString(),
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                      Container(
                                          height: 8,
                                          width: 24,
                                          child: VerticalDivider(color: Colors.black, width: 10, thickness: 1,)
                                      ),
                                      Icon(
                                        Icons.timer,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                      Text(
                                        durationToString(event.duration!),
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                      Container(
                                          height: 8,
                                          width: 24,
                                          child: VerticalDivider(color: Colors.black, width: 10, thickness: 1,)
                                      ),
                                      Icon(
                                        Icons.record_voice_over,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                      Text(
                                        event.numTrainers.toString(),
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                      Container(
                                          height: 8,
                                          width: 24,
                                          child: VerticalDivider(color: Colors.black, width: 10, thickness: 1,)
                                      ),
                                      Icon(
                                        Icons.directions_run,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                      Text(
                                        event.numClients.toString(),
                                        style: TextStyle(color: Colors.black, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: !canDeleteFromEvent(event.numTrainers!) ? Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ) : GestureDetector(
                                onTap: () async {
                                  var result = await showDialog(
                                      context: context,
                                      builder: (_) {
                                        return DeleteFromEventConfirmationDialog(
                                          text: AppLocalizations.of(context)!.deleteFromEventConfirmation(event.title!),
                                          userId: widget.userID,
                                        );
                                      }
                                  );
                                  if (result) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _eventDataService.deleteUserFromEvent(event.id!, user!.id!);
                                    getUser();
                                  }
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                ],
              )
                :
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height*0.30,
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

  bool canDeleteFromBrand() {
    if (widget.viewOnly || currentUser.id! == user!.id! ) {
      return false;
    } else {
      // Si es entrenador i mira a un client
      if (currentUser.isTrainer! && !(user!.isTrainer!)) {
        return true;
      }
      // Si es entrenador i mira a un entrenador, ha de ser admin ID.
      if (currentUser.isTrainer! && user!.isTrainer! && currentUser.id! == currentBrand.adminID) {
        return true;
      }
      return false;
    }
  }

  bool canDeleteFromEvent(int numTrainers) {
    if (widget.viewOnly) {
      return false;
    } else {
      // Si es entrenador i mira a un client
      if (currentUser.isTrainer! && !(user!.isTrainer!)) {
        return true;
      }
      // Si es entrenador i mira a un entrenador, ha de ser admin ID.
      if (currentUser.isTrainer! && user!.isTrainer! && currentUser.id! == currentBrand.adminID && numTrainers > 1) {
        return true;
      }
      return false;
    }
  }
}
