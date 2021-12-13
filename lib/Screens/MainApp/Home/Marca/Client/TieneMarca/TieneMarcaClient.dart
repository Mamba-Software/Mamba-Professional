import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/LeaveBrandConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/BrandLocations.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Client/TieneMarca/SettingsBrandClient.dart';
import 'package:page_transition/page_transition.dart';

import 'TodosMiembrosClient.dart';

class TieneMarcaClient extends StatefulWidget {
  const TieneMarcaClient({Key? key}) : super(key: key);

  @override
  _TieneMarcaClientState createState() => _TieneMarcaClientState();
}

class _TieneMarcaClientState extends State<TieneMarcaClient> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean isLoading
  bool isLoading = false;
  // Brand Events Today
  List<Event> todayEvents = [];
  int numberEventsFinished = 0;
  int numberEventsToDo = 0;

  @override
  void initState() {
    isLoading = true;
    initBrandHome();
    super.initState();
  }

  // Init for Brand Home
  initBrandHome() async {
    unreadNotifications = await _accessDatabase.numberUnreadNotifications(currentUser.id!);
    await updateMembers();
    await getBrand();
    await getNumberFinishedEvents();
    await getAllEventsTodayBrand();
    if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update Number of Members.
  Future<void> updateMembers() async {
    await _accessDatabase.updateNumberMembers(currentBrand.id!);
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand = await _accessDatabase.getBrandDetails(currentBrand.id!);
  }

  // Gets number of finished events
  Future<void> getNumberFinishedEvents() async {
    numberEventsFinished = await _accessDatabase.getNumberEventsFinishedBrand(currentBrand.id!);
    numberEventsToDo = await _accessDatabase.getNumberEventsToDoBrand(currentBrand.id!);
  }
  // Gets all events of today.
  Future<void> getAllEventsTodayBrand() async {
    todayEvents = await _accessDatabase.getAllEventsTodayBrand(currentBrand.id!);
  }

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Center(
        child: LoadingViewPurple(),
      )
        :
      Scaffold(
        appBar: null,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.06),
                Container(
                  height: MediaQuery.of(context).size.height*0.25,
                  width: MediaQuery.of(context).size.width*0.90,
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text("${currentBrand.name!}",
                                  style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Helvetica"), textAlign: TextAlign.left
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.04,),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeftWithFade,
                                          child: BrandLocations(
                                            brandId: currentBrand.id!,
                                          ),
                                        )
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.exit_to_app, color: Colors.red, size: MediaQuery.of(context).size.height*0.04,),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    // DeleteDialog
                                    var result = await showDialog(
                                        context: context,
                                        builder: (_) {
                                          return LeaveBrandConfirmationDialog(text: AppLocalizations.of(context)!.exitBrandConfirm);
                                        }
                                    );
                                    print(result);
                                    if (result) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      NotificationService().userLeavesBrand(currentUser.id!, currentUser.brandID!);
                                      Conversation conv = await _accessDatabase.getConversationByBrand(currentUser.brandID); //12/12/2021
                                      await _accessDatabase.deleteUserFromAllBrandEvents(currentUser.id!, currentUser.brandID!, currentUser.isTrainer!);
                                      await _accessDatabase.leaveBrand(currentUser.id!);
                                      //12/12/2021
                                      for(int i = 0; i < conv.users.length; ++i) {
                                        if(conv.users[i]['uid'] == currentUser.id) {
                                          conv.users.removeAt(i);
                                        }
                                      }
                                      await _accessDatabase.updateConversationUsers(conv.conversationId, conv.users);
                                      Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute<Null>(
                                            builder: (context) =>
                                                SplashScreen(),
                                            settings: RouteSettings(
                                                name: 'SplashScreen'),
                                          )
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Row(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height*0.15,
                              child: Center(
                                child: CircularImage(size: MediaQuery.of(context).size.width * 0.33, image: currentBrand.logoUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.05),
                            Container(
                              height: MediaQuery.of(context).size.height*0.15,
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.directions_run, color: Theme.of(context).accentColor,),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                            Text(
                                              currentBrand.numberClients.toString(),
                                              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor, fontSize: 16),),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                            Flexible(child: Text(AppLocalizations.of(context)!.clients.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).accentColor), textAlign: TextAlign.center,))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.record_voice_over, color: Theme.of(context).accentColor,),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                            Text(
                                              currentBrand.numberTrainers.toString(),
                                              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor, fontSize: 16),),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                            Flexible(child: Text(AppLocalizations.of(context)!.trainers.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).accentColor), textAlign: TextAlign.center,))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.event_available_outlined, color: Theme.of(context).primaryColor,),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                            Text(
                                              numberEventsFinished.toString(),
                                              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                            Flexible(child: Text(AppLocalizations.of(context)!.sessionsDone.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).primaryColor), textAlign: TextAlign.center,))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.event, color: Theme.of(context).primaryColor,),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                            Text(
                                              numberEventsToDo.toString(),
                                              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),),
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                            Flexible(child: Text(AppLocalizations.of(context)!.sessionsToDo.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).primaryColor), textAlign: TextAlign.center,))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                todayEvents.length > 0 ? Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: BrandEventsToday(
                                  brandId: currentBrand.id!
                                )
                            )
                        ).whenComplete(() {
                          setState(() {
                            isLoading = true;
                            initBrandHome();
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
                                  child: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 30,)
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.69,
                                child: Center(child: Text(AppLocalizations.of(context)!.today(toCapitalized(DateFormat('EEEE d/M/yy', Localizations.localeOf(context).languageCode).format(DateTime.now()))), style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.w400)),),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.04),
                  ],
                ) : Container(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: CalendarWidgetClient(
                              brandID: currentBrand.id!,
                              onlyView: false,
                            )
                        )
                    ).whenComplete(() {
                      setState(() {
                        isLoading = true;
                        initBrandHome();
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
                              Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                              SizedBox(height: MediaQuery.of(context).size.height*0.005),
                              Text(AppLocalizations.of(context)!.calendarBrandTextClient(currentBrand.name!), style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey[200])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: TodosMiembrosClient(
                              brandID: currentBrand.id!,
                              brandAdmin: currentBrand.adminID!,
                              viewOnly: false,
                            )
                        )
                    ).whenComplete(() {
                      setState(() {
                        isLoading = true;
                        initBrandHome();
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
                              image: Image.asset(Constants.teamImage).image,
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
                              Text(AppLocalizations.of(context)!.members, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                              SizedBox(height: MediaQuery.of(context).size.height*0.005),
                              Text(AppLocalizations.of(context)!.membersBrandText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey[200])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
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
                              //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                              image: Image.asset(Constants.podiumImage).image,
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
                              Text(AppLocalizations.of(context)!.ranking, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                              SizedBox(height: MediaQuery.of(context).size.height*0.005),
                              Text(AppLocalizations.of(context)!.rankingBrandText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.70, bottom: MediaQuery.of(context).size.height * 0.07),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5), size: 50,)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
              ],
            ),
          ),
    ),
      );
  }
}

