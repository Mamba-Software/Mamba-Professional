import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/BrandLocations.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/TodosMiembrosTrainer.dart';
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

  @override
  void initState() {
    isLoading = true;
    initBrandHome();
    super.initState();
  }
  // Init for Brand Home
  initBrandHome() {
    getBrand();
    getAllEventsTodayBrand();
  }

  // Gets the user info from firebase.
  void getBrand() async {
    currentBrand = await _accessDatabase.getBrandDetails(currentBrand.id!);
  }

  // Gets the events passed by the trainer.
  void getAllEventsTodayBrand() async {
    todayEvents = await _accessDatabase.getAllEventsTodayBrand(currentBrand.id!);
    setState(() {
      isLoading = false;
    });
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.32,
                child: Stack(
                    alignment: Alignment.topCenter,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        bottom: MediaQuery.of(context).size.height*0.15,
                        left: 0,
                        right: MediaQuery.of(context).size.width*0.70,
                        child: IconButton(
                          icon: Icon(Icons.explore_outlined, color: Theme.of(context).primaryColor, size: 50,),
                          alignment: Alignment.center,
                          onPressed: () {

                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height*0.12,
                        bottom: 0,
                        left: 0,
                        right: MediaQuery.of(context).size.width*0.70,
                        child: Text(
                          AppLocalizations.of(context)!.feedback,
                          style: Styles.purpleTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: MediaQuery.of(context).size.height*0.15,
                        left: MediaQuery.of(context).size.width*0.70,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.settings, color: Theme.of(context).primaryColor, size: 50,),
                          onPressed: () {

                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height*0.12,
                        bottom: 0,
                        left: MediaQuery.of(context).size.width*0.70,
                        right: 0,
                        child: Text(
                          AppLocalizations.of(context)!.settings,
                          style: Styles.purpleTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height*0.07,
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
                                child: CircularImage(size: MediaQuery.of(context).size.height * 0.19, image: currentBrand.logoUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height*0.29,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Text("${currentBrand.name!}", style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 26, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                      ),
                    ]
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              todayEvents.length > 0 ? Column(
                children: [
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
                            image: Image.asset(Constants.calendarImage).image,
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
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: BrandLocations(
                            brandId: currentBrand.id!,
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
                            image: Image.asset(Constants.myLocationsImage).image,
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
                            Text(AppLocalizations.of(context)!.locations, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.locationsBrandText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey[200])),
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