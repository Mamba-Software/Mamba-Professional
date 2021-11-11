import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/MyCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/Settings.dart';
import 'package:page_transition/page_transition.dart';

// Profile page for each user.
class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Brand Events Today
  List<Event> todayEvents = [];
  // Image Picker
  var _image;

  @override
  void initState() {
    isLoading = true;
    initProfileHome();
    super.initState();
  }
  // Init for Brand Home
  initProfileHome() {
    getUser();
    getUserEventsToday();
  }

  // Gets the user info from firebase.
  void getUser() async {
    currentUser = await _accessDatabase.getCurrentUserDetails();
  }
  // Gets user events today.
  void getUserEventsToday() async {
    todayEvents = await _accessDatabase.getAllEventsTodayUser(currentUser.id!, currentUser.isTrainer!);
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

  Widget build(BuildContext context) {

    return isLoading ?
      Center(
        child: LoadingViewPurple()
      )
        :
      Scaffold(
        appBar: null,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.30,
                child: Stack(
                    alignment: Alignment.topCenter,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        bottom: MediaQuery.of(context).size.height*0.10,
                        left: 0,
                        right: MediaQuery.of(context).size.width*0.65,
                        child: Icon(Icons.help_outline, color: Theme.of(context).accentColor.withOpacity(0.5), size: 50,),
                      ),
                      Positioned(
                        top: 0,
                        bottom: MediaQuery.of(context).size.height*0.10,
                        left: MediaQuery.of(context).size.width*0.65,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.settings, color: Theme.of(context).accentColor.withOpacity(0.5), size: 50,),
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: Settings(),
                                )
                            ).whenComplete(() {
                              setState(() {
                                isLoading = true;
                                initProfileHome();
                              });
                            });
                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height*0.05,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.20,
                              child: Center(
                                child: CircularImage(size: MediaQuery.of(context).size.height * 0.18, image: currentUser.imageUrl, file: _image, color: Theme.of(context).accentColor, borderWidth: 2,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height*0.26,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Expanded(child: Text("${currentUser.name!}", style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 26, fontFamily: "Helvetica"), textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                    ]
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              Column(
                children: [
                  todayEvents.length != 0 ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.todaysBrandEvents, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w400, fontSize: 26,), textAlign: TextAlign.start),
                            Row(
                              children: [
                                Text(todayEvents.length.toString(), style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                Text(AppLocalizations.of(context)!.events, style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                                SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                Icon(
                                  Icons.swipe,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Container(
                        height: MediaQuery.of(context).size.height*0.28,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: todayEvents.length,
                            itemBuilder: (context, int index) {
                              var event = todayEvents[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
                                child: GestureDetector(
                                      onTap: () {
                                        bool canEdit = true;
                                        DateTime startDate = DateTime(
                                          int.parse(event.year!),
                                          int.parse(event.month!),
                                          int.parse(event.day!),
                                          int.parse(event.hour!),
                                          int.parse(event.minute!),
                                        );
                                        if (startDate.isBefore(DateTime.now())) {
                                          canEdit = false;
                                        }
                                        if (currentUser.isTrainer!) {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.bottomToTop,
                                                child: ViewEventTrainer(
                                                  eventId: event.id!,
                                                  canEdit: canEdit,
                                                  locale: Localizations.localeOf(context),
                                                )
                                            )
                                          ).whenComplete(() {
                                            setState(() {
                                              isLoading = true;
                                              initProfileHome();
                                            });
                                          });
                                        } else {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.bottomToTop,
                                                  child: ViewEventClient(
                                                    eventId: event.id!,
                                                    canJoin: true,
                                                    locale: Localizations.localeOf(context),
                                                  )
                                              )
                                          ).whenComplete(() {
                                            setState(() {
                                              isLoading = true;
                                              initProfileHome();
                                            });
                                          });
                                        }
                                      },
                                      child: Material(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.all(
                                            const Radius.circular(10.0),
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.28,
                                              width: MediaQuery.of(context).size.width * 0.90,
                                              decoration: new BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: new BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                                image: new DecorationImage(
                                                  fit: BoxFit.cover,
                                                  //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
                                                  image: Image.asset(Constants.eventBackground).image,
                                                ),
                                              ),
                                              child: Center(),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.90,
                                              height: MediaQuery.of(context).size.height * 0.28,
                                              decoration: new BoxDecoration(
                                                color: Colors.white,
                                                gradient: LinearGradient(
                                                    begin: FractionalOffset.topCenter,
                                                    end: FractionalOffset.bottomCenter,
                                                    colors: [
                                                      Colors.grey.withOpacity(0.0),
                                                      Colors.black,
                                                    ],
                                                    stops: [
                                                      0.0,
                                                      0.75
                                                    ]
                                                ),
                                                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                                borderRadius: new BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                              child: Center(),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(event.title!, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.schedule,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                      Text(
                                                        event.hour.toString(),
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                      Text(
                                                        ":",
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                      Text(
                                                        event.minute=="0" ? "00" : event.minute.toString(),
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                      Container(
                                                          height: 16,
                                                          width: 32,
                                                          child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                                                      ),
                                                      Icon(
                                                        Icons.timer,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                      Text(
                                                        durationToString(event.duration!),
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                      Container(
                                                          height: 16,
                                                          width: 32,
                                                          child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                                                      ),
                                                      Icon(
                                                        Icons.record_voice_over,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                      Text(
                                                        event.selectedTrainers.length.toString(),
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                      Container(
                                                          height: 16,
                                                          width: 32,
                                                          child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                                                      ),
                                                      Icon(
                                                        Icons.directions_run,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                                      Text(
                                                        event.joinedMembers.length.toString(),
                                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                                      ),
                                                    ],
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
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ],
                  ) : Container(),
                  currentBrand.id != null ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: CalendarWidgetTrainer(
                                brandID: currentBrand.id!,
                                canEdit: true,
                              )
                          )
                      ).whenComplete(() {
                        setState(() {
                          isLoading = true;
                          initProfileHome();
                        });
                      });
                    },
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: new BoxDecoration(
                          color: Theme.of(context).accentColor,
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.09,
                                child: Icon(Icons.add, color: Colors.white, size: 30,)
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.69,
                              child: Center(child: Text(AppLocalizations.of(context)!.planSessions, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.w400))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ) : Container(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: MyCalendarWidget(
                                brandID: currentBrand.id!,
                              )
                          )
                      ).whenComplete(() {
                        setState(() {
                          isLoading = true;
                          initProfileHome();
                        });
                      });
                    },
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            height: MediaQuery.of(context).size.height * 0.20,
                            decoration: new BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Theme.of(context).accentColor, width: 1),
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                                image: Image.asset(Constants.mySessionsImage).image,
                              ),
                            ),
                            child: Center(),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            height: MediaQuery.of(context).size.height * 0.20,
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Colors.grey.withOpacity(0.0),
                                    Colors.black,
                                  ],
                                  stops: [
                                    0.0,
                                    0.75
                                  ]
                              ),
                              border: Border.all(color: Theme.of(context).accentColor, width: 1),
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            child: Center(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.mySchedule, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                                SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                Text(AppLocalizations.of(context)!.myScheduleText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey[200])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            height: MediaQuery.of(context).size.height * 0.20,
                            decoration: new BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Theme.of(context).accentColor, width: 1),
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
                                image: Image.asset(Constants.myProgressImage).image,
                              ),
                            ),
                            child: Center(),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.90,
                            height: MediaQuery.of(context).size.height * 0.20,
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Colors.grey.withOpacity(0.0),
                                    Colors.black,
                                  ],
                                  stops: [
                                    0.0,
                                    0.75
                                  ]
                              ),
                              border: Border.all(color: Theme.of(context).accentColor, width: 1),
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            child: Center(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.myProgress, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 26, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                                SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                Text(AppLocalizations.of(context)!.myProgressText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.white.withOpacity(0.5))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                ],
              ),
            ],
          ),
        ),
      );

  }

  @override
  void dispose() {
    super.dispose();
  }

}