/*
      // Calls a Modal Bottom Sheet every time an Icon is Tapped. It updates the page after closing only if there have been changes
    // inside the modal. Some set the isLoading to true (TusDatos, as the name needs to be updated in the UI), others don´t as it
    // can happen in the background (Settings)
    void _showPerfiClientModals(int _buttonIndex) async {
      switch (_buttonIndex) {
        case 0:
          showModalBottomSheet<bool>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
              ),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return AnadirMiembro();
              }
          ).whenComplete(() =>{
            setState(() {
              _statusButtons[0] = !_statusButtons[0];
            })
          });
          break;
        case 1:
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: TodosMiembros()
              )
          );
          break;
        case 2:
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: CalendarWidget(
                    brandID: currentBrand.id!,
                    canEdit: true,
                  )
              )
          );
          break;
        case 3:
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return HistorialSesiones();
              }).whenComplete(() => {
            setState(() {
              _statusButtons[3] = !_statusButtons[3];
            })
          });
          break;
        default:
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container();
          });
      }
    }


  // Logos Flotants
                        // Perfil Adalt Esquerra
                        Positioned(
                            top: 0,
                            bottom: MediaQuery.of(context).size.height*0.21,
                            left: 0,
                            right: MediaQuery.of(context).size.width*0.45,
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
                                      Icon(Icons.groups, color: Colors.white, size: _iconSize,), // icon
                                    ],
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Theme.of(context).accentColor,
                                    //backgroundColor: !_statusButtons[1] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
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
                            bottom: MediaQuery.of(context).size.height*0.21,
                            left: MediaQuery.of(context).size.width*0.45,
                            right: 0,
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
                                      Icon(Icons.notifications, color: Colors.white, size: _iconSize,), // icon
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
                        // Ajustes Mig Esquerra
                        Positioned(
                            top: MediaQuery.of(context).size.height*0.07,
                            bottom: 0,
                            left: 0,
                            right:  MediaQuery.of(context).size.width*0.70,
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
                                      Icon(Icons.leaderboard_outlined, color: Colors.white, size: _iconSize,), // icon
                                    ],
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Theme.of(context).accentColor,
                                    //backgroundColor: !_statusButtons[3] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                    elevation: 5,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(_globusSize),
                                  ),
                                ),
                              ],
                            )),
                        // Ajustes Mig Dreta
                        Positioned(
                            top: MediaQuery.of(context).size.height*0.07,
                            bottom: 0,
                            left: MediaQuery.of(context).size.width*0.70,
                            right: 0,
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
                                      Icon(Icons.today, color: Colors.white, size: _iconSize,),
                                      //Text("Calendario", style: Styles.purpleTextStyle.copyWith(color: Colors.white, fontSize: 16,), textAlign: TextAlign.center,),// icon
                                    ],
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Theme.of(context).accentColor,
                                    //backgroundColor: !_statusButtons[2] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                    elevation: 5,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(_globusSize),
                                  ),
                                ),
                              ],
                            )),



 Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.todaysBrandEvents, style: Styles.purpleTextStyle.copyWith(color: Colors.grey), textAlign: TextAlign.center,),
                    SizedBox(width: MediaQuery.of(context).size.width*0.01),
                    Text(DateFormat('d/M/yy').format(DateTime.now()), style: Styles.purpleTextStyle.copyWith(color: Colors.grey), textAlign: TextAlign.center,),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
              ],
            ),
          ),


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
                      Text("¡No tienes ningún evento a la vista!", style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
                    ],
                  ),
                ),
 */