/*
 Padding(
                padding: const EdgeInsets.all(0),
                child: new Container(
                  height: MediaQuery.of(context).size.height*0.40,
                  //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height*0.40,
                        child: new Stack(
                            alignment: Alignment.center,
                            //fit: StackFit.,
                            children: <Widget>[
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        child: Center(
                                          child: isLoading ?
                                          CircularProgressIndicator() :
                                          CircularImage(size: MediaQuery.of(context).size.height * 0.22, image: currentUser.imageUrl, file: _image, color: Theme.of(context).accentColor, borderWidth: 1.5,),
                                        ),
                                      ),
                                      onTap: () async {
                                        getImage();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // Logos Flotants
                              // Perfil Adalt Esquerra
                              Positioned(
                                  top: 0,
                                  bottom: MediaQuery.of(context).size.height*0.25,
                                  left: 0,
                                  right: MediaQuery.of(context).size.width*0.60,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _statusButtons[0] = !_statusButtons[0];
                                            _showPerfiClientModals(0);
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon( Icons.person, color: Colors.white, size: _iconSize,),
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Theme.of(context).accentColor,
                                          //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                          elevation: 5,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(_globusSize),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Ajustes Adalt Dreta
                              Positioned(
                                  top: 0,
                                  bottom: MediaQuery.of(context).size.height*0.25,
                                  left: MediaQuery.of(context).size.width*0.60,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _statusButtons[1] = !_statusButtons[1];
                                            _showPerfiClientModals(1);
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.settings, color: Colors.white, size: _iconSize,), // icon
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Theme.of(context).accentColor,
                                          //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                          elevation: 5,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(_globusSize),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Feedback Abaix Esquerra
                              Positioned(
                                  top: MediaQuery.of(context).size.height*0.25,
                                  bottom: 0,
                                  left: 0,
                                  right: MediaQuery.of(context).size.width*0.60,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _statusButtons[2] = !_statusButtons[2];
                                            _showPerfiClientModals(2);
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.help_outline, color: Colors.white, size: _iconSize,), // icon
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Theme.of(context).accentColor,
                                          //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                          elevation: 5,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(_globusSize),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Bug Abaix Dreta
                              Positioned(
                                  top: MediaQuery.of(context).size.height*0.25,
                                  bottom: 0,
                                  left: MediaQuery.of(context).size.width*0.60,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _statusButtons[3] = !_statusButtons[3];
                                            _showPerfiClientModals(3);
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.report_problem_outlined, color: Colors.white, size: _iconSize,), // icon
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Theme.of(context).accentColor,
                                          //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                          elevation: 5,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(_globusSize),
                                        ),
                                      ),
                                    ],
                                  )),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
              new Container(
                //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
                child: new Column(
                  children: [
                    Text("${currentUser.name}", style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold, fontSize: 26), textAlign: TextAlign.center,),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: NumbersWidget(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:20.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.memberSince(currentUser.dateJoined!), style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                    currentUser.brandID != "null" ? Container(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(currentUser.isTrainer! ? AppLocalizations.of(context)!.trainerOf : AppLocalizations.of(context)!.clientOf, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(currentBrand.name!, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          //CircularImage(size: MediaQuery.of(context).size.height * 0.07, image: currentBrand.logoUrl, borderWidth: 1.5, color: Theme.of(context).accentColor,),
                        ],
                      ),
                    ) : Container(
                      padding: EdgeInsets.all(0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.notInBrand, style: Styles.purpleTextStyle.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
 */

class NumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildButton(context, '4.8', 'Ranking'),
      buildDivider(context),
      buildButton(context, '35', 'Following'),
      buildDivider(context),
      buildButton(context, '50', 'Followers'),
    ],
  );

  Widget buildDivider(BuildContext context) => Container(
    height: 24,
    child: VerticalDivider(color: Theme.of(context).primaryColor,),
  );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      );
}

